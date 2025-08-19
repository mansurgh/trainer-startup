import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoCoachScreen extends StatefulWidget {
  const VideoCoachScreen({super.key});
  @override
  State<VideoCoachScreen> createState() => _VideoCoachScreenState();
}

class _VideoCoachScreenState extends State<VideoCoachScreen> {
  VideoPlayerController? _ctrl;
  bool _initializing = false;
  String? _advice;

  final _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;

    _advice = null;
    _ctrl?.dispose();
    setState(() => _initializing = true);

    try {
      final c = VideoPlayerController.file(File(x.path));
      // таймаут на всякий
      await c.initialize().timeout(const Duration(seconds: 6));
      c.setLooping(true);
      await c.play();
      if (!mounted) return;
      setState(() {
        _ctrl = c;
        _initializing = false;
        _advice = _defaultAdvice();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ctrl = null;
        _initializing = false;
        _advice = _defaultAdvice(); // даже если видео не воспроизвелось — советы показываем
      });
    }
  }

  String _defaultAdvice() =>
      '• Своди лопатки и опирайся на них\n'
      '• Стопы прижаты к полу\n'
      '• Негатив 2–3 сек, без «отскока»\n'
      '• Не выпрямляй локти до конца\n'
      '• Полный диапазон под контролем';

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Видео‑коуч')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: _initializing
                        ? const Center(child: CircularProgressIndicator())
                        : (_ctrl == null
                            ? const SizedBox()
                            : AspectRatio(
                                aspectRatio: _ctrl!.value.aspectRatio,
                                child: VideoPlayer(_ctrl!),
                              )),
                  ),
                  if (_ctrl == null && !_initializing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.45),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(.08)),
                        ),
                        child: const Text(
                          'Скинь короткое видео (10–20 сек) — подскажу, как улучшить технику.\nПоддерживаются .mp4 / .mov.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_advice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: Text(_advice!, style: const TextStyle(height: 1.3)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FilledButton.tonal(
                onPressed: _pickVideo,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.video_library_rounded), SizedBox(width: 8), Text('Загрузить видео')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
