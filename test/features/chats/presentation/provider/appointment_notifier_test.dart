import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new appointment is available immediately in the shared schedule', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const appointment = Appointment(
      id: 'appointment-1',
      title: 'Appointment with Bella Vu',
      description: '',
      patientId: 'patient-1',
      patientName: 'Bella Vu',
      doctorId: 'doctor-1',
      doctorName: 'Doctor',
      createdBy: 'doctor-1',
      type: AppointmentType.videoCall,
      status: AppointmentStatus.confirmed,
      isSent: false,
      schedule: AppointmentSchedule(
        date: '2026-09-16',
        startTime: '10:30',
        endTime: '11:30',
        timezone: 'Asia/Ho_Chi_Minh',
      ),
    );

    container.read(appointmentProvider.notifier).upsertAppointment(appointment);

    expect(container.read(appointmentProvider).appointments, [appointment]);
  });
}
