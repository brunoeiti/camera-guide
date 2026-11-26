#!/usr/bin/env bash
set -euo pipefail

platform="${1:-}"
if [[ -z "$platform" ]]; then
  echo "Usage: scripts/run.sh android|ios"
  exit 1
fi

flutter pub get

case "$platform" in
  android)
    flutter run -d android
    ;;
  ios)
    flutter run -d ios
    ;;
  *)
    echo "Usage: scripts/run.sh android|ios"
    exit 1
    ;;
esac
