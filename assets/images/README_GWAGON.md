# Инструкция по добавлению изображения G-Wagon

## Где взять изображение:
1. Скачай картинку гелика (Mercedes G-Wagon) из интернета
2. Рекомендуемые параметры:
   - **Формат:** PNG (с прозрачным фоном) или JPG
   - **Размер:** 1024x576 пикселей (16:9) или 800x600 (4:3)
   - **Вес файла:** до 500 KB
   - **Качество:** Высокое разрешение, черный или темный гелик смотрится круче

## Где разместить:
1. Сохрани изображение как `gwagon.png` 
2. Помести файл сюда: `assets/images/gwagon.png`

## Как подключить в pubspec.yaml:
Файл уже настроен! В `pubspec.yaml` должна быть строка:
```yaml
flutter:
  assets:
    - assets/images/
```

## Примеры ссылок для скачивания:
- https://unsplash.com/s/photos/mercedes-g-wagon
- https://www.pexels.com/search/mercedes%20g%20wagon/
- https://pixabay.com/images/search/mercedes-g-class/

## Альтернатива:
Если не хочешь искать картинку, приложение покажет fallback с иконкой машины и текстом "G-Wagon".

## Проверка:
После добавления файла перезапусти приложение:
```bash
flutter run -d windows --dart-define-from-file=secrets.json
```
