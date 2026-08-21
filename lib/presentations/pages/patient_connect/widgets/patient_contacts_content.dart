import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class PatientContactsContent extends StatelessWidget {
  const PatientContactsContent({super.key});

  static const contacts = [
    ClinicianContactData(
      name: 'Dr. Cameron Taylor',
      specialty: 'Chiropractor',
      phone: '555-204-7890',
      email: 'CTchiro@gmail.com',
      avatarAsset: 'assets/images/avatar/Cameron Taylor.png',
    ),
    ClinicianContactData(
      name: 'Dr. Simone Green',
      specialty: 'Physiotherapist',
      phone: '555-123-4567',
      email: 'GreenPhysio@gmail.com',
      avatarAsset: 'assets/images/avatar/Simone Green.png',
    ),
    ClinicianContactData(
      name: 'Dr. Sarah Morgan',
      specialty: 'Orthopedist',
      phone: '555-292-0980',
      email: 'SMorganOrtho@gmail.com',
      avatarAsset: 'assets/images/avatar/Sarah Morgan.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (context.isCompactShell) {
      return Column(
        children: [
          for (var index = 0; index < contacts.length; index++) ...[
            ClinicianContactCard(data: contacts[index]),
            if (index != contacts.length - 1)
              const SizedBox(height: AppSpacing.s12),
          ],
          const SizedBox(height: AppSpacing.s20),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < contacts.length; index++) ...[
          ClinicianContactCard(data: contacts[index]),
          if (index != contacts.length - 1) const SizedBox(width: 55),
        ],
      ],
    );
  }
}

class ClinicianContactData {
  final String name;
  final String specialty;
  final String phone;
  final String email;
  final String avatarAsset;

  const ClinicianContactData({
    required this.name,
    required this.specialty,
    required this.phone,
    required this.email,
    required this.avatarAsset,
  });
}

class ClinicianContactCard extends StatelessWidget {
  final ClinicianContactData data;

  const ClinicianContactCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isCompactShell ? double.infinity : 280,
      height: context.isCompactShell ? null : 398,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ContactAvatar(
            asset: data.avatarAsset,
            size: context.isCompactShell ? 120 : 200,
          ),
          const SizedBox(height: 24),
          Text(
            data.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall1.copyWith(
              color: AppPalette.secondaryBlue,
              height: 1,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            data.specialty,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.defaultBody2.copyWith(
              color: AppPalette.secondaryBlue,
              height: 1,
            ),
          ),
          const SizedBox(height: 44),
          Text(
            data.phone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall1.copyWith(
              color: AppPalette.secondaryBlue,
              height: 1,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            data.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall1.copyWith(
              color: AppPalette.secondaryBlue,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String asset;
  final double size;

  const _ContactAvatar({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
