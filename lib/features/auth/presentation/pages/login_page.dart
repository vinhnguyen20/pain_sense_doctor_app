import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/common/widgets/custom_button.dart';
import 'package:app_doctor/common/widgets/custom_text_field.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/validators.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthViewState>(authProvider, (previous, next) {
      if (next.state == AuthState.error && next.errorMessage != null) {
        AppSnackbar.error(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo/ps_logo_full.png',
                        width: MediaQuery.sizeOf(context).width * 0.5,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'For doctor app',
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.onSurface,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PainSense | AI Wearable  for Low Back Pain Monitoring & Early Detection',
                        textAlign: TextAlign.center,
                        style: context.bodySmall?.copyWith(
                          color: context.onSurface.withValues(alpha: .5),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _usernameController,
                        label: 'Email address',
                        hintText: 'Enter your email address',
                        prefixIcon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.validateEmail,
                      ),

                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          color: context.onSurface.withValues(alpha: .45),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      CustomButton(
                        onPressed: _isEmailLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _handleEmailPasswordLogin();
                                }
                              },
                        label: 'Sign In',
                        isLoading: _isEmailLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _CompanyInfo(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailPasswordLogin() async {
    setState(() => _isEmailLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmailPassword(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted && ref.read(authProvider).isAuthenticated) {
        context.go('/home');
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }
}

class _CompanyInfo extends StatelessWidget {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.bodySmall?.copyWith(
      fontSize: 12,
      color: context.onSurface.withValues(alpha: .7),
    );

    final iconColor = context.onSurface.withValues(alpha: .4);
    const iconSize = 16.0;
    const iconGap = 10.0;

    Widget row({
      required IconData icon,
      required Widget child,
      bool alignTop = false,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: alignTop ? 1 : 0),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          const SizedBox(width: iconGap),
          child,
        ],
      );
    }

    Widget linkRow(IconData icon, String label, String url) {
      return GestureDetector(
        onTap: () => _launchUrl(url),
        child: row(
          icon: icon,
          child: Text(
            label,
            style: context.bodySmall?.copyWith(
              fontSize: 12,
              color: context.primary,
              decoration: TextDecoration.underline,
              decorationColor: context.primary,
            ),
          ),
        ),
      );
    }

    Widget addressRow(IconData icon, List<String> lines) {
      return row(
        icon: icon,
        alignTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((l) => Text(l, style: textStyle)).toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.onSurface.withValues(alpha: .12)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'PainSense Solution',
            style: context.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.onSurface.withValues(alpha: .7),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                linkRow(
                  Icons.language_outlined,
                  'painsensesolution.ca',
                  'https://painsensesolution.ca/',
                ),
                const SizedBox(height: 8),
                linkRow(
                  Icons.email_outlined,
                  'info@painsensesolution.ca',
                  'mailto:info@painsensesolution.ca',
                ),
                const SizedBox(height: 8),
                linkRow(
                  Icons.phone_outlined,
                  '+1 (888) 462-5539',
                  'tel:+18884625539',
                ),
                const SizedBox(height: 8),
                addressRow(Icons.location_on_outlined, [
                  '1200 - 900 West Hastings St.',
                  'Vancouver BC V6C 1E5',
                ]),
                const SizedBox(height: 8),
                addressRow(Icons.forward_to_inbox_outlined, [
                  '6388 No. 3 Road, Suite 725',
                  'Richmond BC V6Y 0L4',
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
