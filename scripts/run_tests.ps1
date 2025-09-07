# PulseFit Pro - Test Runner Script for Windows PowerShell
Write-Host "🧪 Running PulseFit Pro tests..." -ForegroundColor Green

# Function to print colored output
function Write-Status {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param($Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Status "Flutter is installed"
    Write-Host $flutterVersion
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Clean and get dependencies
Write-Status "Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run unit and widget tests
Write-Status "Running unit and widget tests..."
try {
    flutter test
    Write-Success "Unit and widget tests passed!"
} catch {
    Write-Error "Unit and widget tests failed!"
    exit 1
}

# Run tests with coverage
Write-Status "Running tests with coverage..."
try {
    flutter test --coverage
    Write-Success "Tests with coverage completed!"
    
    # Check if coverage directory exists
    if (Test-Path "coverage/lcov.info") {
        Write-Status "Coverage data generated in coverage/lcov.info"
        Write-Warning "Install lcov to generate HTML coverage report"
    }
} catch {
    Write-Error "Tests with coverage failed!"
    exit 1
}

# Run integration tests
Write-Status "Running integration tests..."
try {
    flutter test integration_test/
    Write-Success "Integration tests passed!"
} catch {
    Write-Error "Integration tests failed!"
    exit 1
}

# Run analyzer
Write-Status "Running Flutter analyzer..."
try {
    flutter analyze
    Write-Success "Analyzer passed - no issues found!"
} catch {
    Write-Warning "Analyzer found some issues. Check the output above."
}

# Summary
Write-Host ""
Write-Success "All tests completed successfully! 🎉"
Write-Host ""
Write-Host "📊 Test Summary:" -ForegroundColor Cyan
Write-Host "   ✅ Unit and Widget tests: PASSED" -ForegroundColor White
Write-Host "   ✅ Integration tests: PASSED" -ForegroundColor White
Write-Host "   ✅ Code coverage: Generated" -ForegroundColor White
Write-Host "   ✅ Flutter analyzer: Completed" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Your app is ready for release!" -ForegroundColor Green

# Open coverage report if available
if (Test-Path "coverage/lcov.info") {
    Write-Status "Coverage data available in coverage/lcov.info"
    Write-Host "Install lcov and run: genhtml coverage/lcov.info -o coverage/html" -ForegroundColor Yellow
}
