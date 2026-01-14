import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../core/modern_components.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../services/noir_toast_service.dart';

class ProgressGalleryScreen extends ConsumerStatefulWidget {
  const ProgressGalleryScreen({super.key});

  @override
  ConsumerState<ProgressGalleryScreen> createState() => _ProgressGalleryScreenState();
}

class _ProgressGalleryScreenState extends ConsumerState<ProgressGalleryScreen> {
  List<String> _progressPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressPhotos();
  }

  Future<void> _loadProgressPhotos() async {
    try {
      final photos = await StorageService.getProgressPhotos();
      setState(() {
        _progressPhotos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        final savedPath = await StorageService.saveProgressPhoto(image.path);
        setState(() {
          _progressPhotos.insert(0, savedPath);
        });
        
        if (mounted) {
          NoirToast.success(context, AppLocalizations.of(context)!.photoAdded);
        }
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, AppLocalizations.of(context)!.error);
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    try {
      final photoPath = _progressPhotos[index];
      await StorageService.deleteProgressPhoto(photoPath);
      setState(() {
        _progressPhotos.removeAt(index);
      });
      
      if (mounted) {
        NoirToast.success(context, AppLocalizations.of(context)!.photoDeleted);
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, AppLocalizations.of(context)!.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.progressGallery,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _progressPhotos.isEmpty
                ? _buildEmptyState()
                : _buildGallery(),
        floatingActionButton: FloatingActionButton(
          onPressed: _addPhoto,
          backgroundColor: const Color(0xFF00D4AA),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          ModernComponents.sexyText(
            AppLocalizations.of(context)!.noProgressPhotos,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ModernComponents.sexyText(
            AppLocalizations.of(context)!.addFirstPhoto,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ModernComponents.animatedButton(
            onPressed: _addPhoto,
            child: Text(
              AppLocalizations.of(context)!.takePhoto,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _progressPhotos.length,
        itemBuilder: (context, index) {
          return _buildPhotoCard(index);
        },
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    final photoPath = _progressPhotos[index];
    final date = DateTime.now().subtract(Duration(days: _progressPhotos.length - index - 1));
    
    return GestureDetector(
      onTap: () => _showPhotoDialog(photoPath, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.file(
                File(photoPath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Градиент сверху
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Дата
              Positioned(
                top: 8,
                left: 8,
                child: Text(
                  '${date.day}.${date.month}.${date.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Кнопка удаления
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _deletePhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDialog(String photoPath, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
