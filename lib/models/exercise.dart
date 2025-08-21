// lib/models/exercise.dart
class Exercise {
  final String id;
  final String name;
  final String? imageUrl;
  final String? gifUrl;
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    this.imageUrl,
    this.gifUrl,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> m) {
    return Exercise(
      id: (m['id'] ?? m['exerciseId'] ?? m['exercise_id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      imageUrl: (m['imageUrl'] ?? m['image'] ?? m['thumbnail'])?.toString(),
      gifUrl: (m['gifUrl'] ?? m['gif'])?.toString(),
      videoUrl: (m['videoUrl'] ?? m['video'])?.toString(),
    );
  }

  Exercise copyWith({String? gifUrl, String? imageUrl, String? videoUrl}) {
    return Exercise(
      id: id,
      name: name,
      imageUrl: imageUrl ?? this.imageUrl,
      gifUrl: gifUrl ?? this.gifUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
