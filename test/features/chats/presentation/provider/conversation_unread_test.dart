import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/last_message.dart';
import 'package:app_doctor/features/chats/domain/entites/un_read_info.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveDoctorUnreadCount', () {
    test('counts unread when the latest message is from the patient', () {
      final conversation = _conversation(
        doctorCount: 4,
        lastSenderId: 'patient-1',
      );

      expect(
        resolveDoctorUnreadCount(
          conversation,
          currentUserIds: const ['doctor-1'],
          knownPatientIds: const ['patient-1'],
        ),
        4,
      );
    });

    test('does not count a message sent by the doctor', () {
      final conversation = _conversation(
        doctorCount: 4,
        lastSenderId: 'doctor-1',
        unreadInfo: const [UnReadInfo(userId: 'patient-1', count: 8)],
      );

      expect(
        resolveDoctorUnreadCount(
          conversation,
          currentUserIds: const ['doctor-1'],
          knownPatientIds: const ['patient-1'],
        ),
        0,
      );
    });

    test(
      'counts an incoming chat sender even when its id differs from patient id',
      () {
        final conversation = _conversation(
          doctorCount: 1,
          lastSenderId: 'chat-patient-user-42',
        );

        expect(
          resolveDoctorUnreadCount(
            conversation,
            currentUserIds: const ['doctor-1', 'ws-doctor-1'],
            knownPatientIds: const ['patient-1'],
          ),
          1,
        );
      },
    );

    test('fallback unread info counts only the patient entry', () {
      final conversation = _conversation(
        lastSenderId: 'patient-1',
        unreadInfo: const [
          UnReadInfo(userId: 'patient-1', count: 7),
          UnReadInfo(userId: 'chat-doctor', count: 2),
        ],
      );

      expect(resolveDoctorUnreadCount(conversation, patientId: 'PATIENT-1'), 7);
    });
  });
}

Conversation _conversation({
  int doctorCount = 0,
  String? lastSenderId,
  List<UnReadInfo> unreadInfo = const [],
}) {
  return Conversation(
    id: 'conversation-1',
    participants: const ['patient-1'],
    name: 'Patient',
    lastMessage: lastSenderId == null
        ? null
        : LastMessage(
            text: 'Message',
            sentAt: DateTime.utc(2026, 8, 23),
            sendBy: lastSenderId,
          ),
    status: 'active',
    unreadCountDoctor: doctorCount,
    unreadCountPatient: 0,
    unreadInfo: unreadInfo,
  );
}
