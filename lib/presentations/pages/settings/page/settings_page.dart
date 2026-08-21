import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/common/widgets/custom_app_bar.dart';
import 'package:app_doctor/common/widgets/custom_text_field.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/settings/presentation/provider/settings_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ecNameCtrl = TextEditingController();
  final _ecPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    final existing = ref.read(userProvider).user;
    if (existing != null) {
      _populate(existing);
    } else {
      Future.microtask(() => ref.read(userProvider.notifier).getCurrentUser());
    }
  }

  void _populate(User user) {
    _firstNameCtrl.text = user.firstName ?? '';
    _lastNameCtrl.text = user.lastName ?? '';
    _emailCtrl.text = user.email ?? '';
    _phoneCtrl.text = user.phone ?? '';
    _ecNameCtrl.text = user.emergencyContact?.name ?? '';
    _ecPhoneCtrl.text = user.emergencyContact?.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ecNameCtrl.dispose();
    _ecPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    final error = await ref
        .read(settingsProvider.notifier)
        .updateProfile(
          firstName: _firstNameCtrl.text,
          lastName: _lastNameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          emergencyName: _ecNameCtrl.text,
          emergencyPhone: _ecPhoneCtrl.text,
        );

    if (!mounted) return;

    if (error != null) {
      AppSnackbar.error(context, error);
    } else {
      AppSnackbar.success(context, 'Profile updated successfully');
    }
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final settingsState = ref.watch(settingsProvider);

    ref.listen<UserState>(userProvider, (prev, next) {
      if (next.user != null && prev?.user != next.user) {
        _populate(next.user!);
      }
    });

    return Scaffold(
      backgroundColor: context.background,
      appBar: const CustomAppBar(title: 'Settings'),
      body: SafeArea(
        child: userState.isLoading && userState.user == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(userProvider.notifier)
                    .getCurrentUser(forceRefresh: true),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s8),

                        _SectionCard(
                          title: 'Personal Information',
                          icon: Icons.person_outline_rounded,
                          children: [
                            if (context.isMobile) ...[
                              CustomTextField(
                                controller: _firstNameCtrl,
                                label: 'First Name',
                              ),
                              const SizedBox(height: AppSpacing.s16),
                              CustomTextField(
                                controller: _lastNameCtrl,
                                label: 'Last Name',
                              ),
                            ] else
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _firstNameCtrl,
                                      label: 'First Name',
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _lastNameCtrl,
                                      label: 'Last Name',
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: AppSpacing.s16),
                            _BirthdateField(
                              selected: settingsState.birthdate,
                              onChanged: (date) => ref
                                  .read(settingsProvider.notifier)
                                  .setBirthdate(date),
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            CustomTextField(
                              controller: _emailCtrl,
                              label: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            CustomTextField(
                              controller: _phoneCtrl,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s16),

                        _SectionCard(
                          title: 'Emergency Contact',
                          icon: Icons.emergency_outlined,
                          subtitle: 'Person to contact in case of emergency',
                          children: [
                            CustomTextField(
                              controller: _ecNameCtrl,
                              label: 'Contact Name',
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            CustomTextField(
                              controller: _ecPhoneCtrl,
                              label: 'Contact Phone',
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s24),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: settingsState.isLoading ? null : _onSave,
                            style: FilledButton.styleFrom(
                              backgroundColor: context.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s16,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppCorners.r12,
                              ),
                            ),
                            child: settingsState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _onLogout,
                            icon: Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: context.error,
                            ),
                            label: Text(
                              'Log out',
                              style: TextStyle(
                                color: context.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s16,
                              ),
                              side: BorderSide(
                                color: context.error.withValues(alpha: .4),
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppCorners.r12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s32),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppCorners.r16,
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: context.primary),
              const SizedBox(width: AppSpacing.s8),
              Text(
                title,
                style: context.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                subtitle!,
                style: context.bodySmall?.copyWith(
                  color: context.onSurface.withValues(alpha: .5),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s20),
          ...children,
        ],
      ),
    );
  }
}

class _BirthdateField extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime?> onChanged;

  const _BirthdateField({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: context.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.onSurface.withValues(alpha: .6),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s14,
            ),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: AppCorners.r12,
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: context.onSurface.withValues(alpha: .45),
                ),
                const SizedBox(width: AppSpacing.s10),
                Text(
                  selected != null
                      ? '${selected!.day.toString().padLeft(2, '0')}/${selected!.month.toString().padLeft(2, '0')}/${selected!.year}'
                      : 'Select date of birth',
                  style: context.bodyMedium?.copyWith(
                    color: selected != null
                        ? context.onSurface
                        : context.onSurface.withValues(alpha: .35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
