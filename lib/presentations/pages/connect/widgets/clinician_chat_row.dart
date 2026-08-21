import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';

class ClinicianChatRow extends StatelessWidget {
  final Patient patient;
  final Conversation? conversation;
  final VoidCallback? onChat;

  const ClinicianChatRow({
    super.key,
    required this.patient,
    this.conversation,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final name = patient.fullName.isEmpty
        ? 'Unnamed patient'
        : patient.fullName;
    final message = conversation?.lastMessage?.text.trim();
    final messageText = message == null || message.isEmpty
        ? 'No recent message'
        : message;
    final textStyle = AppTypography.defaultBody2.copyWith(height: 1);

    if (context.isCompactShell) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppCorners.r20,
        child: InkWell(
          onTap: onChat,
          borderRadius: AppCorners.r20,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: const BoxDecoration(
              color: AppPalette.surfaceLight,
              borderRadius: AppCorners.r20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppPalette.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleBig1.copyWith(
                          color: AppPalette.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s10),
                Text(
                  messageText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle.copyWith(color: AppPalette.black),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  patient.phone?.trim().isNotEmpty == true
                      ? patient.phone!
                      : 'No phone number',
                  style: textStyle.copyWith(color: AppPalette.secondaryBlue),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  patient.email?.trim().isNotEmpty == true
                      ? patient.email!
                      : 'No email address',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle.copyWith(color: AppPalette.secondaryBlue),
                ),
                const SizedBox(height: AppSpacing.s14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onChat,
                    child: const Text('Chat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onChat,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppPalette.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppPalette.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleBig1.copyWith(
                        color: AppPalette.secondaryBlue,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      messageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(color: AppPalette.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.phone?.trim().isNotEmpty == true
                          ? patient.phone!
                          : 'No phone number',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      patient.email?.trim().isNotEmpty == true
                          ? patient.email!
                          : 'No email address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 88,
                height: 50,
                child: TextButton(
                  onPressed: onChat,
                  style: TextButton.styleFrom(
                    backgroundColor: AppPalette.white,
                    foregroundColor: AppPalette.secondaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Chat',
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppPalette.secondaryBlue,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
