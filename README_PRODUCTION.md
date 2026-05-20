README — Production Release for StoreBill

Purpose
This document contains exact commands and steps to build release artifacts, generate icons, configure assets, and prepare for Play Store submission.

Prerequisites
- Flutter installed (stable channel)
- Java JDK 11+
- Android SDK and platform-tools
- ImageMagick or Inkscape for SVG->PNG conversion (optional)
- `flutter_launcher_icons` (optional) for icons

1) Build release AAB (recommended for Play)

```bash
flutter pub get
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

2) Build release APK (optional)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

3) Generate icons (from existing SVG)
Option A: ImageMagick
```bash
magick convert assets/storebill_icon.svg -resize 512x512 assets/storebill_512.png
magick convert assets/storebill_icon.svg -resize 1024x1024 assets/storebill_1024.png
```
Option B: flutter_launcher_icons (recommended for adaptive icons)
- Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.10.0

flutter_icons:
  android: true
  ios: true
  image_path: "assets/storebill_512.png"
```

Then run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

4) Place produced icons
- Play Store upload: use `assets/storebill_512.png` (512×512)
- App Store upload: use `assets/storebill_1024.png` (1024×1024)
- Android adaptive icons: ensure `mipmap-*` folders updated under `android/app/src/main/res/`
- iOS: add images to `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

5) Assets folder (recommended layout)
- assets/
  - storebill_icon.svg
  - storebill_512.png
  - storebill_1024.png
  - privacy.html
  - terms.html

6) Configure ads safely (before enabling live traffic)
- Follow `ad_monetization_rules.md` and `ad_monetization_policy.md` in repo.
- Use test ad IDs in debug builds; register test devices.
- Ensure no ad widgets in invoice editor/export flows.

7) Avoid Play Store rejection — final checks
- Privacy Policy hosted (HTTPS) and linked in Play Console
- Data Safety form filled (use `play_data_safety_mapping.md`)
- Required icons uploaded
- Export/Delete local data UI present and documented
- Pre-permission rationale dialogs implemented

8) Uploadable artifacts
- `build/app/outputs/bundle/release/app-release.aab` (recommended)
- `assets/storebill_512.png` and `assets/storebill_1024.png`
- Hosted policy URLs

Contact
Support: support@storebill.app
