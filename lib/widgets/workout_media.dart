// lib/widgets/workout_media.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class WorkoutMedia extends StatefulWidget {
  final String? imageUrl;
  final String? gifUrl;
  final String? videoUrl;

  const WorkoutMedia({super.key, this.imageUrl, this.gifUrl, this.videoUrl});

  @override
  State<WorkoutMedia> createState() => _WorkoutMediaState();
}

class _WorkoutMediaState extends State<WorkoutMedia> {
  VideoPlayerController? _video;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    final v = widget.videoUrl;
    if (v != null && v.isNotEmpty) {
      _video = VideoPlayerController.networkUrl(Uri.parse(v));
      _chewie = ChewieController(
        videoPlayerController: _video!,
        autoPlay: true,
        looping: true,
        allowPlaybackSpeedChanging: true,
      );
      _video!.initialize().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1) видео
    if (_chewie != null && _video!.value.isInitialized) {
      return _WhiteCard(
        child: AspectRatio(
          aspectRatio: _video!.value.aspectRatio == 0 ? 16 / 9 : _video!.value.aspectRatio,
          child: Chewie(controller: _chewie!),
        ),
      );
    }

    // 2) gif (приоритет) или картинка
    final mediaUrl = widget.gifUrl?.isNotEmpty == true
        ? widget.gifUrl!
        : (widget.imageUrl ?? '');

    if (mediaUrl.isNotEmpty) {
      return _WhiteCard(
        child: CachedNetworkImage(
          imageUrl: mediaUrl,
          height: 230,
          width: double.infinity,
          fit: BoxFit.contain,
          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Center(child: Text('Ошибка загрузки медиа')),
        ),
      );
    }

    // 3) заглушка - пустой контейнер вместо текста
    return _WhiteCard(
      child: const Center(
        child: SizedBox.shrink(), // Пустой виджет вместо "Медиа недоступно"
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
