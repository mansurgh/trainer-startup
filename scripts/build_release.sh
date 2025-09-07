#!/bin/bash

# PulseFit Pro - Release Build Script
echo "🚀 Building PulseFit Pro for release..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Check for .env file
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found. Creating example..."
    cp env.example .env
    echo "📝 Please edit .env file with your API keys before building for release"
fi

# Build for Android
echo "📱 Building Android APK..."
flutter build apk --release

echo "📱 Building Android App Bundle..."
flutter build appbundle --release

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release
    echo "✅ iOS build completed"
else
    echo "⚠️  iOS build skipped (not on macOS)"
fi

# Build for Windows
echo "🪟 Building Windows..."
flutter build windows --release

# Build for macOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building macOS..."
    flutter build macos --release
    echo "✅ macOS build completed"
else
    echo "⚠️  macOS build skipped (not on macOS)"
fi

echo "✅ All builds completed!"
echo ""
echo "📁 Build outputs:"
echo "   Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "   Android AAB: build/app/outputs/bundle/release/app-release.aab"
echo "   iOS: build/ios/Release-iphoneos/Runner.app"
echo "   Windows: build/windows/runner/Release/"
echo "   macOS: build/macos/Build/Products/Release/PulseFit Pro.app"
echo ""
echo "🎉 Ready for App Store submission!"
