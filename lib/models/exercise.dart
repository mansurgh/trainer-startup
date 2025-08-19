class Exercise {
  final String id;
  final String name;
  final String? imageUrl; // PNG/GIF от ExerciseDB

  Exercise({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) {
    final id = (j['id'] ?? j['exerciseId'] ?? '').toString();
    final name = (j['name'] ?? '').toString();
    final image = (j['imageUrl'] ?? j['gifUrl']);
    return Exercise(id: id, name: name, imageUrl: image is String ? image : null);
  }
}
