// =============================================================================
// muscle_selector_demo_screen.dart — Demo Screen for Testing Muscle Selector
// =============================================================================
// Demonstrates gender-aware muscle selection:
// - Male/Female toggle
// - Selected muscles display
// - Dark theme integration
// - Clear selection button
// =============================================================================

import 'package:flutter/material.dart';
import 'package:muscle_selector/muscle_selector.dart';
import '../widgets/gender_muscle_selector.dart';

class MuscleSelectorDemoScreen extends StatefulWidget {
  const MuscleSelectorDemoScreen({super.key});

  @override
  State<MuscleSelectorDemoScreen> createState() => _MuscleSelectorDemoScreenState();
}

class _MuscleSelectorDemoScreenState extends State<MuscleSelectorDemoScreen> {
  Set<Muscle> selectedMuscles = {};
  String gender = 'male'; // 'male' or 'female'
  final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // OLED Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Muscle Selector Demo',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Clear button
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.red),
            onPressed: () {
              _mapKey.currentState?.clearSelect();
              setState(() {
                selectedMuscles.clear();
              });
            },
          ),
          
          // Gender toggle
          IconButton(
            icon: Icon(
              gender == 'male' ? Icons.male : Icons.female,
              color: const Color(0xFF00D9FF),
            ),
            onPressed: () {
              setState(() {
                gender = gender == 'male' ? 'female' : 'male';
                selectedMuscles.clear();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gender indicator card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      gender == 'male' ? Icons.male : Icons.female,
                      color: const Color(0xFF00D9FF),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      gender == 'male' ? 'Мужское тело' : 'Женское тело',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Нажми иконку для переключения',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Muscle selector
              Center(
                child: InteractiveViewer(
                  scaleEnabled: true,
                  panEnabled: true,
                  constrained: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: MusclePickerMap(
                      key: _mapKey,
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 500,
                      map: Maps.BODY,
                      isEditing: false,
                      onChanged: (muscles) {
                        setState(() {
                          selectedMuscles = muscles;
                        });
                      },
                      actAsToggle: true,
                      dotColor: Colors.black,
                      selectedColor: const Color(0xFF00D9FF).withOpacity(0.7),
                      strokeColor: Colors.white38,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Selected muscles display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00D9FF),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Выбранные группы мышц',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D9FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${selectedMuscles.length}',
                            style: const TextStyle(
                              color: Color(0xFF00D9FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (selectedMuscles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Выберите группы мышц на диаграмме выше',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedMuscles.map((muscle) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D9FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00D9FF),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fitness_center,
                                  color: Color(0xFF00D9FF),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _translateMuscleTitle(muscle.title),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Instructions card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF00D9FF),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Как использовать',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction('• Нажмите на группу мышц для выбора/отмены'),
                    _buildInstruction('• Используйте pinch-to-zoom для увеличения'),
                    _buildInstruction('• Смахивайте для перемещения'),
                    _buildInstruction('• Кнопка 🗑️ для очистки выбора'),
                    _buildInstruction('• Кнопка ♂/♀ для смены пола'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
        ),
      ),
    );
  }

  String _translateMuscleTitle(String title) {
    // Translation map for muscle titles
    const translations = {
      'chest': 'Грудь',
      'shoulders': 'Плечи',
      'biceps': 'Бицепс',
      'triceps': 'Трицепс',
      'forearm': 'Предплечье',
      'abs': 'Пресс',
      'obliques': 'Косые мышцы',
      'quads': 'Квадрицепс',
      'hamstrings': 'Бицепс бедра',
      'calves': 'Икры',
      'glutes': 'Ягодицы',
      'lats': 'Широчайшие',
      'upper_back': 'Верх спины',
      'lower_back': 'Низ спины',
      'trapezius': 'Трапеция',
      'neck': 'Шея',
      'adductors': 'Приводящие',
      'abductor': 'Отводящие',
    };
    
    return translations[title.toLowerCase()] ?? title;
  }
}
