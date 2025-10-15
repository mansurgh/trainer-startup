# 🏋️ Trainer - AI Fitness Coach

**Профессиональный фитнес-тренер с искусственным интеллектом**

Современное приложение для фитнеса с ИИ-тренером, интерактивной картой мышц, анализом техники упражнений и персональными программами тренировок.

![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)

---

## ✨ **Ключевые особенности**

### 🤖 **AI Персональный тренер**
- **OpenAI GPT-4o** интеграция для персональных консультаций
- Генерация тренировочных планов на основе целей
- Анализ техники выполнения упражнений по фото
- Рекомендации по питанию и восстановлению

### � **Интерактивная карта мышц**
- Визуализация активных мышечных групп в реальном времени
- 3D модель тела с детализацией нагрузки
- Переключение вид спереди/сзади
- Анимированные переходы и подсветка

### 📊 **Activity Heatmap**
- Тепловая карта активности по GitHub стилю
- Визуализация прогресса за год
- Tracking частоты тренировок
- Мотивационные streak счётчики

### 🎨 **Premium Glassmorphism UI**
- Современный дизайн в стиле **фиолет-неон на тёмном**
- Эффекты размытого стекла и градиенты
- Анимации с использованием flutter_animate
- Адаптивная вёрстка для всех устройств

### 🥗 **AI Анализ питания**
- Распознавание еды по фотографии
- Автоматический подсчёт калорий и макронутриентов
- Персональные рекомендации по питанию
- Tracking водного баланса

---

## 🛠 **Технологический стек**

### **Frontend**
- **Flutter 3.16+** - кроссплатформенная разработка
- **Riverpod** - state management и dependency injection
- **flutter_animate** - богатые анимации
- **google_fonts** - типографика Inter

### **Backend & Database**
- **Supabase** - PostgreSQL с Row Level Security
- **Real-time subscriptions** для синхронизации данных
- **Authentication** с социальными провайдерами
- **Storage** для фотографий и медиа

### **AI & Machine Learning**
- **OpenAI API** (GPT-4o) для AI тренера
- **Computer Vision** анализ техники упражнений
- **Natural Language Processing** для чат-бота
- **Recommendation Engine** персональных планов

### **Design System**
- **Design Tokens** система для консистентности
- **Premium Components** библиотека переиспользуемых UI
- **Accessibility** поддержка VoiceOver/TalkBack
- **Responsive Design** адаптивная вёрстка

---

## 🚀 **Quick Start**

### **Установка**
```bash
# Клонируем репозиторий
git clone [your-repo-url]
cd trainer-app

# Устанавливаем зависимости
flutter pub get

# Настраиваем environment
cp env.example .env
# Редактируем .env с вашими API ключами

# Запускаем приложение
flutter run
```

### **Environment Configuration**
```env
# OpenAI API
OPENAI_API_KEY=your_openai_api_key_here

# Supabase
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### **Supabase Setup**
```sql
-- Выполните schema в Supabase SQL Editor
-- Файл: supabase_schema.sql
```

#### 2. Install Flutter Dependencies
```bash
flutter pub get
```

#### 3. Verify Flutter Installation
```bash
flutter doctor
```
Make sure all required components are installed and configured.

#### 4. Generate Native Splash Screen (Optional)
```bash
flutter pub run flutter_native_splash:create
```

### 🏃‍♂️ Running the Application

#### For Windows Desktop:
```bash
flutter run -d windows
```

#### For Android:
```bash
flutter run -d android
```

#### For iOS (macOS only):
```bash
flutter run -d ios
```

#### For Web:
```bash
flutter run -d chrome
```

### 🔧 Configuration

#### Environment Variables
Create a `secrets.json` file in the project root with your API keys:

```json
{
  "OPENAI_API_KEY": "your_openai_api_key_here",
  "FIREBASE_API_KEY": "your_firebase_api_key_here"
}
```

Run with environment variables:
```bash
flutter run -d windows --dart-define-from-file=secrets.json
```

### 📱 Features

- **AI-Powered Workout Plans**: Personalized fitness recommendations
- **Body Composition Analysis**: Track your fitness progress
- **Modern UI**: Glassmorphism design with smooth animations
- **State Management**: Riverpod for efficient state handling
- **Multi-platform**: Windows, Android, iOS, and Web support

### 🛠️ Development

#### Project Structure
```
lib/
├── core/           # Theme and core widgets
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic services
├── state/          # Riverpod state management
└── widgets/        # Reusable UI components
```

#### Key Dependencies
- **flutter_riverpod**: State management
- **google_fonts**: Typography
- **flutter_animate**: Animations
- **image_picker**: Camera/gallery integration
- **video_player**: Video playback
- **cached_network_image**: Image caching

### 🐛 Troubleshooting

#### Common Issues:

1. **Flutter Doctor Issues**
   - Run `flutter doctor` to identify missing components
   - Follow the suggested fixes

2. **Build Errors**
   - Clean the project: `flutter clean`
   - Get dependencies: `flutter pub get`
   - Rebuild: `flutter run`

3. **Platform-specific Issues**
   - **Windows**: Ensure Visual Studio 2022 is installed
   - **Android**: Check Android SDK installation
   - **iOS**: Verify Xcode and iOS Simulator setup

### 📄 License

This project is licensed under the MIT License.

### 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### 📞 Support

If you encounter any issues, please:
1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with detailed information

---

**Happy Coding! 🎉**