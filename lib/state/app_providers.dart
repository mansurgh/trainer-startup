import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../models/ai_response.dart';
import '../models/daily_plan_model.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

// Реэкспортируем userProvider из user_state.dart
export 'user_state.dart' show userProvider;

// Services
final aiServiceProvider = Provider((_) => AIService());
final firestoreProvider = Provider((_) => FirestoreService());
final storageProvider = Provider((_) => StorageService());
final authServiceProvider = Provider((_) => AuthService());
final profileServiceProvider = Provider((_) => ProfileService());

// Daily plan (simple per-today plan)
class PlanNotifier extends StateNotifier<DailyPlanModel?> {
  PlanNotifier(this.ref): super(null);
  final Ref ref;

  Future<void> loadForToday(String userId) async {
    final repo = ref.read(firestoreProvider);
    final plans = await repo.getPlans(userId);
    final today = DateTime.now();
    state = plans.firstWhere(
      (p) => p.date.year == today.year && p.date.month == today.month && p.date.day == today.day,
      orElse: () => DailyPlanModel(
        id: 'plan-${today.toIso8601String()}', userId: userId, date: today,
        proteinLeft: 120, targetProtein: 160, supplementsLeft: const ['Creatine', 'Vitamin D3'],
      ),
    );
  }

  Future<void> markWorkoutDone() async {
    if (state == null) return;
    state = state!.copyWith(workoutDone: true);
    await ref.read(firestoreProvider).upsertPlan(state!);
  }
}
final planProvider = StateNotifierProvider<PlanNotifier, DailyPlanModel?>((ref) => PlanNotifier(ref));

// Chat
class ChatNotifier extends StateNotifier<List<MessageModel>> {
  ChatNotifier(this.ref): super([]);
  final Ref ref;

  Future<void> sendText(String userId, String text) async {
    final now = DateTime.now();
    final m = MessageModel(
      id: 'm-$now', userId: userId, actor: MessageActor.user,
      contentType: ContentType.text, content: text, timestamp: now,
    );
    state = [...state, m];

    final ai = ref.read(aiServiceProvider);
    final resp = await ai.getResponse(text);
    final mr = MessageModel(
      id: 'r-$now', userId: userId, actor: MessageActor.assistant,
      contentType: ContentType.aiResponse, aiResponse: resp, timestamp: DateTime.now(),
    );
    state = [...state, mr];
  }
}
final chatProvider = StateNotifierProvider<ChatNotifier, List<MessageModel>>((ref) => ChatNotifier(ref));

// Program (28 days) — store as plain text list from AI
final programProvider = StateProvider<List<String>>((_) => []);