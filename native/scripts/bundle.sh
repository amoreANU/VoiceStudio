#!/bin/zsh
# Build the macOS app bundle from the SwiftPM executable.
set -euo pipefail
cd "$(dirname "$0")/.."
swift build
bin=".build/debug/OmniVoice"
out="dist"
mkdir -p "$out"
app="$out/OmniVoice.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$bin" "$app/Contents/MacOS/OmniVoice"
cat > "$app/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>OmniVoice</string>
  <key>CFBundleIdentifier</key><string>com.aiden.omnivoice.mac</string>
  <key>CFBundleName</key><string>OmniVoice</string>
  <key>CFBundleDisplayName</key><string>OmniVoice</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSAppTransportSecurity</key><dict><key>NSAllowsLocalNetworking</key><true/></dict>
</dict>
</plist>
PLIST
codesign --force --deep --sign - "$app" 2>/dev/null || true
echo "built $app"
