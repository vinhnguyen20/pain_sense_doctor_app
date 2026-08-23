import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_doctor/core/config/app_config.dart';
import 'package:app_doctor/features/chats/data/models/chat_ws_event.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:flutter/foundation.dart';

/// WebSocket close codes
abstract class _WsCloseCodes {
  static const unauthorized = 4001;
  static const tokenExpired = 4003;
}

class ChatWsDataSource {
  final String conversationId;
  final Future<String?> Function() _getAccessToken;
  final Message Function(Map<String, dynamic>) _parseMessage;
  final Conversation Function(Map<String, dynamic>) _parseConversation;

  static const int _maxReconnectAttempts = 6;
  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _pingInterval = Duration(seconds: 25);
  static const Duration _stabilityResetDelay = Duration(seconds: 12);

  final _controller = StreamController<ChatWsEvent>.broadcast();
  Stream<ChatWsEvent> get events => _controller.stream;

  WebSocket? _socket;
  StreamSubscription? _wsSubscription;
  Timer? _reconnectTimer;
  Timer? _stabilityTimer;

  int _reconnectAttempt = 0;
  bool _isDisposed = false;
  bool _manualDisconnect = false;
  bool _isConnecting = false;
  String? _connectedUserId;

  bool get isConnected => _socket != null;
  String? get connectedUserId => _connectedUserId;

  final Map<String, int> _preferredPortByHost = {};

  ChatWsDataSource({
    required this.conversationId,
    required Future<String?> Function() getAccessToken,
    required Message Function(Map<String, dynamic>) parseMessage,
    required Conversation Function(Map<String, dynamic>) parseConversation,
  }) : _getAccessToken = getAccessToken,
       _parseMessage = parseMessage,
       _parseConversation = parseConversation;

  Future<void> connect() async {
    if (_isDisposed || _manualDisconnect || _isConnecting || isConnected) {
      return;
    }
    _isConnecting = true;

    try {
      final token = await _getAccessToken();
      if (token == null || token.isEmpty) {
        _emit(const ChatWsDisconnected(error: 'Missing access token'));
        return;
      }

      _closeSocket();
      final candidates = _prioritize([_buildUri(token)]);
      _log('connect candidates: ${candidates.map(_maskUri).join(' | ')}');
      Object? lastError;

      for (final uri in candidates) {
        try {
          _log('try ${_maskUri(uri)}');

          final socket =
              await WebSocket.connect(
                uri.toString(),
                headers: {'Authorization': 'Bearer $token'},
              ).timeout(
                _connectTimeout,
                onTimeout: () => throw TimeoutException(
                  'WS connect timed out',
                  _connectTimeout,
                ),
              );

          if (_isDisposed) {
            await socket.close();
            return;
          }

          socket.pingInterval = _pingInterval;

          _socket = socket;
          _recordSuccess(uri);
          _log('connected ${_maskUri(uri)}');
          break;
        } catch (e) {
          _log('fail ${_maskUri(uri)} | $e');
          lastError = e;
        }
      }

      if (_socket == null) {
        _onDisconnect(error: lastError?.toString() ?? 'WebSocket error');
        return;
      }

      _wsSubscription = _socket!.listen(
        _onRawEvent,
        onError: (Object error) => _onDisconnect(error: error.toString()),
        onDone: () => _onDone(_socket),
        cancelOnError: false,
      );
    } finally {
      _isConnecting = false;
    }
  }

  void disconnect() {
    _manualDisconnect = true;
    _stopReconnectTimer();
    _stopStabilityTimer();
    _reconnectAttempt = 0;
    _closeSocket();
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _controller.close();
  }

  void _onRawEvent(dynamic raw) {
    final payload = _decode(raw);
    if (payload == null) {
      _log('unparsed payload type=${raw.runtimeType}');
      return;
    }

    final event = (payload['event'] ?? payload['type'] ?? payload['name'])
        ?.toString()
        .trim()
        .toLowerCase();

    if (event != 'error') _resetStabilityTimer();

    switch (event) {
      case 'connected':
        _handleConnected(payload);
      case 'pong':
        _log('RX pong');
      case 'error':
        _handleServerError(payload);
      case 'conversation.updated':
        _handleConversationUpdated(payload);
      case 'message.read':
        _handleMessageRead(payload);
      case 'message.created':
        _handleMessageCreated(payload);
      default:
        _handleFallback(payload, event);
    }
  }

