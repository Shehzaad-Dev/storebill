Play Console — Step-by-step upload guide (copy-paste)

1) Create App in Play Console
- Sign in to Play Console → All apps → Create app
- App name: StoreBill — Offline Invoice & Khata
- Select: App or Game → App
- Paid/Free: Free (select accordingly)
- Developer email: support@storebill.app

2) App access & content
- Upload Privacy Policy URL (HTTPS)
- Fill Contact details (email, phone optional)
- Content rating: fill app questionnaire
- Target audience: Adults / General

3) Prepare release artifacts
- Build AAB:
```bash
flutter pub get
flutter build appbundle --release
```
- Locate: `build/app/outputs/bundle/release/app-release.aab`

4) Create Internal Test track
- Release → Testing → Internal testing → Create new release
- Upload AAB, release notes (brief), and click Save → Review → Start rollout to internal testing
- Add tester emails and verify install via Play Store internal test link

5) Closed/Open testing
- Use Closed track to test wider group; replicate steps above

6) Production rollout
- After successful internal/closed tests, create Production release
- Upload AAB, complete store listing, upload screenshots, feature graphic, and icons
- Complete pricing & distribution and target countries
- Submit for review

7) Post-submission checks
- Monitor Pre-launch reports and Crashlytics errors
- Address any reviewer feedback promptly

8) Keynotes
- Before production enable ad networks only after privacy URL and Data Safety are set
- Use staged rollout (e.g., 10%) initially to monitor crashes and invalid traffic

Common commands for signing and building
- Ensure `key.properties` configured and `signingConfigs` set in `android/app/build.gradle`.
- Build with Gradle signing:
```bash
flutter build appbundle --release
```

If you need automated CI, use GitHub Actions to run `flutter build appbundle` and upload artifact to Google Play via `r0adkll/upload-google-play-action`.
