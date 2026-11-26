# Camera Guide

Flutter camera app for capturing photos over a transparent guide image.

## macOS setup

```sh
./scripts/setup-macos.sh
./scripts/run.sh ios
./scripts/run.sh android
```

Open Xcode once and select a signing team for the iOS runner. Android requires
an emulator or a connected device.

## Windows setup

Run in PowerShell:

```powers
.\scripts\setup-windows.ps1
.\scripts\run.ps1 -Platform android
```

iOS builds are only supported from macOS.