  void _handleConnected(Map<String, dynamic> payload) {
    final data = _toMap(payload['data']);
    final channel = data?['channel']?.toString().trim().toLowerCase();
    if (channel == 'notifications') {
      _log('RX connected ignored: notifications channel');
      return;
    }

    final connectedConvId =
        data?['conversation_id']?.toString() ??
        data?['conversationId']?.toString();

    if (connectedConvId != null &&
        connectedConvId.isNotEmpty &&
        connectedConvId.trim() != conversationId.trim()) {
      _log('RX connected ignored: conversation mismatch id=$connectedConvId');
      return;
    }

    final userId = data?['user_id']?.toString() ?? data?['userId']?.toString();
    _connectedUserId = userId?.trim();
    _log('RX connected userId=$userId');
    _stopReconnectTimer();
    _emit(ChatWsConnected(userId: userId));
    _startStabilityTimer();
  }

  void _handleServerError(Map<String, dynamic> payload) {
    final error = payload['error'];
    final reason = error is Map ? error['reason']?.toString() : null;
    _log('RX error reason=$reason');
    _onDisconnect(error: reason ?? 'WebSocket error');
  }

  void _handleConversationUpdated(Map<String, dynamic> payload) {
    final data = _toMap(payload['data']);
    if (data == null) return;
    try {
      final conversationMap =
          _toMap(data['conversation']) ?? _toMap(data['data']) ?? data;
      final conversation = _parseConversation(conversationMap);
      if (conversation.id.trim().isEmpty) return;
      _emit(ChatWsConversationUpdated(conversation));
      _log('RX conversation.updated id=${conversation.id}');
    } catch (_) {}
  }

  void _handleMessageRead(Map<String, dynamic> payload) {
    final data = _toMap(payload['data']);
    if (data == null) return;
    final convId =
        (data['conversation_id'] ?? data['conversationId'])?.toString() ?? '';
    final readerId = (data['user_id'] ?? data['userId'])?.toString() ?? '';
    if (readerId.isNotEmpty) {
      _emit(ChatWsMessageRead(conversationId: convId, readerId: readerId));
      _log('RX message.read by=$readerId');
    }
  }

  void _handleMessageCreated(Map<String, dynamic> payload) {
    final map =
        _extractMessageMap(_toMap(payload['data'])) ??
        _findMessageInPayload(payload);
    if (map == null) return;
    try {
      final message = _parseMessage(map);
      _emit(ChatWsMessageReceived(message));
      _log('RX message.created id=${message.id} type=${message.type}');
    } catch (e) {
      _log('RX message.created parse error=$e');
    }
  }

  void _handleFallback(Map<String, dynamic> payload, String? event) {
    final map = _findMessageInPayload(payload);
    if (map == null) {
      _log('RX ignored event=$event');
      return;
    }
    try {
      final message = _parseMessage(map);
      _emit(ChatWsMessageReceived(message));
      _log('RX fallback message handled event=$event');
    } catch (_) {}
  }

  Map<String, dynamic>? _findMessageInPayload(Map<String, dynamic> payload) {
    final candidates = [
      _extractMessageMap(payload),
      _extractMessageMap(_toMap(payload['data'])),
      _extractMessageMap(_toMap(payload['message'])),
      _extractMessageMap(_toMap(payload['payload'])),
      _extractMessageMap(_toMap(_toMap(payload['data'])?['message'])),
      _extractMessageMap(_toMap(_toMap(payload['data'])?['data'])),
    ];
    for (final c in candidates) {
      if (c != null) return c;
    }
    return null;
  }

