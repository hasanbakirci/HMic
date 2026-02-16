#!/bin/bash

SOURCE_ICON="$1"

if [ -z "$SOURCE_ICON" ]; then
    echo "Usage: ./resize_icons.sh <source_icon_path>"
    exit 1
fi

# Standard macOS icon sizes - forcing png format
sips -s format png -z 16 16     "$SOURCE_ICON" --out AppIcon.iconset/icon_16x16.png
sips -s format png -z 32 32     "$SOURCE_ICON" --out AppIcon.iconset/icon_16x16@2x.png
sips -s format png -z 32 32     "$SOURCE_ICON" --out AppIcon.iconset/icon_32x32.png
sips -s format png -z 64 64     "$SOURCE_ICON" --out AppIcon.iconset/icon_32x32@2x.png
sips -s format png -z 128 128   "$SOURCE_ICON" --out AppIcon.iconset/icon_128x128.png
sips -s format png -z 256 256   "$SOURCE_ICON" --out AppIcon.iconset/icon_128x128@2x.png
sips -s format png -z 256 256   "$SOURCE_ICON" --out AppIcon.iconset/icon_256x256.png
sips -s format png -z 512 512   "$SOURCE_ICON" --out AppIcon.iconset/icon_256x256@2x.png
sips -s format png -z 512 512   "$SOURCE_ICON" --out AppIcon.iconset/icon_512x512.png
sips -s format png -z 1024 1024 "$SOURCE_ICON" --out AppIcon.iconset/icon_512x512@2x.png

echo "✅ Icons resized into AppIcon.iconset"
