#!/bin/bash

# SAGEN Coverage Report Generator
# This script generates and displays coverage reports

set -e

echo "🧪 Running tests with coverage..."
flutter test --coverage

echo ""
echo "📊 Coverage Summary:"
if [ -f coverage/lcov.info ]; then
    # Extract line coverage percentage
    LINES=$(grep -m 1 "^LF:" coverage/lcov.info | cut -d: -f2)
    HIT=$(grep -m 1 "^LH:" coverage/lcov.info | cut -d: -f2)
    
    if [ "$LINES" -gt 0 ]; then
        PERCENTAGE=$((HIT * 100 / LINES))
        echo "Lines: $HIT / $LINES ($PERCENTAGE%)"
        
        if [ "$PERCENTAGE" -lt 80 ]; then
            echo "⚠️  Coverage is below 80% threshold"
        else
            echo "✅ Coverage meets 80% threshold"
        fi
    fi
fi

echo ""
echo "📁 Coverage files:"
echo "  - coverage/lcov.info (machine-readable)"
if command -v genhtml &> /dev/null; then
    echo "  - Generating HTML report..."
    genhtml coverage/lcov.info -o coverage/html --silent
    echo "  - coverage/html/index.html (open in browser)"
else
    echo "  - Install lcov for HTML reports: brew install lcov"
fi

echo ""
echo "🔗 To view coverage in VS Code:"
echo "  1. Install Coverage Gutters extension"
echo "  2. Open coverage/lcov.info"
echo "  3. Click 'Watch' in status bar"
