#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$DIR"

echo "🔨 Building Flutter Web..."
flutter build web --release

echo "🚀 Deploying to Firebase Hosting..."
NODE_OPTIONS="--require $DIR/scripts/disable-fsevents.js" firebase deploy --only hosting --project painsense-doctor
