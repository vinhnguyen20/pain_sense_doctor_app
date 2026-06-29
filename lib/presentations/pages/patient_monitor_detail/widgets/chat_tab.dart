import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_providers.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/chats/presentation/widgets/message_input_bar.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatTab extends ConsumerStatefulWidget {
  final Patient patient;
  final String patientId;

  const ChatTab({super.key, required this.patient, required this.patientId});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  Conversation? _conversation;
  final TextEditingController _draftMessageController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmittingFirstMessage = false;
  String? _error;
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  String _resolveParticipantId() {
    final candidate = widget.patientId.trim();
    if (candidate.isNotEmpty && _uuidPattern.hasMatch(candidate)) {
      return candidate;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadConversation);
  }

  @override
  void dispose() {
    _draftMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final participantId = _resolveParticipantId();
    if (participantId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _conversation = null;
        _isLoading = false;
        _error = 'Patient id is missing from API response. Cannot open chat.';
      });
      return;
    }

    try {
      final conversation = await ref
          .read(conversationsProvider.notifier)
          .getConversationWithParticipant(participantId: participantId);

      if (!mounted) return;

      setState(() {
        _conversation = conversation;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _conversation = null;
        _isLoading = false;
        _error = ExceptionHandler.handle(error).message;
      });
    }
  }

  Future<void> _createConversationAndSendFirstMessage() async {
    if (_isSubmittingFirstMessage) return;

    final participantId = _resolveParticipantId();
    if (participantId.isEmpty) {
      setState(() {
        _error =
            'Patient id is missing from API response. Cannot send message.';
      });
      return;
    }

    final text = _draftMessageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingFirstMessage = true;
      _error = null;
    });

    final conversation = await ref
        .read(conversationsProvider.notifier)
        .createConversationAndSendFirstMessage(
          participantId: participantId,
          firstMessage: text,
        );

    if (!mounted) return;

    if (conversation == null) {
      setState(() {
        _isSubmittingFirstMessage = false;
        _error =
            ref.read(conversationsProvider).error ??
            'Cannot create conversation and send message';
      });
      return;
    }

    _draftMessageController.clear();
    setState(() {
      _conversation = conversation;
      _isSubmittingFirstMessage = false;
      _error = null;
    });
  }

  Widget _buildPreConversationComposer(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: AppInsets.screenHorizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 48,
                  color: context.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'No conversation with this patient yet',
                  style: context.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Type a message and tap Send to create the conversation and send the first message.',
                  style: context.bodySmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isSubmittingFirstMessage) ...[
                  const SizedBox(height: AppSpacing.s16),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.s14),
                  Text(
                    _error!,
                    style: context.bodySmall?.copyWith(color: context.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        MessageInputBar(
          controller: _draftMessageController,
          onSend: _createConversationAndSendFirstMessage,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final scheduleBox = _ScheduleAppointmentBox(patientId: widget.patientId);

    if (_conversation == null) {
      return Column(
        children: [
          Expanded(child: _buildPreConversationComposer(context)),
          scheduleBox,
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ChatRoomPage(
            conversation: _conversation!,
            embedded: true,
            patient: widget.patient,
          ),
        ),
        scheduleBox,
      ],
    );
  }
}

class _ScheduleAppointmentBox extends ConsumerStatefulWidget {
  final String patientId;

  const _ScheduleAppointmentBox({required this.patientId});

  @override
  ConsumerState<_ScheduleAppointmentBox> createState() =>
      _ScheduleAppointmentBoxState();
}

class _ScheduleAppointmentBoxState
    extends ConsumerState<_ScheduleAppointmentBox> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      ref
          .read(appointmentsByPatientProvider(widget.patientId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentsByPatientProvider(widget.patientId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.12),
                    borderRadius: AppCorners.r8,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 14,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  'Appointments',
                  style: context.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) =>
                        _ScheduleAppointmentDialog(patientId: widget.patientId),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 13,
                          color: context.primary,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          'Schedule',
                          style: context.labelMedium?.copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s12),

            if (state.isLoading && state.appointments.isEmpty)
              const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (state.error != null && state.appointments.isEmpty)
              Text(
                'Could not load appointments',
                style: context.labelMedium?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.4),
                ),
              )
            else if (state.appointments.isEmpty)
              Text(
                'No appointments yet',
                style: context.labelMedium?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.4),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount:
                      state.appointments.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.s10),
                  itemBuilder: (_, i) {
                    if (i == state.appointments.length) {
                      return const SizedBox(
                        width: 48,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return _AppointmentCard(
                      appointment: state.appointments[i],
                      patientId: widget.patientId,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.appointment, required this.patientId});

  final Appointment appointment;
  final String patientId;

  void _openEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ScheduleAppointmentDialog(
        patientId: patientId,
        initialAppointment: appointment,
      ),
    );
  }

  static const _typeColors = {
    AppointmentType.videoCall: (
      bg: Color(0xFFE6F1FB),
      text: Color(0xFF185FA5),
      label: 'Meeting',
    ),
    AppointmentType.inPerson: (
      bg: Color(0xFFEAF3DE),
      text: Color(0xFF3B6D11),
      label: 'In person',
    ),
  };

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete appointment?'),
        content: Text('Remove "${appointment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final response = await ref
          .read(deleteAppointmentUseCaseProvider)
          .call(appointment.id);

      if (response.isSuccess) {
        ref.invalidate(appointmentsByPatientProvider(patientId));
      } else if (context.mounted) {
        AppSnackbar.error(context, response.message);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, ExceptionHandler.handle(e).message);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeStyle =
        _typeColors[appointment.type] ??
        _typeColors[AppointmentType.videoCall]!;

    final hasLink =
        appointment.type == AppointmentType.videoCall &&
        (appointment.meetingLink ?? '').isNotEmpty;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: AppCorners.r10,
        border: Border.all(color: context.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeStyle.bg,
                  borderRadius: AppCorners.r20,
                ),
                child: Text(
                  typeStyle.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: typeStyle.text,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  '${appointment.schedule.startTime} – ${appointment.schedule.endTime}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.labelMedium?.copyWith(
                    fontSize: 11,
                    color: context.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              GestureDetector(
                onTap: () => _openEdit(context),
                child: Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: context.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: AppSpacing.s6),
              GestureDetector(
                onTap: () => _delete(context, ref),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: context.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),

          Text(
            appointment.title,
            style: context.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Row(
            children: [
              Text(
                _formatDate(appointment.schedule.date),
                style: context.labelMedium?.copyWith(
                  fontSize: 11,
                  color: context.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const Spacer(),
              if (hasLink)
                SizedBox(
                  height: 24,
                  child: ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(appointment.meetingLink ?? '');
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Join',
                      style: context.labelMedium?.copyWith(
                        color: context.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) => DateUtilsHelper.formatDateMonthAbbr(raw);
}

class _ScheduleAppointmentDialog extends ConsumerStatefulWidget {
  final String patientId;
  final Appointment? initialAppointment;

  const _ScheduleAppointmentDialog({
    required this.patientId,
    this.initialAppointment,
  });

  @override
  ConsumerState<_ScheduleAppointmentDialog> createState() =>
      _ScheduleAppointmentDialogState();
}

class _ScheduleAppointmentDialogState
    extends ConsumerState<_ScheduleAppointmentDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();

  String _type = 'video_call';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 30);
  bool _isSubmitting = false;
  String? _error;

  bool get _isEditing => widget.initialAppointment != null;

  static const _typeOptions = [
    ('video_call', 'Meeting', Icons.videocam_outlined),
    ('in_person', 'In Person', Icons.person_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final appt = widget.initialAppointment;
    if (appt != null) {
      _titleController.text = appt.title;
      _descriptionController.text = appt.description;
      _meetingLinkController.text = appt.meetingLink ?? '';
      _type = appt.type == AppointmentType.inPerson
          ? 'in_person'
          : 'video_call';
      try {
        _selectedDate = DateTime.parse(appt.schedule.date);
      } catch (_) {}
      _startTime = _parseTime(appt.schedule.startTime);
      _endTime = _parseTime(appt.schedule.endTime);
    }
  }

  TimeOfDay _parseTime(String hhmm) => DateUtilsHelper.parseTimeOfDay(
    hhmm,
    fallback: const TimeOfDay(hour: 9, minute: 0),
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => DateUtilsHelper.formatDateDMY(date);

  String _formatTime(TimeOfDay time) => DateUtilsHelper.formatTimeOfDay(time);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        final endMinutes = picked.hour * 60 + picked.minute + 30;
        _endTime = TimeOfDay(
          hour: (endMinutes ~/ 60) % 24,
          minute: endMinutes % 60,
        );
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  String get _formattedDate => DateUtilsHelper.formatDateApi(_selectedDate);

  Future<Map<String, dynamic>> _buildCreatePayload() async {
    final timezone = await getLocalTimezone();
    return {
      'patient_id': widget.patientId,
      'title': _titleController.text.trim(),
      'type': _type,
      'description': _descriptionController.text.trim(),
      'is_sent': true,
      'status': 'scheduled',
      'schedule': {
        'date': _formattedDate,
        'start_time': _formatTime(_startTime),
        'end_time': _formatTime(_endTime),
        'timezone': timezone,
      },
      'meeting_link': _meetingLinkController.text.trim().isNotEmpty
          ? _meetingLinkController.text.trim()
          : 'https://meet.google.com/default',
      'meeting_meta': {'access_token': 'default_token'},
    };
  }

  Future<Map<String, dynamic>> _buildUpdatePayload() async {
    final timezone = await getLocalTimezone();
    final appt = widget.initialAppointment!;
    return {
      'title': _titleController.text.trim(),
      'type': _type,
      'description': _descriptionController.text.trim(),
      'is_sent': true,
      'schedule': {
        'date': _formattedDate,
        'start_time': _formatTime(_startTime),
        'end_time': _formatTime(_endTime),
        'timezone': timezone,
      },
      'status': appt.status.toInt(),
      'meeting_link': _meetingLinkController.text.trim().isNotEmpty
          ? _meetingLinkController.text.trim()
          : null,
      'meeting_meta': {
        'access_token': appt.meetingMeta?.accessToken ?? 'default_token',
        'recording_url': appt.meetingMeta?.recordingUrl,
      },
    };
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a title.');
      return;
    }

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      setState(() => _error = 'End time must be after start time.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final ApiResponse<dynamic> response;

      if (_isEditing) {
        response = await ref
            .read(updateAppointmentUseCaseProvider)
            .call(widget.initialAppointment!.id, await _buildUpdatePayload());
      } else {
        response = await ref
            .read(createAppointmentUseCaseProvider)
            .call(await _buildCreatePayload());
      }

      if (!mounted) return;

      if (response.isSuccess) {
        ref.invalidate(appointmentsByPatientProvider(widget.patientId));
        if (context.mounted) {
          AppSnackbar.success(
            context,
            _isEditing
                ? 'Appointment updated successfully.'
                : 'Appointment scheduled successfully.',
          );
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() => _isSubmitting = false);
        if (context.mounted) {
          AppSnackbar.error(
            context,
            response.message.isNotEmpty
                ? response.message
                : 'Failed to save appointment.',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.error(context, ExceptionHandler.handle(e).message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s32,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppCorners.r16),
      backgroundColor: context.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.12),
                    borderRadius: AppCorners.r10,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: AppSize.iconSm,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Appointment' : 'Schedule Appointment',
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            const _FieldLabel('Title'),
            const SizedBox(height: AppSpacing.s6),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(context, 'e.g. Weekly check-in'),
            ),
            const SizedBox(height: AppSpacing.s16),

            const _FieldLabel('Type'),
            const SizedBox(height: AppSpacing.s8),
            Row(
              children: _typeOptions.map((opt) {
                final selected = _type == opt.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = opt.$1),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: opt.$1 != 'phone_call' ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s10,
                        horizontal: AppSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.primary.withValues(alpha: 0.1)
                            : context.background,
                        borderRadius: AppCorners.r10,
                        border: Border.all(
                          color: selected ? context.primary : context.border,
                          width: selected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt.$3,
                            size: 18,
                            color: selected
                                ? context.primary
                                : context.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            opt.$2,
                            style: context.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? context.primary
                                  : context.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.s16),

            const _FieldLabel('Date & Time'),
            const SizedBox(height: AppSpacing.s8),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _TappableField(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(_selectedDate),
                    onTap: _pickDate,
                    context: context,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  flex: 3,
                  child: _TappableField(
                    icon: Icons.access_time_rounded,
                    label: _formatTime(_startTime),
                    onTap: _pickStartTime,
                    context: context,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s6,
                  ),
                  child: Text(
                    '–',
                    style: context.bodyMedium?.copyWith(
                      color: context.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _TappableField(
                    icon: Icons.access_time_rounded,
                    label: _formatTime(_endTime),
                    onTap: _pickEndTime,
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            if (_type == 'video_call') ...[
              const _FieldLabel('Meeting link (optional)'),
              const SizedBox(height: AppSpacing.s6),
              TextField(
                controller: _meetingLinkController,
                decoration: _inputDecoration(
                  context,
                  'https://meet.google.com/...',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            const _FieldLabel('Note (optional)'),
            const SizedBox(height: AppSpacing.s6),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration(context, 'Add a note...'),
              maxLines: 3,
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                _error!,
                style: context.labelMedium?.copyWith(color: context.error),
              ),
            ],

            const SizedBox(height: AppSpacing.s20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppCorners.r10,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppPalette.white,
                        ),
                      )
                    : Text(
                        _isEditing
                            ? 'Update Appointment'
                            : 'Confirm Appointment',
                        style: context.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: context.onSurface.withValues(alpha: 0.35),
        fontSize: 13,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      filled: true,
      fillColor: context.background,
      border: OutlineInputBorder(
        borderRadius: AppCorners.r10,
        borderSide: BorderSide(color: context.border, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppCorners.r10,
        borderSide: BorderSide(color: context.border, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppCorners.r10,
        borderSide: BorderSide(color: context.primary, width: 1.2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _TappableField extends StatelessWidget {
  const _TappableField({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.context,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: AppCorners.r10,
          border: Border.all(color: context.border, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: context.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(width: AppSpacing.s6),
            Flexible(
              child: Text(
                label,
                style: context.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
