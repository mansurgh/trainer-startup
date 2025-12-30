# 🚀 План добавления женского тела в Muscle Selector

## 🎯 Цель
Добавить визуализацию женского тела с теми же группами мышц, что и у мужского.

---

## 📋 Шаг 1: Извлечь данные из GitHub

### Источник:
https://github.com/HichamELBSI/react-native-body-highlighter

### Файлы для скачивания:
1. `assets/bodyFemaleFront.ts` — передняя часть тела
2. `assets/bodyFemaleBack.ts` — задняя часть тела
3. `components/SvgFemaleWrapper.tsx` — компонент обертки

### Формат данных:
```typescript
export const bodyFemaleFront: BodyPart[] = [
  {
    slug: "chest",
    color: "#454545",
    path: {
      left: ["m 252.02,456.3 c -3.08,-1.43 ..."],
      right: ["m 300.31,556.68 q -4.15,-2.21 ..."],
      common: []
    }
  },
  // ... остальные группы
]
```

---

## 🔧 Шаг 2: Конвертировать TypeScript → Dart

### Создать файл: `lib/data/female_muscle_paths.dart`

```dart
class FemaleMuscleData {
  static const Map<String, Map<String, List<String>>> musclePaths = {
    'chest': {
      'left': [
        'm 252.02,456.3 c -3.08,-1.43 -6.59,-6.27 -8.84,-9.51 ...',
      ],
      'right': [
        'm 300.31,556.68 q -4.15,-2.21 -8.98,-2.91 ...',
      ],
      'common': [],
    },
    'shoulders': {
      'left': ['m 259.53,441.27 c -6.09,-0.94 ...'],
      'right': ['m 349.65,553.77 c -5.34,0.78 ...'],
    },
    'abs': {
      'common': [
        'm 263.89,560.38 c 18.37,-2.6 ...',
        'm 288.4,985.22 q 1.73,22.58 ...',
      ],
    },
    'biceps': {
      'left': ['m 176.77,536.74 c -5.58,2.64 ...'],
      'right': ['m 478.46,543.49 c -4.04,-2.35 ...'],
    },
    'triceps': {
      'left': ['m 1205.91,583.12 c 0.67,-13.86 ...'],
      'right': ['...'],
    },
    'quads': {
      'left': ['m 273.89,1099.95 c 3.37,-15.16 ...'],
      'right': ['...'],
    },
    'hamstrings': {
      'left': ['m 1098.11,859.08 c 1.35,28.16 ...'],
      'right': ['...'],
    },
    'calves': {
      'left': ['...'],
      'right': ['...'],
    },
    'glutes': {
      'left': ['...'],
      'right': ['...'],
    },
    'lats': {
      'left': ['...'],
      'right': ['...'],
    },
    'upper_back': {
      'left': ['...'],
      'right': ['...'],
    },
    'lower_back': {
      'common': ['m 1068.62,544.21 c 7.96,11.18 ...'],
    },
    'trapezius': {
      'common': ['m 1164.71,218.73 c 1.42,12.25 ...'],
    },
    'obliques': {
      'left': ['...'],
      'right': ['...'],
    },
    'forearm': {
      'left': ['...'],
      'right': ['...'],
    },
    'neck': {
      'common': ['m 332.05,262.18 c -0.78,8.99 ...'],
    },
    'adductors': {
      'left': ['...'],
      'right': ['...'],
    },
    'abductor': {
      'left': ['...'],
      'right': ['...'],
    },
  };
}
```

---

## 🎨 Шаг 3: Создать Custom Painter

### Файл: `lib/widgets/female_muscle_painter.dart`

```dart
import 'package:flutter/material.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import '../data/female_muscle_paths.dart';

class FemaleMuscleMapPainter extends CustomPainter {
  final Set<String> selectedMuscleGroups;
  final Color strokeColor;
  final Color selectedColor;
  final Color backgroundColor;

  FemaleMuscleMapPainter({
    required this.selectedMuscleGroups,
    this.strokeColor = Colors.white60,
    this.selectedColor = const Color(0xFF00D9FF),
    this.backgroundColor = Colors.transparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Рисуем фон (силуэт тела)
    final bgPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    // 2. Рисуем каждую группу мышц
    FemaleMuscleData.musclePaths.forEach((muscleGroup, paths) {
      final isSelected = selectedMuscleGroups.contains(muscleGroup);
      
      final paint = Paint()
        ..color = isSelected ? selectedColor : Colors.transparent
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Рисуем left
      paths['left']?.forEach((pathData) {
        final path = parseSvgPath(pathData);
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      });

      // Рисуем right
      paths['right']?.forEach((pathData) {
        final path = parseSvgPath(pathData);
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      });

      // Рисуем common
      paths['common']?.forEach((pathData) {
        final path = parseSvgPath(pathData);
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      });
    });
  }

  @override
  bool shouldRepaint(FemaleMuscleMapPainter oldDelegate) {
    return oldDelegate.selectedMuscleGroups != selectedMuscleGroups;
  }

  @override
  bool hitTest(Offset position) => true;
}
```

