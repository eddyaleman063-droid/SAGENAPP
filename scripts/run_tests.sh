#!/bin/bash

# SAGEN Test Runner
# This script runs all tests and generates reports

set -e

echo "🚀 SAGEN Test Suite"
echo "=================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Get Flutter version
echo "Flutter version:"
flutter --version | head -n 1
echo ""

# Run unit tests
echo "📝 Running unit tests..."
flutter test
echo ""

# Run tests with coverage
echo "📊 Running tests with coverage..."
flutter test --coverage
echo ""

# Run integration tests (if device is available)
echo "📱 Checking for devices..."
DEVICES=$(flutter devices --machine 2>/dev/null | grep -c '"id"')
if [ "$DEVICES" -gt 0 ]; then
    echo "Running integration tests..."
    flutter test integration_test/
else
    echo "No devices available for integration tests"
fi

echo ""
echo "✅ Test suite complete!"
echo ""
echo "Coverage report: coverage/lcov.info"
echo "To view HTML report: genhtml coverage/lcov.info -o coverage/html"
