import 'package:go_router/go_router.dart';

import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';

class PatientAppointmentsPage extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientAppointmentsPage({super.key, required this.patient});

  @override
  ConsumerState<PatientAppointmentsPage> createState() =>
      _PatientAppointmentsPageState();
}

class PatientAppointmentsContent extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientAppointmentsContent({
    super.key,
    required this.patient,
  });

  @override
  ConsumerState<PatientAppointmentsContent> createState() =>
      _PatientAppointmentsContentState();
}

class _PatientAppointmentsContentState
    extends ConsumerState<PatientAppointmentsContent> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(
      appointmentsByPatientProvider(widget.patient.id),
    );

    return _showCreateForm
        ? _CreateAppointmentForm(
            patient: widget.patient,
            onCreated: () async {
              await ref
                  .read(
                    appointmentsByPatientProvider(
                      widget.patient.id,
                    ).notifier,
                  )
                  .refresh();

              if (!mounted) return;
              setState(() => _showCreateForm = false);
            },
            onCancel: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _showCreateForm = false);
            },
          )
        : _PatientScheduleContent(
            state: appointmentState,
            onCreateAppointment: () {
              setState(() => _showCreateForm = true);
            },
            onRefresh: () => ref
                .read(
                  appointmentsByPatientProvider(
                    widget.patient.id,
                  ).notifier,
                )
                .refresh(),
          );
  }
}

class _PatientAppointmentsPageState
    extends ConsumerState<PatientAppointmentsPage> {
  bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final doctorName = userState.user?.lastName != null ? 'Dr. ${userState.user!.lastName}' : 'Doctor';
    final appointmentState = ref.watch(
      appointmentsByPatientProvider(widget.patient.id),
    );

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 1208
                ? 1208.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClinicianHeader(doctorName: doctorName),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              context.goNamed('appointments');
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16.0, top: 4, bottom: 4),
                              child: Icon(Icons.arrow_back, color: AppPalette.secondaryBlue, size: 28),
                            ),
                          ),
                          Text(
                            widget.patient.fullName.trim().isEmpty
                                ? 'Patient Schedule'
                                : widget.patient.fullName.trim(),
                            style: AppTypography.titleBig1.copyWith(
                              color: AppPalette.secondaryBlue,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: _showCreateForm
                            ? _CreateAppointmentForm(
                                patient: widget.patient,
                                onCreated: () async {
                                  await ref
                                      .read(
                                        appointmentsByPatientProvider(
                                          widget.patient.id,
                                        ).notifier,
                                      )
                                      .refresh();

                                  if (!mounted) return;

                                  setState(() {
                                    _showCreateForm = false;
                                  });
                                },
                                onCancel: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    _showCreateForm = false;
                                  });
                                },
                              )
                            : _PatientScheduleContent(
                                state: appointmentState,
                                onCreateAppointment: () {
                                  setState(() {
                                    _showCreateForm = true;
                                  });
                                },
                                onRefresh: () => ref
                                    .read(
                                      appointmentsByPatientProvider(
                                        widget.patient.id,
                                      ).notifier,
                                    )
                                    .refresh(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatientScheduleContent extends StatelessWidget {
  final AppointmentState state;
  final VoidCallback onCreateAppointment;
  final Future<void> Function() onRefresh;

  const _PatientScheduleContent({
    required this.state,
    required this.onCreateAppointment,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final datedAppointments =
        state.appointments
            .where(
              (appointment) =>
                  appointment.status != AppointmentStatus.cancelled,
            )
            .map(
              (appointment) => _DatedAppointment(
                appointment: appointment,
                dateTime: _appointmentDateTime(appointment),
              ),
            )
            .where((item) => item.dateTime != null)
            .toList()
          ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    final now = DateTime.now();

    Appointment? lastAppointment;
    Appointment? nextAppointment;

    for (final item in datedAppointments) {
      if (item.dateTime!.isBefore(now)) {
        lastAppointment = item.appointment;
      } else {
        nextAppointment ??= item.appointment;
      }
    }

    final upcoming = datedAppointments
        .where((item) => !_dateOnly(item.dateTime!).isBefore(_dateOnly(now)))
        .map((item) => item.appointment)
        .toList();

    final sections = <Widget>[];

    if (state.isLoading && state.appointments.isEmpty) {
      sections.add(
        const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(
            child: CircularProgressIndicator(color: AppPalette.secondaryBlue),
          ),
        ),
      );
    } else if (state.error != null && state.appointments.isEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: _PrimaryButton(label: 'Retry', width: 136, onTap: onRefresh),
          ),
        ),
      );
    } else if (upcoming.isEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 90),
          child: Center(
            child: Text(
              'No upcoming appointments.',
              style: _title20(AppPalette.primaryBlue),
            ),
          ),
        ),
      );
    } else {
      final groups = _groupAppointments(upcoming);
      for (final group in groups) {
        sections.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(group.label, style: _title20(AppPalette.secondaryBlue)),
          ),
        );
        sections.add(const SizedBox(height: 10));
        
        for (var i = 0; i < group.appointments.length; i++) {
          sections.add(
            _ScheduleCard(appointment: group.appointments[i]),
          );
          if (i < group.appointments.length - 1) {
            sections.add(const SizedBox(height: 10));
          }
        }
        sections.add(const SizedBox(height: 10));
      }
    }

    return SizedBox(
      width: 1148,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 43, bottom: 30),
          children: [
            _AppointmentTimeline(
              appointments: state.appointments,
              lastAppointment: lastAppointment,
              nextAppointment: nextAppointment,
            ),
            const SizedBox(height: 23),
            Center(
              child: _PrimaryButton(
                label: 'Create An Appointment',
                width: 270,
                onTap: onCreateAppointment,
              ),
            ),
            const SizedBox(height: 23),
            ...sections,
          ],
        ),
      ),
    );
  }
}

