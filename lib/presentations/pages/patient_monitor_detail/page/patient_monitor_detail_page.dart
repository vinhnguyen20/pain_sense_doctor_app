import 'package:app_doctor/common/widgets/custom_app_bar.dart';
import 'package:app_doctor/common/widgets/tab_bar_widget.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/alerts_tab.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/chat_tab.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/diary_tab.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_tab.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/overview_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientMonitorDetail extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientMonitorDetail({super.key, required this.patient});

  @override
  ConsumerState<PatientMonitorDetail> createState() =>
      _PatientDetailPageState();
}

class _PatientDetailPageState extends ConsumerState<PatientMonitorDetail> {
  static const _tabs = ['Overview', 'Goals', 'Chat', 'Diary', 'Alerts'];

  static const _tabIcons = <IconData>[
    Icons.dashboard_outlined,
    Icons.flag_outlined,
    Icons.chat_outlined,
    Icons.menu_book_outlined,
    Icons.notifications_outlined,
  ];

  static const _tabActiveIcons = <IconData>[
    Icons.dashboard,
    Icons.flag,
    Icons.chat,
    Icons.menu_book,
    Icons.notifications,
  ];

  String _selectedTab = 'Overview';

  String get _patientId => widget.patient.id.trim();
  int get _selectedIndex => _tabs.indexOf(_selectedTab);

  void _onTabSelected(String tab) => setState(() => _selectedTab = tab);
  void _onIndexSelected(int index) =>
      setState(() => _selectedTab = _tabs[index]);

  Widget _buildContent(Patient patient) {
    return switch (_selectedTab) {
      'Overview' => OverviewTab(patient: patient),
      'Goals' => GoalsTab(patientId: _patientId, logs: patient.trackingLogs),
      'Chat' => ChatTab(patient: patient, patientId: _patientId),
      'Diary' => DiaryTab(patientId: _patientId),
      'Alerts' => AlertsTab(patientId: _patientId, patient: patient),
      _ => _PlaceholderTab(tab: _selectedTab),
    };
  }

  Widget _buildMobileBody(BuildContext context, Patient patient) {
    return Column(
      children: [
        Padding(
          padding: AppInsets.screenHorizontal,
          child: TabBarWidget(
            categories: _tabs,
            selectedCategory: _selectedTab,
            onCategorySelected: _onTabSelected,
          ),
        ),
        Expanded(child: _buildContent(patient)),
      ],
    );
  }

  Widget _buildTabletBody(BuildContext context, Patient patient) {
    final extended = context.isExpanded;

    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onIndexSelected,
          extended: extended,
          backgroundColor: context.surface,
          labelType: extended
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          selectedIconTheme: IconThemeData(color: context.primary),
          unselectedIconTheme: IconThemeData(
            color: context.onSurface.withValues(alpha: 0.5),
          ),
          selectedLabelTextStyle: context.labelMedium?.copyWith(
            color: context.primary,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: context.labelMedium?.copyWith(
            color: context.onSurface.withValues(alpha: 0.5),
          ),
          indicatorColor: context.primary.withValues(alpha: 0.12),
          destinations: List.generate(
            _tabs.length,
            (i) => NavigationRailDestination(
              icon: Icon(_tabIcons[i]),
              selectedIcon: Icon(_tabActiveIcons[i]),
              label: Text(_tabs[i]),
            ),
          ),
        ),
        VerticalDivider(
          width: AppBorder.thin,
          thickness: AppBorder.thin,
          color: context.border,
        ),
        Expanded(child: _buildContent(patient)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: context.background,
      appBar: CustomAppBar(
        title: patient.fullName,
        subtitle: 'Age ${patient.age ?? 'Age not specified'}',
        showBackButton: true,
      ),
      body: context.isMobile
          ? _buildMobileBody(context, patient)
          : _buildTabletBody(context, patient),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String tab;

  const _PlaceholderTab({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$tab coming soon',
        style: context.bodyMedium?.copyWith(
          color: context.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
