import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum PatientSurveyStep { painDuration, painLevel, activityLevels, activity }

class PatientIntroPage extends StatefulWidget {
  const PatientIntroPage({super.key});

  @override
  State<PatientIntroPage> createState() => _PatientIntroPageState();
}

class _PatientIntroPageState extends State<PatientIntroPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: Center(
          child: _PatientBrand(lockupWidth: 410, showTagline: true),
        ),
      ),
    );
  }
}

class PatientWelcomePage extends StatelessWidget {
  const PatientWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientOnboardingFrame(
      title: 'Welcome to PainSense',
      subtitle: 'Login or Create an Account to get started.',
      body: _WelcomeCard(),
      actions: SizedBox.shrink(),
    );
  }
}

class PatientLoginPage extends ConsumerStatefulWidget {
  const PatientLoginPage({super.key});

  @override
  ConsumerState<PatientLoginPage> createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends ConsumerState<PatientLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
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

    return PatientOnboardingFrame(
      title: 'Welcome to PainSense',
      subtitle: 'Login to continue.',
      body: _FormCard(
        title: 'Login',
        children: [
          _PatientFormField(
            label: 'E-Mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          _PatientFormField(
            label: 'Password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffix: IconButton(
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ],
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PatientButton(
            label: 'Back',
            onPressed: _isSubmitting ? null : () => context.go('/welcome'),
          ),
          _PatientButton(
            label: _isSubmitting ? 'Logging in...' : 'Login',
            onPressed: _isSubmitting ? null : _handleLogin,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(context, 'Please enter your email and password.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmailPassword(email, password);

      if (mounted && ref.read(authProvider).isAuthenticated) {
        context.go('/home');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class PatientAccountCreationPage extends StatefulWidget {
  const PatientAccountCreationPage({super.key});

  @override
  State<PatientAccountCreationPage> createState() =>
      _PatientAccountCreationPageState();
}

class _PatientAccountCreationPageState
    extends State<PatientAccountCreationPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PatientOnboardingFrame(
      title: 'Welcome to PainSense',
      subtitle: 'Let’s start by getting you set up with an account.',
      body: _FormCard(
        title: 'Create An Account',
        height: 485,
        children: [
          _PatientFormField(
            label: 'First Name',
            controller: _firstNameController,
          ),
          _PatientFormField(
            label: 'Last Name',
            controller: _lastNameController,
          ),
          _PatientFormField(
            label: 'E-Mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          _PatientFormField(
            label: 'Password',
            controller: _passwordController,
            obscureText: true,
          ),
          _PatientFormField(
            label: 'Re-Enter Password',
            controller: _confirmPasswordController,
            obscureText: true,
          ),
        ],
      ),
      onBack: () => context.go('/welcome'),
      onNext: () => context.go('/profile-setup'),
    );
  }
}

class PatientProfileSetupPage extends StatefulWidget {
  const PatientProfileSetupPage({super.key});

  @override
  State<PatientProfileSetupPage> createState() =>
      _PatientProfileSetupPageState();
}

class _PatientProfileSetupPageState extends State<PatientProfileSetupPage> {
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _contactController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PatientOnboardingFrame(
      title: 'About You',
      subtitle:
          'Tell us more about yourself so we can address your pain more accurately.',
      body: _FormCard(
        title: 'Profile Setup',
        children: [
          _PatientFormField(
            label: 'Age',
            controller: _ageController,
            keyboardType: TextInputType.number,
          ),
          _PatientFormField(
            label: 'Emergency Contact',
            controller: _contactController,
          ),
          _PatientFormField(
            label: 'EC E-Mail',
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          _PatientFormField(
            label: 'EC Phone #',
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Text(
            'Please complete the following survey so we can better understand your back pain.',
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(color: AppPalette.black),
          ),
        ],
      ),
      onBack: () => context.go('/register'),
      onNext: () => context.go('/survey/pain-duration'),
    );
  }
}

class PatientSurveyPage extends StatefulWidget {
  final PatientSurveyStep step;

  const PatientSurveyPage({super.key, required this.step});

  @override
  State<PatientSurveyPage> createState() => _PatientSurveyPageState();
}

class _PatientSurveyPageState extends State<PatientSurveyPage> {
  String? _selected;
  String? _selectedSitting;
  String? _selectedWalking;

  int get _pageNumber => switch (widget.step) {
    PatientSurveyStep.painDuration => 1,
    PatientSurveyStep.painLevel => 2,
    PatientSurveyStep.activityLevels => 3,
    PatientSurveyStep.activity => 4,
  };

  @override
  Widget build(BuildContext context) {
    final content = switch (widget.step) {
      PatientSurveyStep.painDuration => _buildPainDuration(),
      PatientSurveyStep.painLevel => _buildPainLevel(),
      PatientSurveyStep.activityLevels => _buildActivityLevels(),
      PatientSurveyStep.activity => _buildActivity(),
    };

    return PatientOnboardingFrame(
      title: 'Setup Survey',
      subtitle:
          'Tell us more about yourself so we can address your pain more accurately.',
      progressLabel: '$_pageNumber/5',
      progress: _pageNumber / 5,
      body: content,
      onBack: _goBack,
      onNext: _goNext,
    );
  }

  Widget _buildPainDuration() => _SurveyCard(
    title: 'Your Back Pain',
    question: 'How long have you been dealing with lower back pain?',
    child: _ChoiceList(
      values: const [
        '1-3 Days',
        '1-3 Weeks',
        '1 Month',
        '3 Months+',
        '1+ Years',
      ],
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
    ),
  );

  Widget _buildPainLevel() => _SurveyCard(
    title: 'Your Back Pain',
    question: 'Rate your back pain on a scale from 1-10, 10 being the worst.',
    child: _ChoiceWrap(
      values: List.generate(10, (index) => '${index + 1}'),
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
    ),
  );

  Widget _buildActivityLevels() => _SurveyCard(
    title: 'Your Activity Levels',
    question: 'How many hours a day do you spend sitting?',
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _ChoiceWrap(
              values: const [
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
                '10+',
              ],
              selected: _selectedSitting,
              onSelected: (value) => setState(() => _selectedSitting = value),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'How many hours a day do you spend walking?',
            style: AppTypography.heading2.copyWith(color: AppPalette.black),
          ),
          const SizedBox(height: 14),
          Center(
            child: _ChoiceWrap(
              values: const [
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
                '10+',
              ],
              selected: _selectedWalking,
              onSelected: (value) => setState(() => _selectedWalking = value),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildActivity() => _SurveyCard(
    title: 'Your Activity',
    question:
        'Approximately how much time do you spend in a day actively exercising?',
    child: _ChoiceList(
      values: const [
        'None',
        '10-20 Minutes',
        '30 Minutes',
        '1 Hour',
        '1.5 Hours',
        '2 Hours+',
      ],
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
      buttonHeight: 40,
      itemGap: 5,
    ),
  );

  void _goBack() {
    final previous = switch (widget.step) {
      PatientSurveyStep.painDuration => '/profile-setup',
      PatientSurveyStep.painLevel => '/survey/pain-duration',
      PatientSurveyStep.activityLevels => '/survey/pain-level',
      PatientSurveyStep.activity => '/survey/activity-levels',
    };
    context.go(previous);
  }

  void _goNext() {
    final next = switch (widget.step) {
      PatientSurveyStep.painDuration => '/survey/pain-level',
      PatientSurveyStep.painLevel => '/survey/activity-levels',
      PatientSurveyStep.activityLevels => '/survey/activity',
      PatientSurveyStep.activity => '/survey/complete',
    };
    context.go(next);
  }
}

class PatientSurveyCompletePage extends StatelessWidget {
  const PatientSurveyCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PatientOnboardingFrame(
      title: 'Survey Complete',
      subtitle: 'All set!',
      progressLabel: '5/5',
      progress: 1,
      body: const _CompleteContent(),
      actions: Center(
        child: _PatientButton(
          label: 'To Device Setup',
          onPressed: () => context.go('/login'),
        ),
      ),
    );
  }
}

class PatientOnboardingFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? progressLabel;
  final double? progress;
  final Widget body;
  final Widget? actions;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const PatientOnboardingFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.progressLabel,
    this.progress,
    this.actions,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            final horizontal = compact ? 24.0 : 47.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 26, horizontal, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 26
                      ? constraints.maxHeight - 26
                      : 0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: _headingStyle(context, compact)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: _subtitleStyle(context, compact)),
                      if (progress != null) ...[
                        const SizedBox(height: 31),
                        Row(
                          children: [
                            Text(
                              progressLabel ?? '',
                              style: _subtitleStyle(
                                context,
                                compact,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 18,
                                  child: Stack(
                                    children: [
                                      const Positioned.fill(
                                        child: ColoredBox(
                                          color: AppPalette.surfaceLight,
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: progress!.clamp(0.0, 1.0),
                                        heightFactor: 1,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: AppPalette.secondaryBlue,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: progress == null ? 54 : 30),
                      Center(child: body),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 22, bottom: 80),
                        child:
                            actions ??
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _PatientButton(
                                  label: 'Back',
                                  onPressed: onBack,
                                ),
                                _PatientButton(
                                  label: 'Next',
                                  onPressed: onNext,
                                ),
                              ],
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

  TextStyle _headingStyle(BuildContext context, bool compact) =>
      AppTypography.display1.copyWith(
        fontSize: compact ? 30 : 34,
        color: AppPalette.secondaryBlue,
        height: 1.1,
      );

  TextStyle _subtitleStyle(BuildContext context, bool compact) =>
      AppTypography.titleBig2.copyWith(
        fontSize: compact ? 18 : 20,
        color: AppPalette.secondaryBlue,
        height: 1.2,
      );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      width: 945,
      child: Column(
        children: [
          const _PatientBrand(lockupWidth: 420, showTagline: true),
          const SizedBox(height: 115),
          _PatientButton(label: 'Login', onPressed: () => context.go('/login')),
          const SizedBox(height: 18),
          _PatientButton(
            label: 'Create Account',
            onPressed: () => context.go('/register'),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final double? height;
  final List<Widget> children;

  const _FormCard({required this.title, required this.children, this.height});

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      width: double.infinity,
      height: height,
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.display1.copyWith(
              color: AppPalette.secondaryBlue,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 45),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const SizedBox(height: AppSpacing.s20),
          ],
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final String title;
  final String question;
  final Widget child;

  const _SurveyCard({
    required this.title,
    required this.question,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      width: 890,
      height: MediaQuery.sizeOf(context).height >= 700 ? 485 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.display1.copyWith(
                color: AppPalette.secondaryBlue,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 47),
          Text(
            question,
            textAlign: TextAlign.left,
            style: AppTypography.heading2.copyWith(color: AppPalette.black),
          ),
          const SizedBox(height: 27),
          Align(alignment: Alignment.center, child: child),
        ],
      ),
    );
  }
}

class _CompleteContent extends StatelessWidget {
  const _CompleteContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 150),
          Text(
            'Thank You',
            style: AppTypography.display1.copyWith(
              color: AppPalette.secondaryBlue,
              fontSize: 64,
            ),
          ),
          const SizedBox(height: 46),
          Text(
            'You are now ready to start your pain management journey!',
            style: AppTypography.heading2.copyWith(
              color: AppPalette.black,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final double width;
  final double? height;
  final Widget child;

  const _OnboardingCard({
    required this.width,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Container(
      width: compact ? double.infinity : width,
      height: compact ? null : height,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 22 : 60,
        vertical: compact ? 28 : 33,
      ),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _PatientBrand extends StatelessWidget {
  final double lockupWidth;
  final bool showTagline;

  const _PatientBrand({required this.lockupWidth, required this.showTagline});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo/logo_full_color_no_bg.png',
          width: lockupWidth,
          fit: BoxFit.contain,
        ),
        if (showTagline) ...[
          const SizedBox(height: 12),
          Text(
            'Rehab. Track. Thrive.',
            style: AppTypography.display1.copyWith(
              color: AppPalette.secondaryBlue,
              fontSize: 30,
            ),
          ),
        ],
      ],
    );
  }
}

class _PatientFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _PatientFormField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final input = SizedBox(
      height: 48,
      child: Material(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(67),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: AppPalette.secondaryBlue,
          textAlignVertical: TextAlignVertical.center,
          style: AppTypography.heading2.copyWith(color: AppPalette.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppPalette.white,
            hoverColor: AppPalette.transparent,
            isDense: true,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(67),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(67),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(67),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.heading2.copyWith(
              color: AppPalette.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          input,
        ],
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 260,
          height: 48,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: AppTypography.heading2.copyWith(color: AppPalette.black),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: input),
      ],
    );
  }
}

class _ChoiceList extends StatelessWidget {
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onSelected;
  final double buttonHeight;
  final double itemGap;

  const _ChoiceList({
    required this.values,
    required this.selected,
    required this.onSelected,
    this.buttonHeight = 46,
    this.itemGap = 7,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        children: values
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == values.length - 1 ? 0 : itemGap,
                ),
                child: _PatientChoice(
                  value: entry.value,
                  selected: selected == entry.value,
                  onPressed: () => onSelected(entry.value),
                  buttonHeight: buttonHeight,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: values
          .map(
            (value) => _PatientChoice(
              value: value,
              compact: true,
              selected: selected == value,
              onPressed: () => onSelected(value),
            ),
          )
          .toList(),
    );
  }
}

class _PatientChoice extends StatelessWidget {
  final String value;
  final bool selected;
  final bool compact;
  final VoidCallback onPressed;
  final double buttonHeight;

  const _PatientChoice({
    required this.value,
    required this.selected,
    required this.onPressed,
    this.compact = false,
    this.buttonHeight = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 60 : double.infinity,
      height: compact ? 46 : buttonHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: selected
              ? AppPalette.secondaryBlue
              : AppPalette.white,
          foregroundColor: selected
              ? AppPalette.white
              : AppPalette.secondaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: AppTypography.titleBig1.copyWith(
            fontSize: compact ? 20 : 20,
          ),
        ),
        child: Text(value),
      ),
    );
  }
}

class _PatientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PatientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 50,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.secondaryBlue,
          foregroundColor: AppPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleBig1.copyWith(fontSize: 23),
        ),
        child: Text(label),
      ),
    );
  }
}
