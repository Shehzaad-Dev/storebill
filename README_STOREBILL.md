StoreBill — Launch README

Overview
- App: StoreBill (previously DukaanDoc)
- Purpose: Offline invoice maker, khata (ledger), business card generator
- Data: Fully local on-device; no cloud sync

App Icon
- SVG at `assets/storebill_icon.svg` (1024×1024). Convert to PNG for stores:
  - ImageMagick: `magick convert assets/storebill_icon.svg -resize 512x512 storebill_512.png` and `-resize 1024x1024` for 1024px.
  - Or use online SVG→PNG converter.

Privacy & Legal
- Privacy Policy: `/privacy` route (file: `lib/screens/legal_privacy_page.dart`)
- Terms & Conditions: `/terms` (file: `lib/screens/legal_terms_page.dart`)
- About Page: `/about` (file: `lib/screens/legal_about_page.dart`)

Important developer notes
- App name changed in `pubspec.yaml` to `storebill` and `lib/main.dart` title set to `StoreBill`.
- Default invoice/receipt drafts are empty by default (no prefilled items).
- Added refresh button in invoice screen to start a fresh draft.
- Export/share/print actions record invoice snapshot to history. Duplicate save bug fixed.
- Invoice history supports search, edit (load into draft), delete.

Preparing assets for Play Store / App Store
1. Generate launcher icons from `assets/storebill_icon.svg`.
2. Android adaptive icons: produce foreground PNG (432x432) and background color.
3. iOS App Store: supply 1024×1024 PNG (no alpha preferred).

Ad networks & Ads Compliance (quick)
- Ads may be shown; ensure Privacy Policy accessible in app and Play Store listing.
- Do not show ads during invoice creation flow where accidental clicks may occur.

How to build & run locally
- Flutter SDK required (see `pubspec.yaml` for SDK constraints).
- From repo root:

```bash
flutter pub get
flutter run -d <device>
```

Contact
- Support email placeholder: support@storebill.app

