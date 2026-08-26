import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';

class PatientDetailDialog extends StatelessWidget {
  final String patientId;
  final Patient? initialPatient;

  const PatientDetailDialog({
    super.key,
    required this.patientId,
    this.initialPatient,
  });

  @override
  Widget build(BuildContext context) {
    final patient = initialPatient;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
          child: Container(
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  _buildHeader(context, patient),

                  // Dialog Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: patient != null
                          ? _buildPatientDetails(context, patient)
                          : _buildUnavailableView(context),
                    ),
                  ),

                  // Dialog Footer
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Patient? patient) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        border: Border(
          bottom: BorderSide(color: AppPalette.medGray, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/avatar/avatar.png',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  patient?.fullName.isNotEmpty == true
                      ? patient!.fullName
                      : 'Patient Details',
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppPalette.secondaryBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusChip(patient?.status),
                    if (patient?.painType != null &&
                        patient!.painType!.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildPainTypeChip(patient.painType!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: context.onSurface.withValues(alpha: 0.6),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(UserStatus? status) {
    final isOnlineOrActive = status == UserStatus.active;
    final label = status != null ? status.name.toUpperCase() : 'ACTIVE';
    final color = isOnlineOrActive ? AppPalette.green : AppPalette.medGray;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOnlineOrActive
                  ? const Color(0xFF2E7D32)
                  : AppPalette.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainTypeChip(String painType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppPalette.secondaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        painType,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppPalette.secondaryBlue,
        ),
      ),
    );
  }

  Widget _buildUnavailableView(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: context.error),
          const SizedBox(height: 12),
          Text(
            'Patient details are unavailable',
            style: AppTypography.titleSmall1.copyWith(color: context.error),
          ),
          const SizedBox(height: 8),
          Text(
            'Close this dialog and refresh the patient list.',
            style: AppTypography.defaultBody2.copyWith(
              color: context.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetails(BuildContext context, Patient patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Personal Information
        _buildSectionHeader('Personal Information', Icons.badge_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.cake_outlined,
                label: 'Age / Date of Birth',
                value: _formatAgeAndDob(patient),
              ),
              const Divider(
                height: 20,
                thickness: 0.5,
                color: AppPalette.medGray,
              ),
              _buildInfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Gender',
                value: _formatGender(patient.gender),
              ),
              const Divider(
                height: 20,
                thickness: 0.5,
                color: AppPalette.medGray,
              ),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: patient.phone?.trim().isNotEmpty == true
                    ? patient.phone!
                    : 'Not provided',
              ),
              const Divider(
                height: 20,
                thickness: 0.5,
                color: AppPalette.medGray,
              ),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email Address',
                value: patient.email?.trim().isNotEmpty == true
                    ? patient.email!
                    : 'Not provided',
              ),
              const Divider(
                height: 20,
                thickness: 0.5,
                color: AppPalette.medGray,
              ),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: patient.address?.trim().isNotEmpty == true
                    ? patient.address!
                    : 'Not provided',
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section: Emergency Contact
        if (patient.emergencyContact != null &&
            (patient.emergencyContact!.name.isNotEmpty ||
                patient.emergencyContact!.phone.isNotEmpty)) ...[
          _buildSectionHeader(
            'Emergency Contact',
            Icons.contact_phone_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Contact Name',
                  value: patient.emergencyContact!.name.isNotEmpty
                      ? patient.emergencyContact!.name
                      : 'Not provided',
                ),
                const Divider(
                  height: 20,
                  thickness: 0.5,
                  color: AppPalette.medGray,
                ),
                _buildInfoRow(
                  icon: Icons.phone_in_talk_outlined,
                  label: 'Contact Phone',
                  value: patient.emergencyContact!.phone.isNotEmpty
                      ? '${patient.emergencyContact!.countryCode} ${patient.emergencyContact!.phone}'
                            .trim()
                      : 'Not provided',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Section: Monitoring / Tracking Status
        if (patient.trackingLogs != null) ...[
          _buildSectionHeader(
            'Health & LBP Status',
            Icons.monitor_heart_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LBP Score',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppPalette.secondaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.trackingLogs?.lbpScore ?? 'N/A',
                        style: TextStyle(
                          fontFamily: 'Cabin',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorFromHex(patient.trackingLogs?.color),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorFromHex(
                      patient.trackingLogs?.color,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    patient.trackingLogs?.status ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: colorFromHex(patient.trackingLogs?.color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppPalette.secondaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cabin',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPalette.secondaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppPalette.secondaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.medGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        border: Border(top: BorderSide(color: AppPalette.medGray, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.secondaryBlue,
              foregroundColor: AppPalette.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAgeAndDob(Patient patient) {
    final ageStr = patient.age != null ? '${patient.age} years old' : '';
    final dobStr =
        patient.birthdate != null && patient.birthdate!.trim().isNotEmpty
        ? patient.birthdate!.trim()
        : '';
    if (ageStr.isNotEmpty && dobStr.isNotEmpty) {
      return '$ageStr ($dobStr)';
    }
    if (ageStr.isNotEmpty) return ageStr;
    if (dobStr.isNotEmpty) return dobStr;
    return 'Not provided';
  }

  String _formatGender(Gender? gender) {
    if (gender == null) return 'Not specified';
    return switch (gender) {
      Gender.male => 'Male',
      Gender.female => 'Female',
      Gender.other => 'Other',
    };
  }
}
