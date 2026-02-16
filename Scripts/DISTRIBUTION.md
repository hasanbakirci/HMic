# HMic Distribution Instructions

This document explains how to distribute and install the HMic application.

## Artifacts
The following files have been generated:
- **HMic.app**: The application bundle.
- **HMic_Installer.dmg**: A disk image installer.
- **AppIcon.iconset**: The source icons and `Contents.json`.

## Installation on Another Mac

Since this app is signed with an ad-hoc certificate (not an Apple Developer ID), macOS Gatekeeper will prevent it from running by default on other computers.

### Option 1: Using the DMG (Recommended)
1. Copy `HMic_Installer.dmg` to the target Mac.
2. Double-click the DMG to mount it.
3. Drag `HMic.app` to the `Applications` folder (or anywhere else).
4. **First Launch**:
   - Right-click (or Control-click) on `HMic.app`.
   - Select **Open**.
   - You will see a warning dialog. Click **Open** again.
   - This only needs to be done once to bypass Gatekeeper.

### Option 2: Using the App Bundle
1. Copy `HMic.app` to the target Mac.
2. Follow the "First Launch" steps above.

### Troubleshooting "App is damaged"
If you see a message saying "HMic is damaged and can't be opened", run the following command in Terminal:

```bash
xattr -cr /path/to/HMic.app
```
Then try opening it again.

## Notarization (For Developers)
To distribute this app without Gatekeeper warnings, you must sign it with a valid Apple Developer ID and notarize it.

1. Obtain an Apple Developer ID Application certificate.
2. Update `build_app.sh` to use your certificate identity instead of `-` (ad-hoc).
3. Use `xcrun notarytool` to submit the app to Apple for notarization.
4. Staple the ticket to the app using `xcrun stapler`.
