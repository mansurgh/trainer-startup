# PulseFit Pro - Flutter Fitness App

A Flutter fitness application with AI features, Riverpod state management, and modern UI design.

## 🚀 Quick Start Guide

### ⚡ Super Quick Start (5 minutes)
See [QUICK_START.md](QUICK_START.md) for the fastest way to get running.

### 📋 System Requirements
Check [REQUIREMENTS.md](REQUIREMENTS.md) for detailed system requirements and troubleshooting.

### 🪟 Windows Setup
Follow [SETUP_WINDOWS.md](SETUP_WINDOWS.md) for step-by-step Windows installation.

### Prerequisites

Before running this application, make sure you have the following installed:

#### 1. Flutter SDK
- **Download**: [Flutter SDK](https://docs.flutter.dev/get-started/install)
- **Version**: Flutter 3.4.0 or higher
- **Platform**: Windows, macOS, or Linux

#### 2. Development Environment
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Visual Studio Code** with Flutter extension (recommended)

#### 3. Platform-specific Requirements

**For Windows:**
- Visual Studio 2022 with C++ development tools
- Windows 10 version 1903 or higher

**For Android:**
- Android SDK
- Android device or emulator

**For iOS (macOS only):**
- Xcode 14.0 or higher
- iOS Simulator or physical device

### 📦 Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/mansurgh/trainer-startup.git
cd trainer-startup
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