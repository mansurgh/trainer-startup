import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart' hide kSpaceXS, kSpaceSM, kSpaceMD, kSpaceLG, kSpaceXL, kSpaceXXL, kRadiusSM, kRadiusMD, kRadiusLG, kRadiusXL, kRadiusXXL, kRadiusFull;
import '../theme/noir_theme.dart';
import '../widgets/noir_glass_components.dart';
import '../services/noir_toast_service.dart';
import '../l10n/app_localizations.dart';

/// Helper function to format dates with localized month names (short)
String _formatDateShort(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context)!;
  final months = [
    l10n.janShort, l10n.febShort, l10n.marShort, l10n.aprShort, l10n.mayShort, l10n.junShort,
    l10n.julShort, l10n.augShort, l10n.sepShort, l10n.octShort, l10n.novShort, l10n.decShort
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Helper function to format dates with localized month names (full)
String _formatDateFull(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context)!;
  final months = [
    l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
    l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Progress Photo Gallery Screen - галерея прогресс-фото
class ProgressPhotoGalleryScreen extends ConsumerStatefulWidget {
  const ProgressPhotoGalleryScreen({super.key});

  @override
  ConsumerState<ProgressPhotoGalleryScreen> createState() => _ProgressPhotoGalleryScreenState();
}

class _ProgressPhotoGalleryScreenState extends ConsumerState<ProgressPhotoGalleryScreen> {
  final _supabase = Supabase.instance.client;
  List<ProgressPhoto> _photos = [];
  bool _isLoading = true;
  String? _error;
  bool _didLoadPhotos = false;
  
  @override
  void initState() {
    super.initState();
    // Note: _loadPhotos is called in didChangeDependencies to avoid l10n access before build
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadPhotos) {
      _didLoadPhotos = true;
      _loadPhotos();
    }
  }

  Future<void> _loadPhotos() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _photos = [];
          _isLoading = false;
        });
        return;
      }

      // Check if table exists and has data
      try {
        final response = await _supabase
            .from('progress_photos')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final List<dynamic> data = response as List<dynamic>;
        
        setState(() {
          _photos = data.map((json) => ProgressPhoto.fromJson(json)).toList();
          _isLoading = false;
        });
      } on PostgrestException catch (e) {
        // Table might not exist or RLS policy issue or any Supabase error
        // Common codes: 42P01 (table doesn't exist), PGRST (various)
        debugPrint('[ProgressPhotos] PostgrestException: ${e.code} - ${e.message}');
        setState(() {
          _photos = [];
          _isLoading = false;
          // Don't show error for empty tables or missing relations
          if (e.message.contains('Could not find') || 
              e.code == '42P01' || 
              e.code == 'PGRST116') {
            _error = null;
          } else {
            _error = null; // Silently fail - table may not exist yet
          }
        });
      }
    } catch (e) {
      debugPrint('[ProgressPhotos] Error: $e');
      setState(() {
        _photos = [];
        _isLoading = false;
        _error = null; // Don't show error, just empty state
      });
    }
  }

  Future<void> _addPhoto() async {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: kObsidianSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusLG)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(kSpaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kTextTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text(l10n.addPhoto, style: kDenseHeading),
            const SizedBox(height: kSpaceLG),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpaceSM),
                decoration: BoxDecoration(
                  color: kElectricAmberStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                child: const Icon(Icons.camera_alt, color: kElectricAmberStart),
              ),
              title: Text(l10n.takePhotoCamera, style: kBodyText),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(kSpaceSM),
                decoration: BoxDecoration(
                  color: kInfoCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kRadiusMD),
                ),
                child: const Icon(Icons.photo_library, color: kInfoCyan),
              ),
              title: Text(l10n.chooseFromGallery, style: kBodyText),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Показываем диалог для ввода заметки
      final note = await _showNoteDialog();
      
      setState(() => _isLoading = true);

      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      try {
        // Загружаем в Storage
        final fileBytes = await pickedFile.readAsBytes();
        await _supabase.storage
            .from('progress_photos')
            .uploadBinary(fileName, fileBytes);

        final publicUrl = _supabase.storage
            .from('progress_photos')
            .getPublicUrl(fileName);

        // Сохраняем в базу
        await _supabase.from('progress_photos').insert({
          'user_id': userId,
          'photo_url': publicUrl,
          'note': note,
          'weight': null, // Можно добавить текущий вес
          'created_at': DateTime.now().toIso8601String(),
        });

        await _loadPhotos();
        
        if (mounted) {
          NoirToast.success(context, '📸 ${AppLocalizations.of(context)!.photoAdded}');
        }
      } on PostgrestException catch (e) {
        debugPrint('[ProgressPhotos] Upload error: ${e.code} - ${e.message}');
        setState(() => _isLoading = false);
        if (mounted) {
          // More user-friendly error message
          final l10n = AppLocalizations.of(context)!;
          if (e.message.contains('Could not find') || e.code == '42P01') {
            NoirToast.error(context, l10n.featureNotAvailable);
          } else {
            NoirToast.error(context, l10n.uploadFailed);
          }
        }
      } on StorageException catch (e) {
        debugPrint('[ProgressPhotos] Storage error: ${e.message}');
        setState(() => _isLoading = false);
        if (mounted) {
          NoirToast.error(context, AppLocalizations.of(context)!.uploadFailed);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        debugPrint('[ProgressPhotos] General error: $e');
        NoirToast.error(context, AppLocalizations.of(context)!.somethingWentWrong);
      }
    }
  }

  Future<String?> _showNoteDialog() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(kSpaceLG),
              decoration: BoxDecoration(
                color: kNoirGraphite.withOpacity(0.95),
                borderRadius: BorderRadius.circular(kRadiusXL),
                border: Border.all(color: kNoirSteel.withOpacity(0.5)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.photoNoteTitle, style: kNoirTitleMedium.copyWith(color: kContentHigh)),
                    const SizedBox(height: kSpaceMD),
                    TextField(
                      controller: controller,
                      style: kNoirBodyMedium.copyWith(color: kContentHigh),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.describeProgress,
                        hintStyle: kNoirBodyMedium.copyWith(color: kContentLow),
                        filled: true,
                        fillColor: kNoirBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD),
                          borderSide: BorderSide(color: kBorderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD),
                          borderSide: BorderSide(color: kBorderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kRadiusMD),
                          borderSide: const BorderSide(color: kContentHigh),
                        ),
                      ),
                    ),
                    const SizedBox(height: kSpaceLG),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(foregroundColor: kContentMedium),
                            child: Text(l10n.skip),
                          ),
                        ),
                        const SizedBox(width: kSpaceMD),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, controller.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kContentHigh,
                              foregroundColor: kNoirBlack,
                              padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMD)),
                            ),
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deletePhoto(ProgressPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NoirGlassDialog.showConfirmation(
      context,
      title: l10n.deletePhotoConfirm,
      content: l10n.actionCannotBeUndone,
      icon: Icons.delete_rounded,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      await _supabase.from('progress_photos').delete().eq('id', photo.id);
      await _loadPhotos();
      
      if (mounted) {
        NoirToast.info(context, l10n.photoDeleted);
      }
    } catch (e) {
      if (mounted) {
        NoirToast.error(context, '${l10n.deleteError}: $e');
      }
    }
  }

  void _openPhotoViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewerScreen(
          photos: _photos,
          initialIndex: index,
          onDelete: _deletePhoto,
        ),
      ),
    );
  }

  void _openCompareMode() {
    final l10n = AppLocalizations.of(context)!;
    if (_photos.length < 2) {
      NoirToast.warning(context, l10n.needMinPhotosForCompare);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ComparePhotosScreen(photos: _photos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kOledBlack,
      appBar: AppBar(
        backgroundColor: kOledBlack,
        title: Text(l10n.progressPhotos, style: kDenseHeading),
        actions: [
          if (_photos.length >= 2)
            IconButton(
              onPressed: _openCompareMode,
              icon: const Icon(Icons.compare),
              tooltip: l10n.comparePhotos,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPhoto,
        backgroundColor: kElectricAmberStart,
        foregroundColor: kOledBlack,
        icon: const Icon(Icons.add_a_photo),
        label: Text(l10n.addPhotoShort),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kElectricAmberStart),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: kErrorRed),
            const SizedBox(height: kSpaceMD),
            Text(_error!, style: kBodyText.copyWith(color: kTextSecondary)),
            const SizedBox(height: kSpaceMD),
            ElevatedButton(
              onPressed: _loadPhotos,
              child: Text(l10n.repeatAction),
            ),
          ],
        ),
      );
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kObsidianSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_camera,
                size: 48,
                color: kTextTertiary,
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              l10n.noProgressPhotos,
              style: kDenseHeading.copyWith(color: kTextSecondary),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              l10n.addFirstPhotoHint,
              style: kBodyText.copyWith(color: kTextTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(kSpaceMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: kSpaceSM,
        mainAxisSpacing: kSpaceSM,
        childAspectRatio: 0.75,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return _PhotoCard(
          photo: photo,
          onTap: () => _openPhotoViewer(index),
          onLongPress: () => _deletePhoto(photo),
        );
      },
    );
  }
}