---

## 🖱️ Шаг 4: Добавить GestureDetector

### Файл: `lib/widgets/female_muscle_selector_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'female_muscle_painter.dart';

class FemaleMuscleSelector extends StatefulWidget {
  final Function(Set<String> selectedMuscles) onChanged;
  final double width;
  final double height;

  const FemaleMuscleSelector({
    super.key,
    required this.onChanged,
    this.width = 320,
    this.height = 500,
  });

  @override
  State<FemaleMuscleSelector> createState() => _FemaleMuscleSelectorState();
}

class _FemaleMuscleSelectorState extends State<FemaleMuscleSelector> {
  Set<String> selectedMuscles = {};

  void _handleTap(Offset localPosition) {
    // TODO: Определить какая мышца была нажата
    // Используя path.contains(localPosition)
    
    // Пример:
    String? tappedMuscle = _detectMuscleAtPosition(localPosition);
    if (tappedMuscle != null) {
      HapticFeedback.lightImpact();
      setState(() {
        if (selectedMuscles.contains(tappedMuscle)) {
          selectedMuscles.remove(tappedMuscle);
        } else {
          selectedMuscles.add(tappedMuscle);
        }
      });
      widget.onChanged(selectedMuscles);
    }
  }

  String? _detectMuscleAtPosition(Offset position) {
    // Iterate через все группы мышц
    // Проверить path.contains(position)
    // Вернуть первое совпадение
    return null; // TODO: Implement
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition),
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: FemaleMuscleMapPainter(
          selectedMuscleGroups: selectedMuscles,
        ),
      ),
    );
  }
}
```

---

## 🔄 Шаг 5: Обновить GenderMuscleSelector

### В `lib/widgets/gender_muscle_selector.dart`:

```dart
@override
Widget build(BuildContext context) {
  // Если женское тело — использовать кастомный виджет
  if (gender == 'female') {
    return InteractiveViewer(
      scaleEnabled: true,
      panEnabled: true,
      child: FemaleMuscleSelector(
        width: width ?? 320,
        height: height ?? 500,
        onChanged: (muscleIds) {
          // Конвертировать Set<String> в Set<Muscle>
          final muscles = muscleIds.map((id) => Muscle(
            id: id,
            title: id,
            path: Path(), // Dummy path
          )).toSet();
          onChanged(muscles);
        },
      ),
    );
  }

  // Мужское тело — использовать muscle_selector пакет
  return InteractiveViewer(
    ...
  );
}
```

---

## ✅ Шаг 6: Тестирование

1. Запустить `MuscleSelectorDemoScreen`
2. Переключить на ♀ (female)
3. Проверить:
   - ✅ Отображается женское тело
   - ✅ Можно выбирать мышцы
   - ✅ Pinch-to-zoom работает
   - ✅ Выбранные мышцы подсвечиваются

---

## 📦 Альтернатива: Форк muscle_selector

Вместо кастомного рендеринга можно:

1. Форкнуть https://github.com/EmilCes/muscle_selector
2. Добавить `assets/female_body.svg`
3. Обновить `Parser.svgToMuscleList()` для поддержки gender параметра
4. Создать PR в оригинальный репозиторий
5. Использовать свой форк в `pubspec.yaml`:

```yaml
dependencies:
  muscle_selector:
    git:
      url: https://github.com/YOUR_USERNAME/muscle_selector.git
      ref: female-body-support
```

---

## 🎯 Результат

После выполнения всех шагов:
- ✅ Male body: работает через muscle_selector пакет
- ✅ Female body: работает через кастомный FemaleMuscleSelector
- ✅ Унифицированный API через GenderMuscleSelector
- ✅ Полная интеграция в PulseFit Pro

---

**Оценка времени:** ~4-6 часов  
**Сложность:** Средняя (требует работы с SVG paths и Canvas API)