class _AppointmentTimeline extends StatelessWidget {
  final List<Appointment> appointments;
  final Appointment? lastAppointment;
  final Appointment? nextAppointment;

  const _AppointmentTimeline({
    required this.appointments,
    required this.lastAppointment,
    required this.nextAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));
    final days = List.generate(13, (index) => start.add(Duration(days: index)));

    final appointmentDays = appointments
        .where(
          (appointment) => appointment.status != AppointmentStatus.cancelled,
        )
        .map(_appointmentDateTime)
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet();

    return SizedBox(
      width: 586,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 443.522,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 46.553,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: days.map((day) {
                      final isToday = _sameDay(day, today);
                      final hasAppointment = appointmentDays.any(
                        (appointmentDate) => _sameDay(appointmentDate, day),
                      );

                      final height = isToday
                          ? 38.089
                          : hasAppointment
                          ? 46.553
                          : 16.928;

                      final color = isToday
                          ? AppPalette.cyan
                          : hasAppointment
                          ? AppPalette.secondaryBlue
                          : AppPalette.backgroundLight;

                      return Container(
                        width: 16.928,
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(41.474),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 5.078),
                SizedBox(
                  height: 13,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: days
                        .map(
                          (day) => SizedBox(
                            width: 16.928,
                            child: Text(
                              _weekdayLetter(day),
                              textAlign: TextAlign.center,
                              style: AppTypography.captionBody2.copyWith(
                                color: AppPalette.primaryBlue,
                                height: 1,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 41,
            child: Row(
              children: [
                Expanded(
                  child: _AppointmentDateLabel(
                    appointment: lastAppointment,
                    caption: 'Last Appt.',
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Today',
                      style: _title20(AppPalette.secondaryBlue),
                    ),
                  ),
                ),
                Expanded(
                  child: _AppointmentDateLabel(
                    appointment: nextAppointment,
                    caption: 'Next Appt.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDateLabel extends StatelessWidget {
  final Appointment? appointment;
  final String caption;

  const _AppointmentDateLabel({
    required this.appointment,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final date = appointment == null
        ? null
        : _appointmentDateTime(appointment!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          date == null ? '—' : _monthDay(date),
          style: _title20(AppPalette.secondaryBlue),
        ),
        Text(
          caption,
          style: AppTypography.defaultBody2.copyWith(
            color: AppPalette.primaryBlue,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Appointment appointment;

  const _ScheduleCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final date = _appointmentDateTime(appointment);
    final title = appointment.title.trim().isEmpty
        ? 'Appointment'
        : appointment.title.trim();
    final doctor = appointment.doctorName.trim().isEmpty
        ? 'Doctor'
        : appointment.doctorName.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _title20(AppPalette.secondaryBlue)),
                    const SizedBox(height: 9),
                    Text(
                      doctor,
                      style: AppTypography.titleBig2.copyWith(
                        color: AppPalette.secondaryBlue,
                        height: 1,
                      ),
                    ),
                    if (appointment.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        appointment.description.trim(),
                        style: AppTypography.titleBig2.copyWith(
                          color: AppPalette.secondaryBlue,
                          fontStyle: FontStyle.italic,
                          height: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _appointmentTypeLabel(appointment.type),
                      textAlign: TextAlign.right,
                      style: _title20(AppPalette.secondaryBlue),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      date == null ? '—' : _yyyyMmDd(date),
                      textAlign: TextAlign.right,
                      style: _title20(AppPalette.secondaryBlue),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _timeRange(
                        appointment.schedule.startTime,
                        appointment.schedule.endTime,
                      ),
                      textAlign: TextAlign.right,
                      style: _title20(AppPalette.secondaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrimaryButton(
                label: 'Message',
                width: 240,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Messaging from Schedule is not connected yet.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              _PrimaryButton(
                label: appointment.type == AppointmentType.videoCall
                    ? 'Join Call'
                    : 'View Details',
                width: 240,
                onTap: () {
                  final hasLink =
                      appointment.meetingLink?.trim().isNotEmpty == true;

                  final message = appointment.type == AppointmentType.videoCall
                      ? hasLink
                            ? 'Meeting link is available.'
                            : 'No meeting link is available yet.'
                      : 'In-person appointment.';

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateAppointmentForm extends ConsumerStatefulWidget {
  final Patient patient;
  final Future<void> Function() onCreated;
  final VoidCallback onCancel;

  const _CreateAppointmentForm({
    required this.patient,
    required this.onCreated,
    required this.onCancel,
  });

  @override
  ConsumerState<_CreateAppointmentForm> createState() =>
      _CreateAppointmentFormState();
}

class _CreateAppointmentFormState
    extends ConsumerState<_CreateAppointmentForm> {
  final TextEditingController _notesController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  AppointmentType _type = AppointmentType.videoCall;
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1148,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(top: 43, bottom: 23),
              child: Column(
                children: [
                  Text(
                    'Appointment Date & Time',
                    style: _title20(AppPalette.secondaryBlue),
                  ),
                  const SizedBox(height: 23),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PickerField(
                        width: 200,
                        label: _date == null ? 'Date...' : _yyyyMmDd(_date!),
                        onTap: _pickDate,
                      ),
                      const SizedBox(width: 23),
                      _PickerField(
                        width: 200,
                        label: _time == null ? 'Time...' : _formatTime(_time!),
                        onTap: _pickTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  Text(
                    'Appointment Type',
                    style: _title20(AppPalette.secondaryBlue),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TypeButton(
                        label: 'Video',
                        selected: _type == AppointmentType.videoCall,
                        onTap: () {
                          setState(() {
                            _type = AppointmentType.videoCall;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      _TypeButton(
                        label: 'In-Person',
                        selected: _type == AppointmentType.inPerson,
                        onTap: () {
                          setState(() {
                            _type = AppointmentType.inPerson;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      const _TypeButton(
                        label: 'Exercise Demonstration',
                        selected: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  Text(
                    'Reason For Appointment',
                    style: _title20(AppPalette.secondaryBlue),
                  ),
                  const SizedBox(height: 23),
                  Container(
                    width: 1068,
                    height: 106,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.backgroundLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _notesController,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      cursorColor: AppPalette.secondaryBlue,
                      style: _title20(AppPalette.secondaryBlue),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Appointment Notes...',
                        hintStyle: _title20(AppPalette.medGray),
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _PrimaryButton(
              label: 'Create Appointment',
              width: 240,
              loading: _submitting,
              onTap: _submitting ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _date = picked;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _time = picked;
    });
  }

  Future<void> _submit() async {
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a date and time first.')),
      );

      return;
    }

    setState(() {
      _submitting = true;
    });

    final startMinutes = _time!.hour * 60 + _time!.minute;
    final endMinutes = startMinutes + 60;
    final endTime = TimeOfDay(
      hour: (endMinutes ~/ 60) % 24,
      minute: endMinutes % 60,
    );

    final patientName = widget.patient.fullName.trim().isEmpty
        ? 'Patient'
        : widget.patient.fullName.trim();

    final payload = <String, dynamic>{
      'patient_id': widget.patient.id,
      'title': 'Appointment with $patientName',
      'type': _type == AppointmentType.videoCall ? 'video_call' : 'in_person',
      'description': _notesController.text.trim(),
      'is_sent': false,
      'schedule': {
        'date': _apiDate(_date!),
        'start_time': _apiTime(_time!),
        'end_time': _apiTime(endTime),
        'timezone': 'Asia/Ho_Chi_Minh',
      },
      'status': 'scheduled',
      'meeting_link': '',
      'meeting_meta': {'access_token': '', 'recording_url': ''},
    };

    try {
      final response = await ref.read(createAppointmentUseCaseProvider)(
        payload,
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment created.')));

        await widget.onCreated();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Unable to create appointment.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create appointment.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _PickerField extends StatelessWidget {
  final double width;
  final String label;
  final VoidCallback onTap;

  const _PickerField({
    required this.width,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.backgroundLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: _title20(
                  label.endsWith('...')
                      ? AppPalette.medGray
                      : AppPalette.secondaryBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TypeButton({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.secondaryBlue : AppPalette.backgroundLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Text(
            label,
            style: _title20(selected ? AppPalette.white : AppPalette.medGray),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final double width;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.width,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.secondaryBlue,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          height: 50,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPalette.white,
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: _title20(AppPalette.white),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final double width;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.backgroundLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          height: 50,
          child: Center(
            child: Text(label, style: _title20(AppPalette.secondaryBlue)),
          ),
        ),
      ),
    );
  }
}

class _DatedAppointment {
  final Appointment appointment;
  final DateTime? dateTime;

  const _DatedAppointment({required this.appointment, required this.dateTime});
}

class _AppointmentGroup {
  final String label;
  final List<Appointment> appointments;

  const _AppointmentGroup({required this.label, required this.appointments});
}

List<_AppointmentGroup> _groupAppointments(List<Appointment> appointments) {
  final sorted = [...appointments]
    ..sort((a, b) {
      final aDate = _appointmentDateTime(a);
      final bDate = _appointmentDateTime(b);

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return aDate.compareTo(bDate);
    });

  final today = _dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  final order = <String>[];
  final map = <String, List<Appointment>>{};
  final labels = <String, String>{};

  for (final appointment in sorted) {
    final date = _appointmentDateTime(appointment);

    if (date == null) continue;

    final day = _dateOnly(date);
    final key = _apiDate(day);

    if (!map.containsKey(key)) {
      order.add(key);
    }

    if (_sameDay(day, today)) {
      labels[key] = 'Today';
    } else if (_sameDay(day, tomorrow)) {
      labels[key] = 'Tomorrow';
    } else {
      labels[key] = _monthDayLong(day);
    }

    map.putIfAbsent(key, () => []).add(appointment);
  }

  return order
      .map(
        (key) => _AppointmentGroup(
          label: labels[key] ?? key,
          appointments: map[key] ?? const [],
        ),
      )
      .toList();
}

DateTime? _appointmentDateTime(Appointment appointment) {
  final dateText = appointment.schedule.date.trim().replaceAll('/', '-');

  final date = DateTime.tryParse(dateText);

  if (date == null) return null;

  final time = _parseTimeString(appointment.schedule.startTime);

  if (time == null) return date;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

TimeOfDay? _parseTimeString(String value) {
  final input = value.trim();

  if (input.isEmpty) return null;

  final twelveHour = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(input);

  if (twelveHour != null) {
    var hour = int.tryParse(twelveHour.group(1)!);

    final minute = int.tryParse(twelveHour.group(2)!);

    final suffix = twelveHour.group(3)!.toUpperCase();

    if (hour == null || minute == null) return null;

    if (suffix == 'PM' && hour != 12) {
      hour += 12;
    }

    if (suffix == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  final parts = input.split(':');

  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));

  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

String _timeRange(String start, String end) {
  final startTime = _parseTimeString(start);
  final endTime = _parseTimeString(end);

  if (startTime == null || endTime == null) {
    final rawStart = start.trim();
    final rawEnd = end.trim();

    if (rawStart.isEmpty && rawEnd.isEmpty) {
      return '—';
    }

    if (rawEnd.isEmpty) {
      return rawStart;
    }

    return '$rawStart-$rawEnd';
  }

  final startParts = _formatTimeParts(startTime);
  final endParts = _formatTimeParts(endTime);

  if (startParts.suffix == endParts.suffix) {
    return '${startParts.clock}-${endParts.clock} ${endParts.suffix}';
  }

  return '${startParts.clock} ${startParts.suffix}-${endParts.clock} ${endParts.suffix}';
}

({String clock, String suffix}) _formatTimeParts(TimeOfDay time) {
  final suffix = time.hour >= 12 ? 'PM' : 'AM';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');

  return (clock: '$hour:$minute', suffix: suffix);
}

String _formatTime(TimeOfDay time) {
  final parts = _formatTimeParts(time);

  return '${parts.clock} ${parts.suffix}';
}

String _appointmentTypeLabel(AppointmentType type) {
  switch (type) {
    case AppointmentType.videoCall:
      return 'Video Call';
    case AppointmentType.inPerson:
      return 'In-Person';
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _weekdayLetter(DateTime date) {
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  return labels[date.weekday - 1];
}

String _monthDay(DateTime date) {
  const months = [
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

  return '${months[date.month - 1]} ${date.day}';
}

String _monthDayLong(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[date.month - 1]} ${date.day}';
}

String _yyyyMmDd(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}/$month/$day';
}

String _apiDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}

String _apiTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute:00.000Z';
}

TextStyle _title20(Color color) {
  return AppTypography.titleBig1.copyWith(
    color: color,
    height: 1,
    letterSpacing: 0,
  );
}
