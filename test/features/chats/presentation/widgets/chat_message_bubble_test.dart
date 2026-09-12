import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/entites/message_content.dart';
import 'package:app_doctor/features/chats/presentation/widgets/chat_message_buble.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('doctor and patient messages use opposite sides', (tester) async {
    const patient = Patient(
      id: 'patient-1',
      firstName: 'Patient',
      lastName: 'Test',
    );
    final sentAt = DateTime(2026, 9, 12, 10);

    Message message(String id, String senderId, String text) => Message(
      id: id,
      conversationId: 'conversation-1',
      senderId: senderId,
      sentAt: sentAt,
      readByIds: const [],
      status: 'sent',
      type: 'text',
      content: MessageContent(text: text),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: Column(
                children: [
                  ChatMessageBubble(
                    key: const Key('patient-message'),
                    msg: message('1', 'PATIENT-1', 'From patient'),
                    currentUserIds: const {'doctor-1'},
                    currentRole: UserRole.doctor,
                    patient: patient,
                    compact: true,
                  ),
                  ChatMessageBubble(
                    key: const Key('doctor-message'),
                    msg: message('2', 'doctor-1', 'From doctor'),
                    currentUserIds: const {'DOCTOR-1'},
                    currentRole: UserRole.doctor,
                    patient: patient,
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final patientAlign = tester.widget<Align>(
      find.descendant(
        of: find.byKey(const Key('patient-message')),
        matching: find.byType(Align),
      ),
    );
    final doctorAlign = tester.widget<Align>(
      find.descendant(
        of: find.byKey(const Key('doctor-message')),
        matching: find.byType(Align),
      ),
    );

    expect(patientAlign.alignment, Alignment.centerLeft);
    expect(doctorAlign.alignment, Alignment.centerRight);
  });
}
