import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/app_config.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/validators.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClinicianAccountPage extends ConsumerWidget {
  const ClinicianAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppPalette.white,
        body: Center(
          child: userState.isLoading
              ? const CircularProgressIndicator(color: AppPalette.secondaryBlue)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 64,
                      color: AppPalette.medGray,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userState.error ??
                          'Account information could not be loaded.',
                      textAlign: TextAlign.center,
                      style: AppTypography.defaultBody2,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref
                          .read(userProvider.notifier)
                          .getCurrentUser(forceRefresh: true),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
        ),
      );
    }

    return _AccountForm(key: ValueKey(user.id), user: user);
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  final User user;

  const _AccountForm({super.key, required this.user});

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _countryCodeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _firstNameController = TextEditingController(text: user.firstName ?? '');
    _lastNameController = TextEditingController(text: user.lastName ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _countryCodeController = TextEditingController(
      text: user.countryCode ?? '',
    );
    _phoneController = TextEditingController(text: user.phone ?? '');
    _addressController = TextEditingController(text: user.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      countryCode: _countryCodeController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    final response = await ref.read(updateUserUseCaseProvider).call(updated);

    if (!mounted) return;
    setState(() => _saving = false);
    if (response.isFailure) {
      AppSnackbar.error(context, response.message);
      return;
    }

    await ref.read(userProvider.notifier).getCurrentUser(forceRefresh: true);
    if (mounted) {
      AppSnackbar.success(context, 'Account information updated.');
    }
  }

  Future<void> _changePassword() async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (mounted && updated == true) {
      AppSnackbar.success(context, 'Password updated successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompactShell;
    final displayName = widget.user.fullName.isEmpty
        ? 'Doctor'
        : 'Dr. ${widget.user.fullName}';

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? AppSpacing.s16 : 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClinicianHeader(
                  doctorName: displayName,
                  avatarUrl: _avatarUrl(widget.user.avatarUrl),
                ),
                SizedBox(height: compact ? AppSpacing.s24 : 36),
                Text(
                  'Account',
                  style: AppTypography.display1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                _ProfileSummary(user: widget.user),
                const SizedBox(height: AppSpacing.s24),
                _SectionCard(
                  title: 'Your Information',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 700;
                      final fields = [
                        _AccountField(
                          controller: _firstNameController,
                          label: 'First Name',
                          validator: (value) => AppValidators.validateName(
                            value,
                            fieldName: 'first name',
                          ),
                        ),
                        _AccountField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          validator: (value) => AppValidators.validateName(
                            value,
                            fieldName: 'last name',
                          ),
                        ),
                        _AccountField(
                          controller: _emailController,
                          label: 'E-Mail',
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.validateEmail,
                        ),
                        _AccountField(
                          controller: _countryCodeController,
                          label: 'Country Code',
                          hintText: '+1',
                          validator: (value) => AppValidators.validateRequired(
                            value,
                            fieldName: 'country code',
                          ),
                        ),
                        _AccountField(
                          controller: _phoneController,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.validatePhone,
                        ),
                        _AccountField(
                          controller: _addressController,
                          label: 'Address',
                          validator: (value) => AppValidators.validateRequired(
                            value,
                            fieldName: 'address',
                          ),
                        ),
                      ];
                      if (!twoColumns) {
                        return Column(
                          children: [
                            for (var i = 0; i < fields.length; i++) ...[
                              fields[i],
                              if (i < fields.length - 1)
                                const SizedBox(height: AppSpacing.s16),
                            ],
                          ],
                        );
                      }
                      return Wrap(
                        spacing: AppSpacing.s20,
                        runSpacing: AppSpacing.s16,
                        children: fields
                            .map(
                              (field) => SizedBox(
                                width: (constraints.maxWidth - 20) / 2,
                                child: field,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                _SectionCard(
                  title: 'Password',
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Password  ••••••••••••',
                          style: AppTypography.titleSmall2,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('Change Password'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                Wrap(
                  spacing: AppSpacing.s16,
                  runSpacing: AppSpacing.s12,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 50,
                      child: FilledButton(
                        onPressed: _saving ? null : _saveProfile,
                        child: Text(_saving ? 'Saving...' : 'Save Changes'),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).signOut(),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final User user;

  const _ProfileSummary({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = [
      user.firstName?.trim() ?? '',
      user.lastName?.trim() ?? '',
    ].where((value) => value.isNotEmpty).map((value) => value[0]).join();
    final avatar = _avatarUrl(user.avatarUrl);
    return Row(
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: 88,
            child: avatar == null
                ? ColoredBox(
                    color: AppPalette.secondaryBlue.withValues(alpha: .12),
                    child: Center(
                      child: initials.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: AppPalette.secondaryBlue,
                            )
                          : Text(
                              initials.toUpperCase(),
                              style: AppTypography.heading1.copyWith(
                                color: AppPalette.secondaryBlue,
                              ),
                            ),
                    ),
                  )
                : Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: AppPalette.surfaceLight,
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.s20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName.isEmpty ? 'Doctor' : user.fullName,
                style: AppTypography.heading1.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                user.email ?? '',
                style: AppTypography.defaultBody2.copyWith(
                  color: AppPalette.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleBig1.copyWith(
              color: AppPalette.secondaryBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          child,
        ],
      ),
    );
  }
}

class _AccountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AccountField({
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.defaultBody2,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: AppPalette.surfaceLight,
        border: OutlineInputBorder(borderRadius: AppCorners.r12),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppCorners.r12,
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppCorners.r12,
          borderSide: const BorderSide(
            color: AppPalette.secondaryBlue,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final response = await ref
        .read(userRepositoryProvider)
        .updatePassword(
          oldPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted) return;
    if (response.isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _error = response.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppPalette.white,
      shape: RoundedRectangleBorder(borderRadius: AppCorners.r16),
      title: Text(
        'Change Password',
        style: AppTypography.heading1.copyWith(color: AppPalette.secondaryBlue),
      ),
      content: SizedBox(
        width: 430,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(
                controller: _currentController,
                label: 'Current Password',
              ),
              const SizedBox(height: AppSpacing.s14),
              _PasswordField(
                controller: _newController,
                label: 'New Password',
                validator: (value) => value != null && value.length >= 8
                    ? null
                    : 'Use at least 8 characters.',
              ),
              const SizedBox(height: AppSpacing.s14),
              _PasswordField(
                controller: _confirmController,
                label: 'Confirm New Password',
                validator: (value) => value == _newController.text
                    ? null
                    : 'Passwords do not match.',
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  _error!,
                  style: AppTypography.captionBody1.copyWith(
                    color: context.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Updating...' : 'Update Password'),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator:
          validator ??
          (value) => value == null || value.isEmpty ? 'Required.' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppPalette.surfaceLight,
        border: OutlineInputBorder(borderRadius: AppCorners.r12),
      ),
    );
  }
}

String? _avatarUrl(String? rawValue) {
  final raw = rawValue?.trim() ?? '';
  if (raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return '${AppConfig.baseUrl}${raw.startsWith('/') ? '' : '/'}$raw';
}
