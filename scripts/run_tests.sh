#!/bin/bash

# PulseFit Pro - Test Runner Script
echo "🧪 Running PulseFit Pro tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
print_status "Flutter version:"
flutter --version

# Clean and get dependencies
print_status "Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run unit and widget tests
print_status "Running unit and widget tests..."
if flutter test; then
    print_success "Unit and widget tests passed!"
else
    print_error "Unit and widget tests failed!"
    exit 1
fi

# Run tests with coverage
print_status "Running tests with coverage..."
if flutter test --coverage; then
    print_success "Tests with coverage completed!"
    
    # Generate coverage report
    if command -v genhtml &> /dev/null; then
        print_status "Generating coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        print_success "Coverage report generated in coverage/html/"
    else
        print_warning "genhtml not found. Install lcov to generate coverage report."
    fi
else
    print_error "Tests with coverage failed!"
    exit 1
fi

# Run integration tests
print_status "Running integration tests..."
if flutter test integration_test/; then
    print_success "Integration tests passed!"
else
    print_error "Integration tests failed!"
    exit 1
fi

# Run analyzer
print_status "Running Flutter analyzer..."
if flutter analyze; then
    print_success "Analyzer passed - no issues found!"
else
    print_warning "Analyzer found some issues. Check the output above."
fi

# Check for test coverage threshold
if [ -f "coverage/lcov.info" ]; then
    COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')
    THRESHOLD=80
    
    if (( $(echo "$COVERAGE >= $THRESHOLD" | bc -l) )); then
        print_success "Coverage is $COVERAGE% (threshold: $THRESHOLD%)"
    else
        print_warning "Coverage is $COVERAGE% (threshold: $THRESHOLD%)"
    fi
fi

# Summary
echo ""
print_success "All tests completed successfully! 🎉"
echo ""
echo "📊 Test Summary:"
echo "   ✅ Unit and Widget tests: PASSED"
echo "   ✅ Integration tests: PASSED"
echo "   ✅ Code coverage: Generated"
echo "   ✅ Flutter analyzer: Completed"
echo ""
echo "🚀 Your app is ready for release!"

# Open coverage report if available
if [ -d "coverage/html" ]; then
    print_status "Opening coverage report..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open coverage/html/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open coverage/html/index.html
    elif [[ "$OSTYPE" == "msys" ]]; then
        start coverage/html/index.html
    fi
fi
