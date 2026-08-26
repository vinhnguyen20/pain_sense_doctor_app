import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/validators.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
import 'package:app_doctor/features/auth/presentation/provider/patient_onboarding_provider.dart';
import 'package:app_doctor/features/survey/data/models/survey_definition_model.dart';
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
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail([String? value]) {
    final err = AppValidators.validateEmail(value ?? _emailController.text);
    if (_emailError != err) {
      setState(() => _emailError = err);
    }
  }

  void _validatePassword([String? value]) {
    final text = value ?? _passwordController.text;
    final err = text.isEmpty ? 'Please enter your password.' : null;
    if (_passwordError != err) {
      setState(() => _passwordError = err);
    }
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
            errorText: _emailError,
            onChanged: _validateEmail,
          ),
          _PatientFormField(
            label: 'Password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            errorText: _passwordError,
            onChanged: _validatePassword,
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

    final emailErr = AppValidators.validateEmail(email);
    final passwordErr = password.isEmpty ? 'Please enter your password.' : null;

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });

    final firstError = emailErr ?? passwordErr;
    if (firstError != null) {
      AppSnackbar.error(context, firstError);
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

class PatientAccountCreationPage extends ConsumerStatefulWidget {
  const PatientAccountCreationPage({super.key});

  @override
  ConsumerState<PatientAccountCreationPage> createState() =>
      _PatientAccountCreationPageState();
}

class _PatientAccountCreationPageState
    extends ConsumerState<PatientAccountCreationPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final registration = ref.read(patientOnboardingProvider).registration;
    if (registration != null) {
      _firstNameController.text = registration.firstName;
      _lastNameController.text = registration.lastName;
      _emailController.text = registration.email;
      _phoneController.text = registration.phone;
      _passwordController.text = registration.password;
      _confirmPasswordController.text = registration.password;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFirstName([String? value]) {
    final err = AppValidators.validateName(
      value ?? _firstNameController.text,
      fieldName: 'First name',
    );
    if (_firstNameError != err) setState(() => _firstNameError = err);
  }

  void _validateLastName([String? value]) {
    final err = AppValidators.validateName(
      value ?? _lastNameController.text,
      fieldName: 'Last name',
    );
    if (_lastNameError != err) setState(() => _lastNameError = err);
  }

  void _validateEmail([String? value]) {
    final err = AppValidators.validateEmail(value ?? _emailController.text);
    if (_emailError != err) setState(() => _emailError = err);
  }

  void _validatePhone([String? value]) {
    final err = AppValidators.validatePhone(
      value ?? _phoneController.text,
      fieldName: 'Phone number',
    );
    if (_phoneError != err) setState(() => _phoneError = err);
  }

  void _validatePassword([String? value]) {
    final err = AppValidators.validatePassword(
      value ?? _passwordController.text,
    );
    if (_passwordError != err) setState(() => _passwordError = err);
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword([String? value]) {
    final err = AppValidators.validateConfirmPassword(
      value ?? _confirmPasswordController.text,
      _passwordController.text,
    );
    if (_confirmPasswordError != err) {
      setState(() => _confirmPasswordError = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(patientOnboardingProvider);
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
            errorText: _firstNameError,
            onChanged: _validateFirstName,
          ),
          _PatientFormField(
            label: 'Last Name',
            controller: _lastNameController,
            errorText: _lastNameError,
            onChanged: _validateLastName,
          ),
          _PatientFormField(
            label: 'E-Mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: _validateEmail,
          ),
          _PatientFormField(
            label: 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
            onChanged: _validatePhone,
          ),
          _PatientFormField(
            label: 'Password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            errorText: _passwordError,
            onChanged: _validatePassword,
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
          _PatientFormField(
            label: 'Re-Enter Password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            errorText: _confirmPasswordError,
            onChanged: _validateConfirmPassword,
            suffix: IconButton(
              tooltip: _obscureConfirmPassword
                  ? 'Show password'
                  : 'Hide password',
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ],
      ),
      onBack: () => context.go('/welcome'),
      nextLabel: onboarding.isSubmitting ? 'Creating...' : 'Next',
      onNext: onboarding.isSubmitting ? null : () => _handleRegistration(),
    );
  }

  Future<void> _handleRegistration() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;

    final firstNameErr = AppValidators.validateName(
      firstName,
      fieldName: 'First name',
    );
    final lastNameErr = AppValidators.validateName(
      lastName,
      fieldName: 'Last name',
    );
    final emailErr = AppValidators.validateEmail(email);
    final phoneErr = AppValidators.validatePhone(
      phone,
      fieldName: 'Phone number',
    );
    final passwordErr = AppValidators.validatePassword(password);
    final confirmPasswordErr = AppValidators.validateConfirmPassword(
      confirmation,
      password,
    );

    setState(() {
      _firstNameError = firstNameErr;
      _lastNameError = lastNameErr;
      _emailError = emailErr;
      _phoneError = phoneErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
    });

    final firstError = firstNameErr ??
        lastNameErr ??
        emailErr ??
        phoneErr ??
        passwordErr ??
        confirmPasswordErr;

    if (firstError != null) {
      AppSnackbar.error(context, firstError);
      return;
    }

    final success = await ref
        .read(patientOnboardingProvider.notifier)
        .registerAccount(
          PatientRegistration(
            email: email,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            password: password,
          ),
        );
    if (!mounted) return;
    if (success) {
      context.go('/profile-setup');
    } else {
      AppSnackbar.error(
        context,
        ref.read(patientOnboardingProvider).errorMessage ??
            'Unable to create the account.',
      );
    }
  }
}

class PatientProfileSetupPage extends ConsumerStatefulWidget {
  const PatientProfileSetupPage({super.key});

  @override
  ConsumerState<PatientProfileSetupPage> createState() =>
      _PatientProfileSetupPageState();
}

class _PatientProfileSetupPageState
    extends ConsumerState<PatientProfileSetupPage> {
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String? _ageError;
  String? _contactNameError;
  String? _contactEmailError;
  String? _contactPhoneError;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(patientOnboardingProvider).profile;
    if (profile != null) {
      _ageController.text = profile.age.toString();
      _contactController.text = profile.emergencyContactName;
      _contactEmailController.text = profile.emergencyContactEmail;
      _contactPhoneController.text = profile.emergencyContactPhone;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _contactController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _validateAge([String? value]) {
    final err = AppValidators.validateAge(value ?? _ageController.text);
    if (_ageError != err) setState(() => _ageError = err);
  }

  void _validateContactName([String? value]) {
    final err = AppValidators.validateName(
      value ?? _contactController.text,
      fieldName: 'Emergency contact name',
    );
    if (_contactNameError != err) setState(() => _contactNameError = err);
  }

  void _validateContactEmail([String? value]) {
    final err = AppValidators.validateEmail(
      value ?? _contactEmailController.text,
    );
    if (_contactEmailError != err) setState(() => _contactEmailError = err);
  }

  void _validateContactPhone([String? value]) {
    final err = AppValidators.validatePhone(
      value ?? _contactPhoneController.text,
      fieldName: 'Emergency contact phone',
    );
    if (_contactPhoneError != err) setState(() => _contactPhoneError = err);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(patientOnboardingProvider);
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
            errorText: _ageError,
            onChanged: _validateAge,
          ),
          _PatientFormField(
            label: 'Emergency Contact',
            controller: _contactController,
            errorText: _contactNameError,
            onChanged: _validateContactName,
          ),
          _PatientFormField(
            label: 'EC E-Mail',
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _contactEmailError,
            onChanged: _validateContactEmail,
          ),
          _PatientFormField(
            label: 'EC Phone #',
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            errorText: _contactPhoneError,
            onChanged: _validateContactPhone,
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
      nextLabel: onboarding.isSubmitting ? 'Saving...' : 'Next',
      onNext: onboarding.isSubmitting ? null : () => _handleProfile(),
    );
  }

  Future<void> _handleProfile() async {
    final ageText = _ageController.text.trim();
    final contactName = _contactController.text.trim();
    final contactEmail = _contactEmailController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();

    final ageErr = AppValidators.validateAge(ageText);
    final nameErr = AppValidators.validateName(
      contactName,
      fieldName: 'Emergency contact name',
    );
    final emailErr = AppValidators.validateEmail(contactEmail);
    final phoneErr = AppValidators.validatePhone(
      contactPhone,
      fieldName: 'Emergency contact phone',
    );

    setState(() {
      _ageError = ageErr;
      _contactNameError = nameErr;
      _contactEmailError = emailErr;
      _contactPhoneError = phoneErr;
    });

    final firstError = ageErr ?? nameErr ?? emailErr ?? phoneErr;
    if (firstError != null) {
      AppSnackbar.error(context, firstError);
      return;
    }

    final age = int.parse(ageText);

    final success = await ref
        .read(patientOnboardingProvider.notifier)
        .saveProfileAndLoadSurvey(
          PatientProfileSetup(
            age: age,
            emergencyContactName: contactName,
            emergencyContactEmail: contactEmail,
            emergencyContactPhone: contactPhone,
          ),
        );
    if (!mounted) return;
    if (success) {
      context.go('/survey/pain-duration');
    } else {
      AppSnackbar.error(
        context,
        ref.read(patientOnboardingProvider).errorMessage ??
            'Unable to start the survey.',
      );
    }
  }
}

class PatientSurveyPage extends ConsumerStatefulWidget {
  final PatientSurveyStep step;

  const PatientSurveyPage({super.key, required this.step});

  @override
  ConsumerState<PatientSurveyPage> createState() => _PatientSurveyPageState();
}

class _PatientSurveyPageState extends ConsumerState<PatientSurveyPage> {
  @override
  void initState() {
    super.initState();
    if (ref.read(patientOnboardingProvider).registrationCompleted) {
      Future.microtask(
        () => ref.read(patientOnboardingProvider.notifier).ensureSurveyLoaded(),
      );
    }
  }

  int get _pageNumber => switch (widget.step) {
    PatientSurveyStep.painDuration => 1,
    PatientSurveyStep.painLevel => 2,
    PatientSurveyStep.activityLevels => 3,
    PatientSurveyStep.activity => 4,
  };

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(patientOnboardingProvider);
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
      nextLabel: onboarding.isSubmitting ? 'Submitting...' : 'Next',
      onNext: onboarding.isSubmitting ? null : () => _goNext(),
    );
  }

  Widget _buildPainDuration() => _SurveyCard(
    title: 'Your Back Pain',
    question: _questionTitle(
      0,
      'How long have you been dealing with lower back pain?',
    ),
    child: _ChoiceList(
      values: _questionOptions(0, const [
        '1-3 Days',
        '1-3 Weeks',
        '1 Month',
        '3 Months+',
        '1+ Years',
      ]),
      selected: _answer(0),
      onSelected: (value) => _selectAnswer(0, value),
    ),
  );

  Widget _buildPainLevel() => _SurveyCard(
    title: 'Your Back Pain',
    question: _questionTitle(
      1,
      'Rate your back pain on a scale from 1-10, 10 being the worst.',
    ),
    child: _ChoiceWrap(
      values: _questionOptions(1, List.generate(10, (index) => '${index + 1}')),
      selected: _answer(1),
      onSelected: (value) => _selectAnswer(1, value),
    ),
  );

  Widget _buildActivityLevels() => _SurveyCard(
    title: 'Your Activity Levels',
    question: _questionTitle(2, 'How many hours a day do you spend sitting?'),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _ChoiceWrap(
              values: _questionOptions(2, const [
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
              ]),
              selected: _answer(2),
              onSelected: (value) => _selectAnswer(2, value),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _questionTitle(3, 'How many hours a day do you spend walking?'),
            style: AppTypography.heading2.copyWith(color: AppPalette.black),
          ),
          const SizedBox(height: 14),
          Center(
            child: _ChoiceWrap(
              values: _questionOptions(3, const [
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
              ]),
              selected: _answer(3),
              onSelected: (value) => _selectAnswer(3, value),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildActivity() => _SurveyCard(
    title: 'Your Activity',
    question: _questionTitle(
      4,
      'Approximately how much time do you spend in a day actively exercising?',
    ),
    child: _ChoiceList(
      values: _questionOptions(4, const [
        'None',
        '10-20 Minutes',
        '30 Minutes',
        '1 Hour',
        '1.5 Hours',
        '2 Hours+',
      ]),
      selected: _answer(4),
      onSelected: (value) => _selectAnswer(4, value),
      buttonHeight: 40,
      itemGap: 5,
    ),
  );

  SurveyQuestionModel? _question(int index) {
    final questions = ref.watch(patientOnboardingProvider).survey?.questions;
    if (questions == null || index < 0 || index >= questions.length) {
      return null;
    }
    return questions[index];
  }

  String _questionTitle(int index, String fallback) {
    final title = _question(index)?.title.trim();
    return _displayText(title?.isNotEmpty == true ? title! : fallback);
  }

  List<String> _questionOptions(int index, List<String> fallback) {
    final options = _question(index)?.options ?? const <SurveyOptionModel>[];
    if (options.isEmpty) return fallback;
    return options.map((option) => _displayText(option.content)).toList();
  }

  String? _answer(int index) {
    return ref.watch(patientOnboardingProvider).answers[index];
  }

  void _selectAnswer(int index, String value) {
    ref.read(patientOnboardingProvider.notifier).selectAnswer(index, value);
  }

  static String _displayText(String value) => value.replaceAll('–', '-');

  void _goBack() {
    final previous = switch (widget.step) {
      PatientSurveyStep.painDuration => '/profile-setup',
      PatientSurveyStep.painLevel => '/survey/pain-duration',
      PatientSurveyStep.activityLevels => '/survey/pain-level',
      PatientSurveyStep.activity => '/survey/activity-levels',
    };
    context.go(previous);
  }

  Future<void> _goNext() async {
    final indexes = switch (widget.step) {
      PatientSurveyStep.painDuration => const [0],
      PatientSurveyStep.painLevel => const [1],
      PatientSurveyStep.activityLevels => const [2, 3],
      PatientSurveyStep.activity => const [4],
    };
    final controller = ref.read(patientOnboardingProvider.notifier);
    if (!controller.hasAnswers(indexes)) {
      AppSnackbar.error(context, 'Please select an answer before continuing.');
      return;
    }

    if (widget.step == PatientSurveyStep.activity) {
      final submitted = await controller.submitSurvey();
      if (!mounted) return;
      if (!submitted) {
        AppSnackbar.error(
          context,
          ref.read(patientOnboardingProvider).errorMessage ??
              'Unable to submit the survey.',
        );
        return;
      }
    }

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
  final String nextLabel;

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
    this.nextLabel = 'Next',
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
                                  label: nextLabel,
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
    final dense = children.length > 5;
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
          SizedBox(height: dense ? 30 : 45),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              SizedBox(height: dense ? 10 : AppSpacing.s20),
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
      constraints: height != null ? BoxConstraints(minHeight: height!) : null,
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

class _PatientFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _PatientFormField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.errorText,
    this.onChanged,
  });

  @override
  State<_PatientFormField> createState() => _PatientFormFieldState();
}

class _PatientFormFieldState extends State<_PatientFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final border = hasError
        ? Border.all(color: const Color(0xFFD32F2F), width: 1.5)
        : _isFocused
            ? Border.all(color: AppPalette.secondaryBlue, width: 1.5)
            : null;

    final input = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(67),
        border: border,
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          cursorColor: AppPalette.secondaryBlue,
          textAlignVertical: TextAlignVertical.center,
          style: AppTypography.heading2.copyWith(color: AppPalette.black),
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            suffixIcon: widget.suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
          ),
        ),
      ),
    );

    final inputWithValidation = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        input,
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 4),
            child: Text(
              widget.errorText!,
              style: AppTypography.captionBody1.copyWith(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: AppTypography.heading2.copyWith(
              color: AppPalette.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          inputWithValidation,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          height: 48,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.label,
              textAlign: TextAlign.right,
              style: AppTypography.heading2.copyWith(color: AppPalette.black),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: inputWithValidation),
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
