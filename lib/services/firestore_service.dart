import '../models/message_model.dart';
import '../models/daily_plan_model.dart';

/// Simple in-memory store; swap with Firebase later.
class FirestoreService {
  final _messages = <String, List<MessageModel>>{}; // userId -> messages
  final _plans = <String, List<DailyPlanModel>>{};  // userId -> plans

  Stream<List<MessageModel>> watchMessages(String userId) async* {
    yield _messages[userId] ?? [];
  }

  Future<void> addMessage(MessageModel m) async {
    final list = _messages.putIfAbsent(m.userId, () => []);
    list.add(m);
  }

  Future<List<DailyPlanModel>> getPlans(String userId) async {
    return _plans[userId] ?? [];
  }

  Future<void> upsertPlan(DailyPlanModel p) async {
    final list = _plans.putIfAbsent(p.userId, () => []);
    final idx = list.indexWhere((e) => e.date.day == p.date.day && e.date.month == p.date.month && e.date.year == p.date.year);
    if (idx >= 0) list[idx] = p; else list.add(p);
  }
}