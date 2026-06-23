#!/bin/bash
# Run this script after updating google-services.json

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building app..."
flutter build apk --debug

echo "✅ Done! Now run: flutter run"
