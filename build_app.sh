#!/bin/bash

# App Name
APP_NAME="HMic"
EXECUTABLE_NAME="HMic"
BUNDLE_ID="com.hasan.HMic"

echo "🚀 Building $APP_NAME..."

# Build the project
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

# Create App Bundle Structure
echo "📦 Creating App Bundle..."
rm -rf "$APP_NAME.app"
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

# Copy Executable
cp ".build/release/$EXECUTABLE_NAME" "$APP_NAME.app/Contents/MacOS/$APP_NAME"

# Copy Icon
# Copy Icon
if [ -f "Assets/AppIcon.icns" ]; then
    echo "🎨 Copying AppIcon.icns..."
    cp "Assets/AppIcon.icns" "$APP_NAME.app/Contents/Resources/AppIcon.icns"
elif [ -d "Assets/AppIcon.iconset" ]; then
    echo "🎨 Generating AppIcon.icns from iconset..."
    iconutil -c icns "Assets/AppIcon.iconset" -o "Assets/AppIcon.icns"
    cp "Assets/AppIcon.icns" "$APP_NAME.app/Contents/Resources/"
fi

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "$APP_NAME.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>HMic needs access to the microphone to control its input gain and mute status.</string>
</dict>
</plist>
EOF

# Sign the app (Ad-hoc signing required for local execution and permissions)
echo "🔏 Signing App..."
codesign --force --deep --sign - "$APP_NAME.app"

# Create DMG
# Create DMG
echo "💿 Creating DMG..."
DMG_NAME="${APP_NAME}_Installer.dmg"
rm -f "$DMG_NAME"

# Create a temporary directory for DMG contents
DMG_TMP_DIR="./dmg_temp"
rm -rf "$DMG_TMP_DIR"
mkdir -p "$DMG_TMP_DIR"

# Copy App to temp dir
cp -R "$APP_NAME.app" "$DMG_TMP_DIR/"

# Create Applications symlink
ln -s /Applications "$DMG_TMP_DIR/Applications"

# Create DMG from temp dir
hdiutil create -volname "$APP_NAME Installer" -srcfolder "$DMG_TMP_DIR" -ov -format UDZO "$DMG_NAME"

# Clean up
rm -rf "$DMG_TMP_DIR"

echo "✅ Done! App is at ./$APP_NAME.app"
echo "✅ Installer is at ./$DMG_NAME"
echo "To run: open $APP_NAME.app"
