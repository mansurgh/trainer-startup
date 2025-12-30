# SVG Muscle Assets Specifications

## Общие требования

### Размер холста (Artboard)
- **Ширина:** 300px
- **Высота:** 500px
- **Aspect Ratio:** 3:5 (0.6)

### Формат файлов
- **Формат:** SVG (Scalable Vector Graphics)
- **Цвет заливки:** Белый (`#FFFFFF`) или без заливки (код окрасит программно)
- **Обводка:** Нет (stroke: none)
- **Opacity:** 1.0 (непрозрачный)

---

## Список необходимых SVG файлов

### Вид спереди (Front View)
Все координаты относительно холста 300x500px:

| Файл | Мышца | Примерные границы (x, y, width, height) |
|------|-------|----------------------------------------|
| `body_silhouette_front.svg` | Силуэт тела (контур) | 50, 20, 200, 460 |
| `chest.svg` | Грудные мышцы | 85, 120, 130, 60 |
| `abs.svg` | Пресс (6 кубиков) | 115, 185, 70, 90 |
| `shoulders_front.svg` | Передние дельты | 70, 100, 160, 35 |
| `biceps_left.svg` | Левый бицепс | 50, 145, 35, 70 |
| `biceps_right.svg` | Правый бицепс | 215, 145, 35, 70 |
| `forearms_front_left.svg` | Левое предплечье | 35, 220, 30, 70 |
| `forearms_front_right.svg` | Правое предплечье | 235, 220, 30, 70 |
| `quadriceps_left.svg` | Левый квадрицепс | 95, 290, 45, 100 |
| `quadriceps_right.svg` | Правый квадрицепс | 160, 290, 45, 100 |
| `obliques_left.svg` | Левые косые | 85, 185, 30, 70 |
| `obliques_right.svg` | Правые косые | 185, 185, 30, 70 |

### Вид сзади (Back View)

| Файл | Мышца | Примерные границы (x, y, width, height) |
|------|-------|----------------------------------------|
| `body_silhouette_back.svg` | Силуэт тела сзади | 50, 20, 200, 460 |
| `traps.svg` | Трапеции | 100, 75, 100, 50 |
| `lats_left.svg` | Левые широчайшие | 75, 130, 50, 80 |
| `lats_right.svg` | Правые широчайшие | 175, 130, 50, 80 |
| `lower_back.svg` | Поясница | 115, 210, 70, 50 |
| `rear_delts_left.svg` | Левая задняя дельта | 65, 100, 35, 30 |
| `rear_delts_right.svg` | Правая задняя дельта | 200, 100, 35, 30 |
| `triceps_left.svg` | Левый трицепс | 45, 145, 35, 65 |
| `triceps_right.svg` | Правый трицепс | 220, 145, 35, 65 |
| `glutes.svg` | Ягодицы | 100, 260, 100, 60 |
| `hamstrings_left.svg` | Левый бицепс бедра | 100, 325, 40, 90 |
| `hamstrings_right.svg` | Правый бицепс бедра | 160, 325, 40, 90 |
| `calves_left.svg` | Левая икра | 105, 420, 35, 60 |
| `calves_right.svg` | Правая икра | 160, 420, 35, 60 |

---

## Инструкции по созданию SVG

### В Figma:
1. Создай Frame 300x500px
2. Нарисуй силуэт тела (можно использовать reference)
3. Каждую мышцу — отдельный слой/компонент
4. Export каждый слой как отдельный SVG
5. Используй **Fill: #FFFFFF** (белый)
6. Убедись что **Stroke: None**

### В Adobe Illustrator:
1. Artboard: 300x500px
2. Каждая мышца на отдельном слое
3. File → Export → Export As → SVG
4. Опции: Presentation Attributes, Inline Style

### В Inkscape:
1. Document Properties: 300x500px
2. Каждая мышца — отдельный path
3. File → Save As → Plain SVG

---

## Структура папки после подготовки

```
assets/images/muscles/
├── SVG_SPECIFICATIONS.md (этот файл)
├── front/
│   ├── body_silhouette_front.svg
│   ├── chest.svg
│   ├── abs.svg
│   ├── shoulders_front.svg
│   ├── biceps_left.svg
│   ├── biceps_right.svg
│   ├── forearms_front_left.svg
│   ├── forearms_front_right.svg
│   ├── quadriceps_left.svg
│   ├── quadriceps_right.svg
│   ├── obliques_left.svg
│   └── obliques_right.svg
└── back/
    ├── body_silhouette_back.svg
    ├── traps.svg
    ├── lats_left.svg
    ├── lats_right.svg
    ├── lower_back.svg
    ├── rear_delts_left.svg
    ├── rear_delts_right.svg
    ├── triceps_left.svg
    ├── triceps_right.svg
    ├── glutes.svg
    ├── hamstrings_left.svg
    ├── hamstrings_right.svg
    ├── calves_left.svg
    └── calves_right.svg
```

---

## Пример SVG кода (chest.svg)

```xml
<svg width="130" height="60" viewBox="0 0 130 60" xmlns="http://www.w3.org/2000/svg">
  <path d="M10 30 Q15 5 65 5 Q115 5 120 30 Q115 55 65 50 Q15 55 10 30 Z" 
        fill="#FFFFFF" 
        fill-opacity="1"/>
</svg>
```

---

## Важно для интеграции

1. **Все SVG должны иметь viewBox** с правильными размерами
2. **Белая заливка** — код заменит её на нужный цвет через `ColorFilter`
3. **Без transform** — позиционирование через Stack + Positioned в коде
4. **Простые пути** — избегайте clipPath, mask, filter внутри SVG

---

## После подготовки ассетов

Когда SVG файлы будут готовы, сообщите мне, и я:
1. Добавлю их в `pubspec.yaml`
2. Обновлю `muscle_map_widget.dart` для использования реальных SVG
3. Настрою интерактивные зоны через `flutter_svg` + `GestureDetector`

---

## Альтернатива (если нет времени на SVG)

Если не хотите создавать SVG, я могу:
1. Использовать `CustomPainter` для рисования мышц программно
2. Использовать готовые иконки из `flutter_svg` пакетов
3. Использовать PNG с прозрачным фоном вместо SVG

Сообщите, какой вариант предпочитаете!
