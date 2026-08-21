import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _notificationFrequency = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            final horizontalPadding = isCompact ? 16.0 : 30.0;

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
                      _SettingsTabs(controller: _tabController),
                      const SizedBox(height: 28),
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) => _tabController.index == 0
                            ? _DeviceSettings(isCompact: isCompact)
                            : _NotificationSettings(
                                selected: _notificationFrequency,
                                onSelected: (value) => setState(
                                  () => _notificationFrequency = value,
                                ),
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
  final TabController controller;

  const _SettingsTabs({required this.controller});

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
          child: TabBar(
            controller: controller,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: AppPalette.secondaryBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFC5C5C5),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'Device'),
              Tab(text: 'Notifications'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceSettings extends StatelessWidget {
  final bool isCompact;

  const _DeviceSettings({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 161),
          child: const _SectionTitle(
            icon: Icons.bluetooth,
            text: "John's Devices",
          ),
        ),
        const SizedBox(height: 10),
        _DeviceCard(
          image: 'assets/images/icon/Group 241.png',
          title: 'PainSense Back Belt',
          subtitle: 'Connected',
          connected: true,
          isCompact: isCompact,
          insetHorizontal: isCompact ? 0 : 161,
          actionLabel: 'Info',
        ),
        const SizedBox(height: 30),
        Text(
          'Device Connection Tutorials',
          style: context.bodyLarge?.copyWith(
            color: AppPalette.secondaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Connect your PainSense health monitoring device to learn more about your pain management.',
          style: context.bodyLarge?.copyWith(color: AppPalette.secondaryBlue),
        ),
        const SizedBox(height: 22),
        Text(
          'Current Devices',
          style: context.bodyLarge?.copyWith(
            color: AppPalette.secondaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _DeviceCard(
          image: 'assets/images/icon/Painsense Belt.817 1.png',
          title: 'PainSense Back Belt',
          subtitle: '2026',
          isCompact: isCompact,
          actionLabel: 'Info',
          secondaryActionLabel: 'Tutorial',
        ),
        const SizedBox(height: 30),
        Text(
          'Need help with a Painsense Device?',
          style: context.bodyLarge?.copyWith(
            color: AppPalette.secondaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Contact Us\ninfo@painsensesolution.ca\n1200 - 900 West Hastings St.\nVancouver BC V6C 1E5',
          style: context.bodyLarge?.copyWith(color: AppPalette.secondaryBlue),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppPalette.secondaryBlue),
        const SizedBox(width: 12),
        Text(
          text,
          style: context.bodyLarge?.copyWith(
            color: AppPalette.secondaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool connected;
  final bool isCompact;
  final double insetHorizontal;
  final String actionLabel;
  final String? secondaryActionLabel;

  const _DeviceCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isCompact,
    this.insetHorizontal = 0,
    required this.actionLabel,
    this.connected = false,
    this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final actions = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ActionButton(label: actionLabel),
        if (secondaryActionLabel != null) ...[
          const SizedBox(width: 20),
          _ActionButton(label: secondaryActionLabel!),
        ],
      ],
    );
    final compactActions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionButton(label: actionLabel, expand: true),
        if (secondaryActionLabel != null) ...[
          const SizedBox(height: 12),
          _ActionButton(label: secondaryActionLabel!, expand: true),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insetHorizontal),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 14 : 20,
          vertical: isCompact ? 14 : 18,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DeviceInfo(
                    image: image,
                    title: title,
                    subtitle: subtitle,
                    connected: connected,
                  ),
                  const SizedBox(height: 14),
                  compactActions,
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _DeviceInfo(
                      image: image,
                      title: title,
                      subtitle: subtitle,
                      connected: connected,
                    ),
                  ),
                  actions,
                ],
              ),
      ),
    );
  }
}

class _DeviceInfo extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool connected;

  const _DeviceInfo({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (connected)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: AppPalette.green,
              shape: BoxShape.circle,
            ),
          ),
        SizedBox(
          width: connected ? 76 : 150,
          height: connected ? 28 : 52,
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyLarge?.copyWith(
                  color: AppPalette.secondaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.bodyLarge?.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool expand;

  const _ActionButton({required this.label, this.expand = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : (label == 'Tutorial' ? 240 : 115),
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
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _NotificationSettings extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _NotificationSettings({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose John's Notification Frequency",
          style: context.bodyLarge?.copyWith(
            color: AppPalette.secondaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This setting will adjust how often the PainSense device vibrates to suggest adjustments to posture.',
          style: context.bodyLarge?.copyWith(color: AppPalette.secondaryBlue),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth < 420 ? 22.0 : 29.0;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(7, (index) {
                    final isSelected = index == selected;
                    return GestureDetector(
                      onTap: () => onSelected(index),
                      child: Container(
                        width: barWidth,
                        height: isSelected ? 62 : (index.isEven ? 23 : 34),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppPalette.secondaryBlue
                              : (index == 0 || index == 6
                                    ? const Color(0xFFF5F5F5)
                                    : const Color(0xFFC7D3DE)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Less Often'), Text('More Often')],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
