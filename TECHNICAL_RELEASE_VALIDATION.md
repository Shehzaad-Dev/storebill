TECHNICAL RELEASE VALIDATION — Final checks

APK/AAB readiness checklist
- [ ] `flutter build appbundle --release` completes without errors
- [ ] `build/app/outputs/bundle/release/app-release.aab` exists
- [ ] Proguard / minify settings verified (if enabled)

Release build configuration
- Signing
  - `android/key.properties` configured with keystore path and passwords
  - `android/app/build.gradle` `signingConfigs` set for release
  - Keystore backup stored securely (offline) and password stored in vault
- Build flavors: none by default — verify production config

Versioning rules
- Update `pubspec.yaml` version with new `x.y.z+versionCode`
  - Increment `versionCode` for Play Store
  - Use semantic `versionName` for human readable

Crash-free launch checklist
- Run release build on internal test device and verify cold start
- Check for missing permissions prompts and rationale dialogs
- Verify all critical flows: create invoice → export PDF → open shared PDF

Performance risks
- PDF generation: ensure uses background isolate or compute to avoid jank
- Large history lists: implement lazy loading / ListView.builder (ensure virtualization)
- Image handling: limit in-memory decoded images; use `flutter_advanced_networkimage` or similar if needed

Signing key safety
- Keep keystore offline, distributed backups in secure storage
- Rotate credentials only if compromised
- Use Google Play App Signing (recommended) — upload the app signing key if using Play App Signing

Final smoke tests (must pass before upload)
- Create invoice with multiple line items, export to PDF, open PDF
- Schedule a khata reminder and test local notification delivery and tap behavior
- Export all data JSON and import back (if import present)
- Test Delete All Data flow and confirm deletion

CI/CD recommendations (optional)
- Use GitHub Actions to build AAB and optionally use `r0adkll/upload-google-play-action` for internal track uploads


