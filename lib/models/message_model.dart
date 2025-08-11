import 'ai_response.dart';

class MessageModel {
  final String id;
  final String userId;
  final MessageActor actor; // user/assistant
  final ContentType contentType; // text/image/aiResponse
  final String? content; // text
  final String? imageUrl; // local path or remote
  final AIResponse? aiResponse;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.userId,
    required this.actor,
    required this.contentType,
    this.content,
    this.imageUrl,
    this.aiResponse,
    required this.timestamp,
  });
}