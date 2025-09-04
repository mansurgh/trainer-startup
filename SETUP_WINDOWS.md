# 🪟 Windows Setup Guide

## Пошаговая инструкция для запуска PulseFit Pro на Windows

### 1. Установка Flutter SDK

#### Скачивание Flutter
1. Перейдите на [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Скачайте Flutter SDK для Windows
3. Распакуйте архив в `C:\flutter` (или другую папку)

#### Настройка PATH
1. Откройте "Параметры системы" → "Дополнительные параметры системы"
2. Нажмите "Переменные среды"
3. В разделе "Системные переменные" найдите `Path` и нажмите "Изменить"
4. Добавьте путь к Flutter: `C:\flutter\bin`
5. Нажмите "ОК" во всех окнах

### 2. Установка Visual Studio 2022

#### Скачивание и установка
1. Скачайте [Visual Studio 2022 Community](https://visualstudio.microsoft.com/vs/community/)
2. При установке выберите:
   - ✅ **Desktop development with C++**
   - ✅ **Windows 10/11 SDK** (любая версия)
   - ✅ **CMake tools for C++**

### 3. Установка Git

1. Скачайте [Git for Windows](https://git-scm.com/download/win)
2. Установите с настройками по умолчанию

### 4. Клонирование и запуск проекта

#### Клонирование репозитория
```bash
git clone https://github.com/mansurgh/trainer-startup.git
cd trainer-startup
```

#### Установка зависимостей
```bash
flutter pub get
```

#### Проверка установки
```bash
flutter doctor
```

**Важно**: Убедитесь, что все компоненты отмечены зелеными галочками ✅

#### Запуск приложения
```bash
flutter run -d windows
```

### 5. Возможные проблемы и решения

#### Проблема: "Flutter not found"
**Решение**: Перезапустите командную строку после добавления Flutter в PATH

#### Проблема: "Visual Studio not found"
**Решение**: Убедитесь, что установлен Visual Studio 2022 с C++ компонентами

#### Проблема: "Windows SDK not found"
**Решение**: Переустановите Visual Studio с Windows SDK

#### Проблема: "CMake not found"
**Решение**: Установите CMake через Visual Studio Installer

### 6. Дополнительные настройки

#### Настройка VS Code (рекомендуется)
1. Установите [Visual Studio Code](https://code.visualstudio.com/)
2. Установите расширение "Flutter"
3. Откройте папку проекта в VS Code

#### Настройка эмулятора (опционально)
1. Установите Android Studio
2. Создайте Android Virtual Device (AVD)
3. Запустите эмулятор

### 7. Проверка работоспособности

После успешного запуска вы должны увидеть:
- Окно приложения PulseFit Pro
- Главный экран с навигацией
- Рабочий интерфейс без ошибок

### 8. Следующие шаги

1. **Изучите код**: Начните с `lib/main.dart`
2. **Настройте API**: Создайте `secrets.json` с вашими ключами
3. **Разрабатывайте**: Вносите изменения и тестируйте

---

**Готово! 🎉 Ваше приложение должно запуститься на Windows.**
