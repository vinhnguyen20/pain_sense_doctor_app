import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
int? getLbpScore(String? lbpScore) {
  if (lbpScore == null || lbpScore.isEmpty || lbpScore == 'N/A') {
    return 0;
  }

  final parts = lbpScore.split('/');
  final score = int.tryParse(parts.first);

  if (score == null || score < 0) return null;

  return score;
}

String monthAbbr(int month) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month];
}

Color colorFromHex(String? hex, {Color fallback = Colors.grey}) {
  if (hex == null) return fallback;
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return fallback;
  return cleaned.length == 6 ? Color(0xFF000000 | value) : Color(value);
}

Future<String> getLocalTimezone() async {
  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    return timezoneInfo.identifier;
  } catch (_) {
    return 'Asia/Ho_Chi_Minh';
  }
}