  Map<String, dynamic>? _decode(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is List<int>) {
      try {
        final decoded = jsonDecode(utf8.decode(raw));
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic>? _extractMessageMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    final hasConvId =
        data.containsKey('conversation_id') ||
        data.containsKey('conversationId');
    final hasId = data.containsKey('id') || data.containsKey('_id');
    final hasContent =
        data.containsKey('content') ||
        data.containsKey('sent_at') ||
        data.containsKey('sentAt');
    final hasSender =
        data.containsKey('sender_id') || data.containsKey('senderId');
    if ((hasId || hasConvId) && (hasContent || hasSender)) return data;
    return _toMap(data['message']) ?? _toMap(data['data']);
  }

  void _onDone(WebSocket? socket) {
    final code = socket?.closeCode;
    final reason = socket?.closeReason;
    _log('ws closed code=$code reason=$reason');

    final isAuthError =
        code == _WsCloseCodes.unauthorized ||
        code == _WsCloseCodes.tokenExpired;

    if (isAuthError) {
      _manualDisconnect = true;
      _onDisconnect(
        error: 'Authentication error (code $code). Please log in again.',
        isAuthError: true,
      );
      return;
    }

    _onDisconnect(
      error: (reason != null && reason.isNotEmpty)
          ? reason
          : 'Connection closed (code $code)',
    );
  }

  void _onDisconnect({String? error, bool isAuthError = false}) {
    if (_isDisposed) return;
    _stopStabilityTimer();
    _closeSocket();
    _emit(ChatWsDisconnected(error: error, isAuthError: isAuthError));
    if (_manualDisconnect) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || _manualDisconnect || _reconnectTimer != null) return;

    if (_reconnectAttempt >= _maxReconnectAttempts) {
      _log('max reconnect attempts reached');
      _emit(
        const ChatWsDisconnected(
          error: 'Could not reconnect after several attempts. Tap to retry.',
        ),
      );
      return;
    }

    _reconnectAttempt += 1;
    final backoff = math.min(
      20,
      math.max(1, math.pow(2, _reconnectAttempt).toInt()),
    );
    _log('reconnect in ${backoff}s attempt=$_reconnectAttempt');
    _emit(const ChatWsReconnecting());
    _reconnectTimer = Timer(Duration(seconds: backoff), () {
      _reconnectTimer = null;
      if (_isDisposed || _manualDisconnect) return;
      connect();
    });
  }

  void _closeSocket() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
  }

  void _startStabilityTimer() {
    _stopStabilityTimer();
    _stabilityTimer = Timer(_stabilityResetDelay, () {
      if (_reconnectAttempt == 0) return;
      _reconnectAttempt = 0;
      _log('ws stable; reconnect attempt reset');
    });
  }

  void _stopStabilityTimer() {
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  void _resetStabilityTimer() => _startStabilityTimer();

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Uri _buildUri(String token) {
    final base = Uri.parse(AppConfig.socketUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/ws/messages/$conversationId',
      queryParameters: {'token': token},
    );
  }

  List<Uri> _prioritize(List<Uri> candidates) {
    if (candidates.length <= 1) return candidates;
    final preferred = <Uri>[];
    final others = <Uri>[];
    for (final uri in candidates) {
      final host = uri.host.toLowerCase();
      final prefPort = _preferredPortByHost[host];
      final port = _effectivePort(uri);
      if (prefPort != null && prefPort > 0 && prefPort == port) {
        preferred.add(uri);
      } else {
        others.add(uri);
      }
    }
    return [...preferred, ...others];
  }

  void _recordSuccess(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host.isEmpty) return;
    final port = _effectivePort(uri);
    if (port > 0) _preferredPortByHost[host] = port;
  }

  int _effectivePort(Uri uri) {
    if (uri.hasPort) return uri.port;
    return switch (uri.scheme) {
      'wss' || 'https' => 443,
      'ws' || 'http' => 80,
      _ => 0,
    };
  }

  void _emit(ChatWsEvent event) {
    if (!_isDisposed && !_controller.isClosed) _controller.add(event);
  }

  String _maskUri(Uri uri) {
    final q = Map<String, String>.from(uri.queryParameters);
    if (q.containsKey('token')) q['token'] = '***';
    final base = '${uri.scheme}://${uri.authority}${uri.path}';
    if (q.isEmpty) return base;
    return '$base?${q.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[WS_CHAT][$conversationId] $message');
  }
}
