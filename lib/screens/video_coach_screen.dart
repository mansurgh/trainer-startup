import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../state/app_providers.dart';

class VideoCoachScreen extends ConsumerStatefulWidget {
  const VideoCoachScreen({super.key});
  @override
  ConsumerState<VideoCoachScreen> createState() => _VideoCoachScreenState();
}

class _VideoCoachScreenState extends ConsumerState<VideoCoachScreen> {
  String? tips;
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Видео‑коуч')),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Запиши короткий клип подхода (или выбери из галереи) и получи 3–6 советов по технике.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Выбрать видео', icon: Icons.videocam_rounded, onPressed: () async {
              final picker = ImagePicker();
              final v = await picker.pickVideo(source: ImageSource.gallery);
              if (v == null) return;
              final ai = ref.read(aiServiceProvider);
              final resp = await ai.analyzeVideo(videoPath: v.path, exerciseName: 'squat');
              setState(() => tips = resp.advice);
            }),
            const SizedBox(height: 12),
            if (tips != null) GlassCard(child: Text(tips!, style: const TextStyle(color: Colors.white70))),
          ]),
        ),
      ),
    );
  }
}