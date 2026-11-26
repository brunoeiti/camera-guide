#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Install Homebrew first: https://brew.sh"
  exit 1
fi

brew install --cask flutter android-studio android-commandlinetools temurin
brew install cocoapods

flutter doctor --android-licenses
flutter doctor
