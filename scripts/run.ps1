param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("android", "ios")]
    [string]$Platform
)

$ErrorActionPreference = "Stop"
flutter pub get

if ($Platform -eq "android") {
    flutter run -d android
} else {
    throw "iOS builds require macOS."
}
