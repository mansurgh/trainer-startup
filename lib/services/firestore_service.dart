import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/daily_plan_model.dart';

/// Простая in‑memory заглушка Firestore.
/// Сообщения + дневные планы с минимальным CRUD.
/// Добавлены методы getPlans / upsertPlan, чтобы не падали провайдеры.
class FirestoreService {
  // Сообщения (messageId -> MessageModel)
  final _messages = SplayTreeMap<String, MessageModel>();
  // Планы (ключ "userId|yyyy-mm-dd")
  final _plans = <String, DailyPlanModel>{};

  // ===== Messages =====
  Future<void> saveMessage(MessageModel m) async {
    _messages[m.id] = m;
  }

  Future<List<MessageModel>> getMessages(String userId) async {
    final res = _messages.values
        .where((e) => e.userId == userId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return res;
  }

  Future<void> deleteMessage(String id) async {
    if (_messages[id] != null) {
      _messages.remove(id);
    }
  }

  // ===== Plans =====
  /// Вернуть ВСЕ планы пользователя (отсортированы по дате по возрастанию)
  Future<List<DailyPlanModel>> getPlans(String userId) async {
    final res = _plans.values
        .where((p) => p.userId == userId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return res;
  }

  /// Получить план на конкретную дату
  Future<DailyPlanModel?> getPlanFor(String userId, DateTime date) async {
    final key = _planKey(userId, date);
    return _plans[key];
  }

  /// Создать/обновить план (upsert)
  Future<void> upsertPlan(DailyPlanModel plan) async {
    final key = _planKey(plan.userId, plan.date);
    _plans[key] = plan;
  }

  /// Сохранить план (совместимость со старым кодом)
  Future<void> savePlan(DailyPlanModel plan) => upsertPlan(plan);

  /// Пометить тренировку выполненной на сегодня
  Future<void> markTodayWorkoutDone(String userId) async {
    final now = DateTime.now();
    final key = _planKey(userId, now);
    final current = _plans[key];
    if (current != null) {
      _plans[key] = current.copyWith(workoutDone: true);
    } else {
      _plans[key] = DailyPlanModel(
        id: '${userId}_${_ymd(now)}',
        userId: userId,
        date: DateTime(now.year, now.month, now.day),
        workoutDone: true,
        proteinLeft: 0,
        supplementsLeft: const [],
        targetProtein: 0,
        targetSupplements: const [],
      );
    }
  }

  // ===== Utils =====
  @visibleForTesting
  void clearAll() {
    _messages.clear();
    _plans.clear();
  }

  String _planKey(String userId, DateTime date) => '$userId|${_ymd(date)}';
  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
