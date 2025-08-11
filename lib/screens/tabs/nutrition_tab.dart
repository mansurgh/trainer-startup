import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_providers.dart';
import '../chat_screen.dart';

class NutritionTab extends ConsumerStatefulWidget {
  const NutritionTab({super.key});
  @override
  ConsumerState<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends ConsumerState<NutritionTab> {
  String? lastAdvice;
  String? lastMacros;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('Питание', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Фото холодильника/еды → анализ и рецепты', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Загрузить фото', icon: Icons.camera_alt_rounded, onPressed: () async {
              final picker = ImagePicker();
              final img = await picker.pickImage(source: ImageSource.gallery);
              if (img == null) return;
              final ai = ref.read(aiServiceProvider);
              final m = await ai.analyzeFood(img.path);
              final r = await ai.suggestRecipe(img.path);
              setState(() {
                lastAdvice = r.advice;
                if (m.macros != null) {
                  final mm = m.macros!;
                  lastMacros = 'Ккал: ${mm.kcal}, Б: ${mm.protein}г, Ж: ${mm.fat}г, У: ${mm.carbs}г';
                }
              });
            })),
            const SizedBox(width: 12),
            Expanded(child: PrimaryButton(label: 'Открыть чат', icon: Icons.chat_bubble_rounded, onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
            })),
          ]),
        ])),
        const SizedBox(height: 12),
        if (lastAdvice != null || lastMacros != null)
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (lastMacros != null) Text(lastMacros!, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (lastAdvice != null) ...[
              const SizedBox(height: 8),
              Text(lastAdvice!, style: const TextStyle(color: Colors.white70)),
            ],
          ])),
      ],
    );
  }
}