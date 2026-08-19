import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';

class PatientConnectHeader extends StatelessWidget {
  final Patient? patient;
  final VoidCallback? onBack;
  final bool showBackButton;

  const PatientConnectHeader({
    super.key,
    required this.patient,
    this.onBack,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: onBack ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppPalette.secondaryBlue,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 20),
          ],
          const PatientConnectAvatar(size: 80),
          const SizedBox(width: 40),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient?.fullName.isNotEmpty == true
                    ? patient!.fullName
                    : 'Patient',
                style: AppTypography.titleBig1.copyWith(
                  color: AppPalette.secondaryBlue,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                patient?.phone?.trim().isNotEmpty == true
                    ? patient!.phone!
                    : 'No phone number',
                style: AppTypography.defaultBody2.copyWith(
                  color: AppPalette.secondaryBlue,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PatientConnectAvatar extends StatelessWidget {
  final double size;
  final String asset;

  const PatientConnectAvatar({
    super.key,
    required this.size,
    this.asset = 'assets/images/avatar/avatar.png',
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
