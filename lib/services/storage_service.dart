/// Placeholder for image/video uploads. Replace with Firebase Storage later.
class StorageService {
  Future<String> uploadImage(String localPath) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'local://$localPath';
  }
  Future<String> uploadVideo(String localPath) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'local://$localPath';
  }
}