$ErrorActionPreference = "Stop"

winget install -e --id Google.AndroidStudio
winget install -e --id Google.Flutter

flutter doctor --android-licenses
flutter doctor
