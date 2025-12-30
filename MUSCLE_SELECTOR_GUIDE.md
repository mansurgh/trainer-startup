# 🏋️ Muscle Selector Integration Guide

## ✅ Статус: ГОТОВО К ИСПОЛЬЗОВАНИЮ

Интегрирован пакет `muscle_selector` с поддержкой мужского тела. Женское тело использует ту же визуализацию (пакет пока не имеет отдельного female SVG).

---

## 📦 Установленный пакет

```yaml
dependencies:
  muscle_selector: ^1.0.4
```

**Возможности:**
- ✅ Интерактивный выбор групп мышц
- ✅ 18 групп мышц (chest, shoulders, biceps, triceps, abs, legs и т.д.)
- ✅ Pinch-to-zoom и pan навигация
- ✅ Toggle режим (вкл/выкл выбранных мышц)
- ✅ Темная тема

---

## 🎯 Созданные компоненты

### 1. `GenderMuscleSelector` (lib/widgets/gender_muscle_selector.dart)

Базовый виджет с gender параметром:

```dart
GenderMuscleSelector(
  gender: 'male',  // или 'female'
  onChanged: (muscles) {
    // Set<Muscle> с выбранными мышцами
  },
  width: 320,
  height: 500,
  initialSelectedGroups: ['chest', 'shoulders'],
  strokeColor: Colors.white60,
  selectedColor: Color(0xFF00D9FF),
  actAsToggle: true,
)
```

### 2. `ThemedGenderMuscleSelector` (lib/widgets/gender_muscle_selector.dart)

Стилизованный виджет под PulseFit Pro:

```dart
ThemedGenderMuscleSelector(
  gender: userGender,
  onChanged: (muscles) => setState(() => selectedMuscles = muscles),
  width: MediaQuery.of(context).size.width * 0.8,
  height: 450,
  initialSelectedGroups: ['chest', 'abs'],
)
```

**Стилизация:**
- 🎨 OLED Black background
- 🎨 Dark grey card (0xFF1C1C1C)
- 🎨 Neon cyan selection (0xFF00D9FF)
- 🎨 Gender icon в заголовке
- 🎨 Округлые края (20px)

### 3. `MuscleSelectorDemoScreen` (lib/screens/muscle_selector_demo_screen.dart)

Полнофункциональный demo экран:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MuscleSelectorDemoScreen(),
  ),
)
```

**Функционал:**
- 🔄 Male/Female переключатель
- 🧹 Clear selection кнопка
- 📋 Список выбранных мышц с русскими названиями
- 🔍 Pinch-to-zoom и pan
- 📖 Инструкция по использованию

---

## 🛠️ Как использовать в своих экранах

### Вариант А: Простой выбор мышц

```dart
import 'package:muscle_selector/muscle_selector.dart';
import '../widgets/gender_muscle_selector.dart';

class WorkoutPlanScreen extends StatefulWidget {
  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  Set<Muscle> targetMuscles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GenderMuscleSelector(
        gender: 'male',
        onChanged: (muscles) => setState(() => targetMuscles = muscles),
      ),
    );
  }
}
```

### Вариант Б: С начальными группами

```dart
ThemedGenderMuscleSelector(
  gender: userProfile.gender,
  initialSelectedGroups: ['chest', 'shoulders', 'triceps'],
  onChanged: (muscles) {
    // Сохранить в базу или стейт
    workoutPlan.targetMuscles = muscles.map((m) => m.id).toList();
  },
)
```

### Вариант В: С GlobalKey для программного управления

```dart
final GlobalKey<MusclePickerMapState> _mapKey = GlobalKey();

// Очистить выбор программно
_mapKey.currentState?.clearSelect();

// В виджете
MusclePickerMap(
  key: _mapKey,
  map: Maps.BODY,
  onChanged: (muscles) => print(muscles),
)
```

---

## 📚 Доступные группы мышц

```dart
const availableMuscleGroups = [
  'chest',        // Грудь
  'shoulders',    // Плечи
  'biceps',       // Бицепс
  'triceps',      // Трицепс
  'forearm',      // Предплечье
  'abs',          // Пресс
  'obliques',     // Косые мышцы
  'quads',        // Квадрицепс
  'hamstrings',   // Бицепс бедра
  'calves',       // Икры
  'glutes',       // Ягодицы
  'lats',         // Широчайшие
  'upper_back',   // Верх спины
  'lower_back',   // Низ спины
  'trapezius',    // Трапеция
  'neck',         // Шея
  'adductors',    // Приводящие
  'abductor',     // Отводящие
];
```

---

## 🎨 Перевод названий мышц

```dart
String translateMuscle(String muscleId) {
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
  return translations[muscleId] ?? muscleId;
}
```

---

## 🚀 Тестирование

### Путь к demo:
1. Запустить приложение
2. Перейти в **Настройки** (⚙️ в ProfileScreen)
3. Раздел **"О приложении"**
4. Нажать **"Muscle Selector Demo"**

### Проверить:
- ✅ Pinch-to-zoom работает
- ✅ Pan (смахивание) работает
- ✅ Нажатие на мышцу выделяет её синим
- ✅ Повторное нажатие снимает выделение (toggle)
- ✅ Переключение ♂/♀ очищает выбор
- ✅ Кнопка 🗑️ очищает все выделения
- ✅ Список выбранных мышц обновляется в реальном времени

---

## 🔮 Будущие улучшения

### TODO: Женское тело SVG

Пакет `muscle_selector` пока не имеет female SVG. Для полноценной поддержки нужно:

1. **Извлечь данные из react-native-body-highlighter:**
   - GitHub: https://github.com/HichamELBSI/react-native-body-highlighter
   - Файлы: `assets/bodyFemaleFront.ts`, `assets/bodyFemaleBack.ts`

2. **Конвертировать TypeScript → Dart:**
   ```dart
   // Пример структуры
   class FemaleMuscleData {
     static const Map<String, List<String>> musclePaths = {
       'chest': ['m 252.02,456.3 c -3.08,-1.43 ...'],
       'shoulders': ['m 273.89,1099.95 c 3.37,-15.16 ...'],
       // ... остальные группы
     };
   }
   ```

3. **Форкнуть muscle_selector и добавить female_body.svg:**
   - Создать PR в оригинальный репозиторий
   - Или использовать свой форк

4. **Альтернатива: Кастомный рендеринг**
   ```dart
   CustomPaint(
     painter: FemaleMuscleMapPainter(
       selectedMuscles: selectedMuscles,
       musclePaths: FemaleMuscleData.musclePaths,
     ),
   )
   ```

---

## 📝 Примечания

- **Производительность:** SVG рендеринг эффективен, но для больших списков лучше использовать `const` конструкторы
- **Accessibility:** Все виджеты имеют `accessible` и `accessibilityLabel`
- **Responsive:** Используйте `MediaQuery.of(context).size.width * 0.8` для адаптивности

---

## 📞 Интеграция в экраны

### Где можно использовать:

1. **WorkoutPlanScreen** — выбор целевых мышц для плана
2. **ExerciseDetailScreen** — показать задействованные мышцы
3. **ProgressTrackingScreen** — отметить проработанные группы
4. **ProfileScreen** — любимые/приоритетные группы мышц

---

**Дата создания:** 9 декабря 2025  
**Версия пакета:** muscle_selector ^1.0.4  
**Статус:** ✅ Production Ready (мужское тело), ⏸️ Pending (женское тело требует custom SVG)
