import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:app_doctor/presentations/pages/appointments/page/patient_appointments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared doctor schedule identifies each appointment by patient', (
    tester,
  ) async {
    var openedAppointmentId = '';
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    Appointment appointmentAt({
      required String id,
      required String title,
      required DateTime date,
    }) {
      final apiDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      return Appointment(
        id: id,
        title: title,
        description: 'Weekly review',
        patientId: 'patient-1',
        patientName: 'Bella Vu',
        doctorId: 'doctor-1',
        doctorName: 'Dr. Cameron Taylor',
        createdBy: 'doctor-1',
        type: AppointmentType.videoCall,
        status: AppointmentStatus.confirmed,
        isSent: true,
        schedule: AppointmentSchedule(
          date: apiDate,
          startTime: '14:30',
          endTime: '15:30',
          timezone: 'Asia/Ho_Chi_Minh',
        ),
      );
    }

    final appointment = appointmentAt(
      id: 'appointment-1',
      title: 'Guided Stretching Session',
      date: tomorrow,
    );
    final pastAppointment = appointmentAt(
      id: 'appointment-past',
      title: 'Past Appointment',
      date: today.subtract(const Duration(days: 1)),
    );
    final outsideRangeAppointment = appointmentAt(
      id: 'appointment-outside-range',
      title: 'Outside Range Appointment',
      date: today.add(const Duration(days: 7)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentScheduleContent(
            state: AppointmentState(
              appointments: [
                pastAppointment,
                appointment,
                outsideRangeAppointment,
              ],
            ),
            showPatientName: true,
            onCreateAppointment: () {},
            onRefresh: () async {},
            onOpenChat: (selected) async {
              openedAppointmentId = selected.id;
            },
          ),
        ),
      ),
    );

    expect(find.text('Create An Appointment'), findsOneWidget);
    expect(find.text('Bella Vu'), findsOneWidget);
    expect(find.text('Dr. Cameron Taylor'), findsNothing);
    expect(find.text('Guided Stretching Session'), findsOneWidget);
    expect(find.text('Past Appointment'), findsNothing);
    expect(find.text('Outside Range Appointment'), findsNothing);
    expect(find.text('Confirmed'), findsNothing);
    expect(find.text('Today'), findsNothing);
    final weekdayLabels = tester
        .widgetList<Text>(find.byType(Text))
        .where((text) => const {'M', 'T', 'W', 'F', 'S'}.contains(text.data));
    expect(weekdayLabels, hasLength(7));

    await tester.tap(find.text('Message'));
    expect(openedAppointmentId, 'appointment-1');
  });
}
