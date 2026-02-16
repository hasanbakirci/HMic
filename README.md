# HMic 🎙️

Modern macOS menu bar application for real-time microphone control. Adjust input gain, toggle mute, and set global keyboard shortcuts—all from your menu bar.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

- **🎚️ Real-time Gain Control** - Smooth slider with visual level meter
- **🔇 Mute Toggle** - Quick mute/unmute with visual feedback
- **⌨️ Global Shortcuts** - Control mic even when app is inactive
- **📊 dB Display** - See both percentage and decibel values
- **⚡ Event-Driven** - Instant updates, zero CPU waste
- **🎨 Modern UI** - Glassmorphic design with native macOS feel
- **♿ Accessible** - Full VoiceOver support

## 📸 Screenshot

```
┌─────────────────────────────┐
│  🎤  MacBook Pro Microphone │
│      Active                 │
│  ────────────────────  [◉] │
├─────────────────────────────┤
│  Input Gain          75%    │
│                    +3.5 dB  │
│  ▰▰▰▰▰▰▰▱▱▱              │
│  ══════════════════════     │
│                             │
│  Quick: [25%][50%][75%][100%] │
├─────────────────────────────┤
│  ▼ Shortcuts                │
│    Toggle Mute      ⌥M      │
│    Increase Gain    ⌥↑      │
│    Decrease Gain    ⌥↓      │
└─────────────────────────────┘
```

## 🚀 Quick Start

### Option 1: Download DMG (Recommended)

1. Download `HMic_Installer.dmg` from [Releases](#)
2. Open the DMG
3. Drag `HMic.app` to Applications folder
4. Right-click → **Open** (first time only)
5. Grant microphone permission when prompted

### Option 2: Build from Source

```bash
# Clone repository
git clone https://github.com/yourusername/HMic.git
cd HMic

# Build and run
swift build
swift run

# Or create .app bundle
./build_app.sh
open HMic.app
```

**Requirements:**
- macOS 12.0+
- Xcode 14.0+ or Swift 5.9+

## 🎮 Usage

### Basic Controls

1. **Click menu bar icon** to open control panel
2. **Drag slider** to adjust input gain (0-100%)
3. **Toggle switch** to mute/unmute
4. **Click preset buttons** for quick levels (25%, 50%, 75%, 100%)

### Global Shortcuts

1. Click **"Shortcuts"** to expand
2. Click button next to action (e.g., "Toggle Mute")
3. Press your desired key combination (e.g., `⌥M`)
4. Shortcut saved automatically!

**Default shortcuts:** (customize as needed)
- Toggle Mute: `⌥ M`
- Increase Gain: `⌥ ↑`
- Decrease Gain: `⌥ ↓`

## 🏗️ Architecture

### Event-Driven Design

HMic uses CoreAudio property listeners instead of timer-based polling:

```swift
// Real-time updates, zero CPU overhead
AudioObjectAddPropertyListenerBlock(deviceID, &propertyAddress, queue) {
    // Instant UI refresh when volume changes
}
```

**Benefits:**
- ⚡ <16ms latency (vs 1000ms with polling)
- 🔋 Minimal battery impact
- 🎯 Instant sync with external changes

### Project Structure

```
HMic/
├── Sources/HMic/
│   ├── Utilities/           # Core audio helpers
│   │   ├── AudioPropertyListener.swift
│   │   └── AudioConstants.swift
│   ├── Services/            # Business logic
│   │   ├── AudioDeviceService.swift
│   │   ├── MicrophoneService.swift
│   │   └── ShortcutService.swift
│   ├── Hotkeys/            # Global shortcuts
│   │   └── GlobalHotkeyManager.swift
│   ├── ViewModels/         # MVVM
│   │   └── MicViewModel.swift
│   ├── MenuBarView.swift   # SwiftUI UI
│   ├── StatusBarController.swift
│   ├── AppDelegate.swift
│   └── MicControlApp.swift
├── Assets/                 # App icon
├── Package.swift          # Swift Package Manager
└── build_app.sh          # Build script
```

## 🛠️ Development

### Prerequisites

```bash
# Verify Swift version
swift --version  # Should be 5.9+
```

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run
swift run

# Create distributable .app
./build_app.sh
```

### Testing

```bash
# Run the app
swift run

# Test checklist:
# - [ ] Slider moves smoothly
# - [ ] Mute toggle works
# - [ ] External volume changes update UI
# - [ ] Global shortcuts trigger actions
# - [ ] Visual meter reflects gain
# - [ ] dB values are accurate
```

## 🔧 Troubleshooting

### "HMic.app can't be opened"

**Solution:** Right-click → **Open** (bypass Gatekeeper)

Or via terminal:
```bash
xattr -dr com.apple.quarantine /Applications/HMic.app
```

### Microphone permission denied

**Solution:** 
1. System Settings → Privacy & Security → Microphone
2. Enable `HMic`
3. Restart app

### Shortcuts not working

**Solution:**
1. System Settings → Privacy & Security → Accessibility
2. Add `HMic` to allowed apps
3. Re-register shortcuts in app

## 📦 Distribution

See [DISTRIBUTION.md](DISTRIBUTION.md) for detailed packaging instructions.

**Quick:**
```bash
./build_app.sh              # Creates HMic.app and HMic_Installer.dmg
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- Built with Swift & SwiftUI
- Uses CoreAudio framework
- Carbon API for global hotkeys

## 📞 Support

- Issues: [GitHub Issues](https://github.com/yourusername/HMic/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/HMic/discussions)

---

**Made with ❤️ for macOS power users**
