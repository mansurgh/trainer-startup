# PulseFit Pro - Release Build Script for Windows
Write-Host "🚀 Building PulseFit Pro for release..." -ForegroundColor Green

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Check for .env file
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  Warning: .env file not found. Creating example..." -ForegroundColor Yellow
    Copy-Item "env.example" ".env"
    Write-Host "📝 Please edit .env file with your API keys before building for release" -ForegroundColor Cyan
}

# Build for Android
Write-Host "📱 Building Android APK..." -ForegroundColor Blue
flutter build apk --release

Write-Host "📱 Building Android App Bundle..." -ForegroundColor Blue
flutter build appbundle --release

# Build for Windows
Write-Host "🪟 Building Windows..." -ForegroundColor Blue
flutter build windows --release

Write-Host "✅ All builds completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Build outputs:" -ForegroundColor Cyan
Write-Host "   Android APK: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor White
Write-Host "   Android AAB: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor White
Write-Host "   Windows: build/windows/runner/Release/" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Ready for App Store submission!" -ForegroundColor Green
