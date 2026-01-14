#!/bin/bash

# Build script for Cineverse iOS project

set -e  # Exit on error

echo "🔨 Building Cineverse..."

# Generate Xcode project from project.yml
echo "📦 Generating Xcode project..."
if ! command -v xcodegen &> /dev/null; then
  echo "❌ XcodeGen not installed. Install with: brew install xcodegen"
  exit 1
fi

if ! xcodegen generate; then
  echo "❌ XcodeGen failed to generate project!"
  exit 1
fi
echo "✅ Xcode project generated!"

# Run SwiftLint
echo "🔍 Running SwiftLint..."
if command -v swiftlint &> /dev/null; then
  swiftlint lint --strict
  echo "✅ SwiftLint passed!"
else
  echo "⚠️  SwiftLint not installed. Install with: brew install swiftlint"
  echo "Continuing without linting..."
fi

# Build the project
set +e  # Temporarily disable exit on error to capture build status
if command -v xcbeautify &> /dev/null; then
  xcodebuild \
    -project Cineverse.xcodeproj \
    -scheme Cineverse \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -configuration Debug \
    clean build \
    | xcbeautify
  BUILD_EXIT_CODE=${PIPESTATUS[0]}
else
  echo "⚠️  xcbeautify not installed. Install with: brew install xcbeautify"
  echo "Building without output formatting..."
  xcodebuild \
    -project Cineverse.xcodeproj \
    -scheme Cineverse \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -configuration Debug \
    clean build
  BUILD_EXIT_CODE=$?
fi
set -e  # Re-enable exit on error

# Check build result
if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "✅ Build succeeded!"
  exit 0
else
  echo "❌ Build failed!"
  exit 1
fi
