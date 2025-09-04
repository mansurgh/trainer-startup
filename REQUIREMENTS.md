# 📋 System Requirements

## Минимальные требования для запуска PulseFit Pro

### 🖥️ Операционная система
- **Windows**: 10 версия 1903 или выше (64-bit)
- **macOS**: 10.14 (Mojave) или выше
- **Linux**: Ubuntu 18.04 LTS или выше

### 💻 Аппаратные требования
- **RAM**: 4 GB (рекомендуется 8 GB)
- **Дисковое пространство**: 2 GB свободного места
- **Процессор**: 64-bit архитектура

### 🔧 Программное обеспечение

#### Обязательные компоненты
1. **Flutter SDK** версия 3.4.0 или выше
2. **Git** для клонирования репозитория
3. **IDE** (Visual Studio Code, Android Studio, или IntelliJ IDEA)

#### Платформо-специфичные требования

### Windows
- **Visual Studio 2022** с компонентами:
  - Desktop development with C++
  - Windows 10/11 SDK
  - CMake tools for C++
- **PowerShell** 5.0 или выше

### macOS
- **Xcode** 14.0 или выше
- **CocoaPods** для iOS зависимостей
- **Command Line Tools** для Xcode

### Linux
- **GCC** компилятор
- **CMake** 3.10 или выше
- **Ninja** build system
- **pkg-config**
- **libgtk-3-dev** (для GTK)

### Android (опционально)
- **Android Studio** с Android SDK
- **Android SDK Platform** API 21 или выше
- **Android Virtual Device** (AVD)

### iOS (только macOS)
- **Xcode** 14.0 или выше
- **iOS Simulator** или физическое устройство
- **CocoaPods** 1.10.0 или выше

## 📦 Зависимости проекта

### Основные пакеты
- `flutter_riverpod: ^2.5.1` - Управление состоянием
- `google_fonts: ^6.2.1` - Шрифты Google
- `flutter_animate: ^4.5.0` - Анимации
- `image_picker: ^1.1.2` - Выбор изображений
- `video_player: ^2.8.6` - Воспроизведение видео

### Дополнительные пакеты
- `window_manager: ^0.3.9` - Управление окнами
- `http: ^1.2.2` - HTTP запросы
- `cached_network_image: ^3.4.1` - Кэширование изображений
- `chewie: ^1.7.5` - Видео плеер
- `flutter_dotenv: ^5.1.0` - Переменные окружения

## 🔍 Проверка установки

### Команда проверки
```bash
flutter doctor
```

### Ожидаемый результат
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.0, on Microsoft Windows, locale ru-RU)
[✓] Windows Version (Installed version of Windows is Version 10.0.22631 Build 22631)
[✓] Visual Studio - develop for Windows (Visual Studio Community 2022 17.8.5)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Chrome - develop for the web
[✓] Visual Studio Code (version 1.85.1)
[✓] Connected device (2 available)
[✓] Network resources
```

## 🚨 Устранение неполадок

### Частые проблемы

#### 1. Flutter не найден
```bash
# Добавьте Flutter в PATH
export PATH="$PATH:/path/to/flutter/bin"
```

#### 2. Visual Studio не найден (Windows)
- Установите Visual Studio 2022 с C++ компонентами
- Перезапустите командную строку

#### 3. Android SDK не найден
- Установите Android Studio
- Настройте Android SDK через SDK Manager

#### 4. Xcode не найден (macOS)
- Установите Xcode из App Store
- Примите лицензионное соглашение: `sudo xcodebuild -license accept`

## 📱 Поддерживаемые платформы

### Полная поддержка
- ✅ **Windows** (Desktop)
- ✅ **Android** (Mobile)
- ✅ **iOS** (Mobile)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

### Экспериментальная поддержка
- 🔄 **Linux** (Desktop)
- 🔄 **macOS** (Desktop)

## 🔄 Обновления

### Flutter SDK
```bash
flutter upgrade
```

### Зависимости проекта
```bash
flutter pub upgrade
```

### Очистка кэша
```bash
flutter clean
flutter pub get
```

---

**Примечание**: Убедитесь, что все требования выполнены перед запуском приложения.
