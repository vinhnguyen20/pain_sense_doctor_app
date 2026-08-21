import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class ClinicianSettingsPage extends StatefulWidget {
  const ClinicianSettingsPage({super.key});

  @override
  State<ClinicianSettingsPage> createState() => _ClinicianSettingsPageState();
}

class _ClinicianSettingsPageState extends State<ClinicianSettingsPage> {
  bool _preferencesSelected = false;
  bool _darkMode = false;
  bool _largeText = false;
  bool _emails = false;
  bool _pushNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                context.isCompactShell || constraints.maxWidth < 600;
            final horizontalPadding = isCompact ? 16.0 : 22.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isCompact ? 16 : 30,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ClinicianHeader(doctorName: 'Dr. Cameron Taylor'),
                      if (!isCompact) ...[
                        const SizedBox(height: 30),
                        Text(
                          'Dr. Cameron Taylor',
                          style: AppTypography.titleBig1.copyWith(
                            color: AppPalette.secondaryBlue,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 34),
                      ] else
                        const SizedBox(height: 16),
                      _SettingsTabs(
                        preferencesSelected: _preferencesSelected,
                        onChanged: (value) =>
                            setState(() => _preferencesSelected = value),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 0 : 80,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _preferencesSelected
                              ? _PreferencesSettings(
                                  darkMode: _darkMode,
                                  largeText: _largeText,
                                  emails: _emails,
                                  pushNotifications: _pushNotifications,
                                  onDarkModeChanged: (value) =>
                                      setState(() => _darkMode = value),
                                  onLargeTextChanged: (value) =>
                                      setState(() => _largeText = value),
                                  onEmailsChanged: (value) =>
                                      setState(() => _emails = value),
                                  onPushNotificationsChanged: (value) =>
                                      setState(
                                        () => _pushNotifications = value,
                                      ),
                                )
                              : const _DeviceSettings(),
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

class _SettingsTabs extends StatelessWidget {
  final bool preferencesSelected;
  final ValueChanged<bool> onChanged;

  const _SettingsTabs({
    required this.preferencesSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Device',
                  selected: !preferencesSelected,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Preferences',
                  selected: preferencesSelected,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.secondaryBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Text(
            label,
            style: AppTypography.titleBig1.copyWith(
              color: selected ? Colors.white : const Color(0xFFC5C5C5),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceSettings extends StatelessWidget {
  const _DeviceSettings();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Connection Tutorials',
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect your PainSense health monitoring device to learn more about your pain management.',
          style: AppTypography.titleBig2.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Current Devices',
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 10),
        _CurrentDeviceCard(compact: context.isCompactShell),
        const SizedBox(height: 30),
        Text(
          'Need help with a Painsense Device?',
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Contact Us',
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        Text(
          'info@painsensesolution.ca\n1200 - 900 West Hastings St.\nVancouver BC V6C 1E5',
          style: AppTypography.titleBig2.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
      ],
    );
  }
}

class _CurrentDeviceCard extends StatelessWidget {
  final bool compact;

  const _CurrentDeviceCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    final deviceInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PainSense Back Belt',
          style: AppTypography.defaultBody1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '2026',
          style: AppTypography.defaultBody2.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 0 : 126),
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 52,
                      child: Image.asset(
                        'assets/images/icon/Painsense Belt.817 1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: deviceInfo),
                  ],
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ActionButton(label: 'Info'),
                    _ActionButton(label: 'Tutorial', width: 200),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 200,
                  height: 60,
                  child: Image.asset(
                    'assets/images/icon/Painsense Belt.817 1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(child: deviceInfo),
                const _ActionButton(label: 'Info'),
                const SizedBox(width: 20),
                const _ActionButton(label: 'Tutorial', width: 240),
              ],
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final double width;

  const _ActionButton({required this.label, this.width = 115});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.secondaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: AppTypography.titleSmall1),
      ),
    );
  }
}

class _PreferencesSettings extends StatelessWidget {
  final bool darkMode;
  final bool largeText;
  final bool emails;
  final bool pushNotifications;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onEmailsChanged;
  final ValueChanged<bool> onPushNotificationsChanged;

  const _PreferencesSettings({
    required this.darkMode,
    required this.largeText,
    required this.emails,
    required this.pushNotifications,
    required this.onDarkModeChanged,
    required this.onLargeTextChanged,
    required this.onEmailsChanged,
    required this.onPushNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.isCompactShell ? 0 : 92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreferenceGroup(
            title: 'Appearance',
            children: [
              _PreferenceRow(
                label: 'Dark Mode',
                value: darkMode,
                onChanged: onDarkModeChanged,
              ),
              _PreferenceRow(
                label: 'Large Text',
                value: largeText,
                onChanged: onLargeTextChanged,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PreferenceGroup(
            title: 'Notices',
            children: [
              _PreferenceRow(
                label: 'E-Mails',
                value: emails,
                onChanged: onEmailsChanged,
              ),
              _PreferenceRow(
                label: 'Push Notifications',
                value: pushNotifications,
                onChanged: onPushNotificationsChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PreferenceGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.titleBig2.copyWith(
                color: AppPalette.secondaryBlue,
              ),
            ),
          ),
          _PreferenceToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: value,
      label: 'Preference toggle',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          width: 86,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppPalette.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
