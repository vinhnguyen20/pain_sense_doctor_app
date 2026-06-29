import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/core/providers/storage_provider.dart';
import 'package:app_doctor/features/chats/data/datasources/appointment_remote_datasource.dart';
import 'package:app_doctor/features/chats/data/datasources/chat_remote_datasource.dart';
import 'package:app_doctor/features/chats/data/repository/appointment_repository_impl.dart';
import 'package:app_doctor/features/chats/data/repository/chat_cache_repository_impl.dart';
import 'package:app_doctor/features/chats/data/repository/conversation_repository_impl.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';
import 'package:app_doctor/features/chats/domain/repository/chat_cache_repository.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/clear_cached_conversation_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/create_conversation_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/get_conversation_by_id_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/get_conversations_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/get_messages_page_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/mark_conversation_as_read_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/read_cached_conversation_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/save_cached_conversation_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/send_text_message_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/conversation/upload_message_file_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/appointment/create_appointment_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/appointment/delete_appointment_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/appointment/get_appointment_by_id_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/appointment/get_appointments_by_patient_id_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/appointment/get_appointments_use_case.dart';
import 'package:app_doctor/features/chats/domain/usecases/appointment/update_appointment_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_providers.g.dart';

// ── Chat datasources ───────────────────────────────────────────────────────

@riverpod
ChatRemoteDataSource chatRemoteDataSource(Ref ref) {
  return ChatRemoteDataSource(ref.read(dioClientProvider));
}

@riverpod
AppointmentRemoteDataSource appointmentRemoteDataSource(Ref ref) {
  return AppointmentRemoteDataSource(ref.read(dioClientProvider));
}

// ── Repositories ───────────────────────────────────────────────────────────

@riverpod
ConversationRepository conversationRepository(Ref ref) {
  return ConversationRepositoryImpl(ref.read(chatRemoteDataSourceProvider));
}

@riverpod
ChatCacheRepository chatCacheRepository(Ref ref) {
  return ChatCacheRepositoryImpl(ref.read(sharedPreferencesProvider));
}

@riverpod
AppointmentRepository appointmentRepository(Ref ref) {
  return AppointmentRepositoryImpl(
    ref.read(appointmentRemoteDataSourceProvider),
  );
}

// ── Conversation use cases ─────────────────────────────────────────────────

@riverpod
GetConversationsUseCase getConversationsUseCase(Ref ref) {
  return GetConversationsUseCase(ref.read(conversationRepositoryProvider));
}

@riverpod
CreateConversationUseCase createConversationUseCase(Ref ref) {
  return CreateConversationUseCase(ref.read(conversationRepositoryProvider));
}

@riverpod
GetConversationByIdUseCase getConversationByIdUseCase(Ref ref) {
  return GetConversationByIdUseCase(ref.read(conversationRepositoryProvider));
}

@riverpod
MarkConversationAsReadUseCase markConversationAsReadUseCase(Ref ref) {
  return MarkConversationAsReadUseCase(
    ref.read(conversationRepositoryProvider),
  );
}

@riverpod
GetMessagesPageUseCase getMessagesPageUseCase(Ref ref) {
  return GetMessagesPageUseCase(ref.read(conversationRepositoryProvider));
}

@riverpod
SendTextMessageUseCase sendTextMessageUseCase(Ref ref) {
  return SendTextMessageUseCase(ref.read(conversationRepositoryProvider));
}

@riverpod
UploadMessageFileUseCase uploadMessageFileUseCase(Ref ref) {
  return UploadMessageFileUseCase(ref.read(conversationRepositoryProvider));
}

// ── Cache use cases ────────────────────────────────────────────────────────

@riverpod
ReadCachedConversationUseCase readCachedConversationUseCase(Ref ref) {
  return ReadCachedConversationUseCase(ref.read(chatCacheRepositoryProvider));
}

@riverpod
SaveCachedConversationUseCase saveCachedConversationUseCase(Ref ref) {
  return SaveCachedConversationUseCase(ref.read(chatCacheRepositoryProvider));
}

@riverpod
ClearCachedConversationUseCase clearCachedConversationUseCase(Ref ref) {
  return ClearCachedConversationUseCase(ref.read(chatCacheRepositoryProvider));
}

// ── Appointment use cases ──────────────────────────────────────────────────

@riverpod
GetAppointmentsUseCase getAppointmentsUseCase(Ref ref) {
  return GetAppointmentsUseCase(ref.read(appointmentRepositoryProvider));
}

@riverpod
GetAppointmentByIdUseCase getAppointmentByIdUseCase(Ref ref) {
  return GetAppointmentByIdUseCase(ref.read(appointmentRepositoryProvider));
}

@riverpod
CreateAppointmentUseCase createAppointmentUseCase(Ref ref) {
  return CreateAppointmentUseCase(ref.read(appointmentRepositoryProvider));
}

@riverpod
GetAppointmentsByPatientIdUseCase getAppointmentsByPatientIdUseCase(Ref ref) {
  return GetAppointmentsByPatientIdUseCase(
    ref.read(appointmentRepositoryProvider),
  );
}

@riverpod
DeleteAppointmentUseCase deleteAppointmentUseCase(Ref ref) {
  return DeleteAppointmentUseCase(ref.read(appointmentRepositoryProvider));
}

@riverpod
UpdateAppointmentUseCase updateAppointmentUseCase(Ref ref) {
  return UpdateAppointmentUseCase(ref.read(appointmentRepositoryProvider));
}

