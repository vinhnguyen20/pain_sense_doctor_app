import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_providers.dart';
import 'package:app_doctor/features/survey/data/models/survey_definition_model.dart';
import 'package:app_doctor/features/survey/presentation/provider/survey_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientOnboardingState {
  final PatientRegistration? registration;
  final PatientProfileSetup? profile;
  final SurveyDefinitionModel? survey;
  final Map<int, String> answers;
  final DateTime startedAt;
  final String? accessToken;
  final String? userId;
  final bool registrationCompleted;
  final bool isSubmitting;
  final bool isLoadingSurvey;
  final String? errorMessage;

  const PatientOnboardingState({
    this.registration,
    this.profile,
    this.survey,
    this.answers = const {},
    required this.startedAt,
    this.accessToken,
    this.userId,
    this.registrationCompleted = false,
    this.isSubmitting = false,
    this.isLoadingSurvey = false,
    this.errorMessage,
  });

  PatientOnboardingState copyWith({
    PatientRegistration? registration,
    PatientProfileSetup? profile,
    SurveyDefinitionModel? survey,
    Map<int, String>? answers,
    DateTime? startedAt,
    String? accessToken,
    String? userId,
    bool? registrationCompleted,
    bool? isSubmitting,
    bool? isLoadingSurvey,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PatientOnboardingState(
      registration: registration ?? this.registration,
      profile: profile ?? this.profile,
      survey: survey ?? this.survey,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      registrationCompleted:
          registrationCompleted ?? this.registrationCompleted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingSurvey: isLoadingSurvey ?? this.isLoadingSurvey,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final patientOnboardingProvider =
    NotifierProvider<PatientOnboardingController, PatientOnboardingState>(
      PatientOnboardingController.new,
    );

class PatientOnboardingController extends Notifier<PatientOnboardingState> {
  @override
  PatientOnboardingState build() {
    return PatientOnboardingState(startedAt: DateTime.now());
  }

  Future<bool> registerAccount(PatientRegistration registration) async {
    if (state.registrationCompleted) return true;

    state = state.copyWith(
      registration: registration,
      isSubmitting: true,
      clearError: true,
    );

    try {
      final registrationResult = await ref
          .read(registerPatientUseCaseProvider)
          .call(registration);
      if (registrationResult.isFailure) {
        state = state.copyWith(errorMessage: registrationResult.message);
        return false;
      }

      final loginResult = await ref
          .read(signInWithEmailPasswordUseCaseProvider)
          .call(registration.email, registration.password);
      final token = loginResult.data;
      if (token == null) {
        state = state.copyWith(errorMessage: loginResult.message);
        return false;
      }

      String? userId;
      try {
        final userInfo = await ref
            .read(authRemoteDataSourceProvider)
            .getCurrentUserInfo(token.accessToken);
        userId = userInfo.data?.id;
      } catch (_) {}

      state = state.copyWith(
        registrationCompleted: true,
        accessToken: token.accessToken,
        userId: userId,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        errorMessage: ExceptionHandler.handle(error, stackTrace).message,
      );
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<bool> saveProfileAndLoadSurvey(PatientProfileSetup profile) async {
    final token = state.accessToken;
    if (!state.registrationCompleted || token == null || token.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please complete account registration first.',
      );
      return false;
    }

    state = state.copyWith(
      profile: profile,
      isSubmitting: true,
      clearError: true,
    );

    try {
      String? userId = state.userId;
      if (userId == null || userId.trim().isEmpty) {
        final userInfo = await ref
            .read(authRemoteDataSourceProvider)
            .getCurrentUserInfo(token);
        userId = userInfo.data?.id;
        if (userId != null && userId.trim().isNotEmpty) {
          state = state.copyWith(userId: userId);
        }
      }

      if (userId == null || userId.trim().isEmpty) {
        state = state.copyWith(
          errorMessage: 'Unable to resolve user ID for profile update.',
        );
        return false;
      }

      final profileResult = await ref
          .read(authRemoteDataSourceProvider)
          .updateDoctorProfile(
            userId: userId,
            profile: profile,
            registration: state.registration,
            accessToken: token,
          );
      if (profileResult.isFailure) {
        state = state.copyWith(errorMessage: profileResult.message);
        return false;
      }

      final loaded = await _loadSurvey();
      return loaded;
    } catch (error, stackTrace) {
      state = state.copyWith(
        errorMessage: ExceptionHandler.handle(error, stackTrace).message,
      );
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false, isLoadingSurvey: false);
    }
  }

  Future<bool> ensureSurveyLoaded() async {
    if (state.survey != null) return true;
    if (state.isLoadingSurvey) return false;

    state = state.copyWith(isLoadingSurvey: true, clearError: true);
    try {
      return await _loadSurvey();
    } catch (error, stackTrace) {
      state = state.copyWith(
        errorMessage: ExceptionHandler.handle(error, stackTrace).message,
      );
      return false;
    } finally {
      state = state.copyWith(isLoadingSurvey: false);
    }
  }

  Future<bool> _loadSurvey() async {
    final response = await ref
        .read(surveyRemoteDataSourceProvider)
        .getFirstSurvey();
    final survey = response.data;
    if (response.isFailure || survey == null || survey.questions.length < 5) {
      state = state.copyWith(
        errorMessage: response.isFailure
            ? response.message
            : 'The setup survey is incomplete.',
      );
      return false;
    }

    state = state.copyWith(survey: survey, clearError: true);
    return true;
  }

  void selectAnswer(int questionIndex, String answer) {
    state = state.copyWith(
      answers: {...state.answers, questionIndex: answer},
      clearError: true,
    );
  }

  bool hasAnswers(Iterable<int> questionIndexes) {
    return questionIndexes.every(
      (index) => state.answers[index]?.trim().isNotEmpty == true,
    );
  }

  Future<bool> submitSurvey() async {
    final survey = state.survey;
    final token = state.accessToken;
    if (survey == null || token == null || token.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Survey session is unavailable. Please register again.',
      );
      return false;
    }

    if (!hasAnswers(List.generate(survey.questions.length, (index) => index))) {
      state = state.copyWith(
        errorMessage: 'Please answer every survey question.',
      );
      return false;
    }

    final responses = <UserSurveyResponseModel>[];
    for (var index = 0; index < survey.questions.length; index++) {
      final question = survey.questions[index];
      final answer = state.answers[index]!;
      final option = question.options
          .where((item) => _normalize(item.content) == _normalize(answer))
          .firstOrNull;
      if (option == null || option.id.isEmpty) {
        state = state.copyWith(
          errorMessage: 'A selected survey option is no longer available.',
        );
        return false;
      }
      responses.add(
        UserSurveyResponseModel(
          questionId: question.id,
          selectedOptionIds: [option.id],
        ),
      );
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final response = await ref
          .read(surveyRemoteDataSourceProvider)
          .submitSurvey(
            surveyId: survey.id,
            responses: responses,
            startedAt: state.startedAt,
            accessToken: token,
          );
      if (response.isFailure) {
        state = state.copyWith(errorMessage: response.message);
        return false;
      }
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        errorMessage: ExceptionHandler.handle(error, stackTrace).message,
      );
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  static String _normalize(String value) {
    return value.trim().replaceAll('–', '-').replaceAll('—', '-').toLowerCase();
  }
}