// =============================================================================
// SUPPORTING WIDGETS
// =============================================================================

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photo,
    required this.onTap,
    required this.onLongPress,
  });

  final ProgressPhoto photo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(color: kObsidianBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image.network(
              photo.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: kObsidianSurface,
                child: const Icon(Icons.broken_image, color: kTextTertiary),
              ),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: kObsidianSurface,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: kElectricAmberStart,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
            
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(kSpaceSM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      kOledBlack.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateShort(context, photo.createdAt),
                      style: kCaptionText.copyWith(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (photo.note != null && photo.note!.isNotEmpty)
                      Text(
                        photo.note!,
                        style: kCaptionText.copyWith(
                          color: kTextTertiary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PHOTO VIEWER SCREEN
// =============================================================================

class _PhotoViewerScreen extends StatefulWidget {
  const _PhotoViewerScreen({
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
  });

  final List<ProgressPhoto> photos;
  final int initialIndex;
  final Function(ProgressPhoto) onDelete;

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];
    
    return Scaffold(
      backgroundColor: kOledBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _formatDateFull(context, photo.createdAt),
          style: kBodyText,
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.onDelete(photo);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline, color: kErrorRed),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Photo viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.photos[index].photoUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          
          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                kSpaceLG,
                kSpaceLG,
                kSpaceLG,
                kSpaceLG + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    kOledBlack,
                    kOledBlack.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photo.note != null && photo.note!.isNotEmpty) ...[
                    Text(
                      photo.note!,
                      style: kBodyText.copyWith(color: kTextPrimary),
                    ),
                    const SizedBox(height: kSpaceSM),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.photos.length, (index) {
                      return Container(
                        width: index == _currentIndex ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? kElectricAmberStart
                              : kTextTertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPARE PHOTOS SCREEN
// =============================================================================

class _ComparePhotosScreen extends StatefulWidget {
  const _ComparePhotosScreen({required this.photos});

  final List<ProgressPhoto> photos;

  @override
  State<_ComparePhotosScreen> createState() => _ComparePhotosScreenState();
}

class _ComparePhotosScreenState extends State<_ComparePhotosScreen> {
  late ProgressPhoto _leftPhoto;
  late ProgressPhoto _rightPhoto;

  @override
  void initState() {
    super.initState();
    _leftPhoto = widget.photos.last; // Самое старое
    _rightPhoto = widget.photos.first; // Самое новое
  }

  void _selectPhoto(bool isLeft) async {
    final selected = await showModalBottomSheet<ProgressPhoto>(
      context: context,
      backgroundColor: kObsidianSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusLG)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              const SizedBox(height: kSpaceSM),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: kSpaceMD),
              Text(
                isLeft ? l10n.selectBefore : l10n.selectAfter,
                style: kDenseHeading,
              ),
              const SizedBox(height: kSpaceMD),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(kSpaceMD),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: kSpaceSM,
                    mainAxisSpacing: kSpaceSM,
                  ),
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    return GestureDetector(
                      onTap: () => Navigator.pop(ctx, photo),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kRadiusSM),
                          border: Border.all(
                            color: (isLeft && photo == _leftPhoto) ||
                                    (!isLeft && photo == _rightPhoto)
                                ? kElectricAmberStart
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          photo.photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isLeft) {
          _leftPhoto = selected;
        } else {
          _rightPhoto = selected;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kOledBlack,
      appBar: AppBar(
        backgroundColor: kOledBlack,
        title: Text(l10n.comparison, style: kDenseHeading),
      ),
      body: Column(
        children: [
          // Photos comparison
          Expanded(
            child: Row(
              children: [
                // Left (Before)
                Expanded(
                  child: _ComparePhotoCard(
                    photo: _leftPhoto,
                    label: l10n.before,
                    onTap: () => _selectPhoto(true),
                  ),
                ),
                Container(width: 2, color: kElectricAmberStart),
                // Right (After)
                Expanded(
                  child: _ComparePhotoCard(
                    photo: _rightPhoto,
                    label: l10n.after,
                    onTap: () => _selectPhoto(false),
                  ),
                ),
              ],
            ),
          ),
          
          // Time difference
          Container(
            padding: EdgeInsets.fromLTRB(
              kSpaceLG,
              kSpaceMD,
              kSpaceLG,
              kSpaceMD + MediaQuery.of(context).padding.bottom,
            ),
            color: kObsidianSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 16, color: kTextTertiary),
                const SizedBox(width: kSpaceSM),
                Text(
                  '${l10n.difference}: ${_getDifferenceText(context)}',
                  style: kBodyText.copyWith(color: kTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDifferenceText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final diff = _rightPhoto.createdAt.difference(_leftPhoto.createdAt);
    final days = diff.inDays.abs();
    
    if (days == 0) return l10n.lessThanOneDay;
    if (days == 1) return l10n.oneDay;
    if (days < 7) return l10n.daysPlural(days);
    if (days < 30) return l10n.weeksPlural((days / 7).round());
    if (days < 365) return l10n.monthsPlural((days / 30).round());
    return l10n.yearsPlural((days / 365).round());
  }
}

class _ComparePhotoCard extends StatelessWidget {
  const _ComparePhotoCard({
    required this.photo,
    required this.label,
    required this.onTap,
  });

  final ProgressPhoto photo;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photo.photoUrl,
            fit: BoxFit.cover,
          ),
          
          // Label
          Positioned(
            top: kSpaceSM,
            left: kSpaceSM,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpaceSM,
                vertical: kSpaceXS,
              ),
              decoration: BoxDecoration(
                color: kOledBlack.withOpacity(0.7),
                borderRadius: BorderRadius.circular(kRadiusFull),
              ),
              child: Text(
                label,
                style: kCaptionText.copyWith(
                  color: kElectricAmberStart,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Date
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(kSpaceSM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [kOledBlack.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: Text(
                _formatDateShort(context, photo.createdAt),
                style: kCaptionText.copyWith(color: kTextPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Tap to change hint
          Positioned(
            top: kSpaceSM,
            right: kSpaceSM,
            child: Container(
              padding: const EdgeInsets.all(kSpaceXS),
              decoration: BoxDecoration(
                color: kOledBlack.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_horiz,
                size: 16,
                color: kTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DATA MODEL
// =============================================================================

class ProgressPhoto {
  final String id;
  final String userId;
  final String photoUrl;
  final String? note;
  final double? weight;
  final DateTime createdAt;

  ProgressPhoto({
    required this.id,
    required this.userId,
    required this.photoUrl,
    this.note,
    this.weight,
    required this.createdAt,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      photoUrl: json['photo_url'] as String,
      note: json['note'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
