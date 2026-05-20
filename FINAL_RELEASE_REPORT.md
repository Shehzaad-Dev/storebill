StoreBill v1.0.0 — Final Release Report

Actions performed:
- Ensured `.gitignore` excludes `/build/`, `.dart_tool/`, `*.jks`, `*.keystore`, `.env`, `/android/key.properties`, and `release_artifacts/`.
- Ran `flutter clean`, `flutter pub get`, `flutter analyze`, and `flutter test` (all green).
- Built release APK and AAB:
  - `build/app/outputs/flutter-apk/app-release.apk`
  - `build/app/outputs/bundle/release/app-release.aab`
- Collected artifacts into `release_artifacts/`.
- Initialized local git repo, committed current files, and created tag `v1.0.0` (local).
- Created `docs/` with `index.html`, `privacy.html`, and `terms.html` for GitHub Pages.
- Replaced `README.md` with StoreBill release README.
- Added `RELEASE_NOTES.md` and `PUBLISH_INSTRUCTIONS.md` with GH CLI steps.

Next steps before publishing:
1. Verify the APK installs on a test device and launches without crash.
2. (Optional) Add a remote and push to GitHub: `git remote add origin https://github.com/OWNER/REPO.git` then `git push -u origin main --tags`.
3. Use `gh` CLI or GitHub UI to create release `v1.0.0` and upload `release_artifacts/app-release.apk` (and AAB if desired).
4. Update `docs/index.html` with your repository owner and name (replace `OWNER/REPO`).
5. Enable GitHub Pages on `main` branch using `/docs` folder.

If you want, I can push the repo and create the GitHub release for you — provide the repository URL and confirm you want me to push. Otherwise, I can run the `gh release create` command if you provide `gh` authentication on this machine.
