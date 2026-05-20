# Quick Reference: DukaanDoc Release Workflow

## 📋 Release Checklist

### Before Every Release:
- [ ] Update `version: X.Y.Z+N` in `pubspec.yaml`
- [ ] Add changelog entries (if using CHANGELOG.md)
- [ ] Run `flutter test` locally
- [ ] Test on device/emulator
- [ ] Verify app icons display correctly

---

## 🚀 Step-by-Step Release Process

### 1. Update Version (example: 1.0.0 → 1.1.0)

**Edit `pubspec.yaml`:**
```yaml
# OLD:
version: 1.0.0+1

# NEW:
version: 1.1.0+1
```

### 2. Commit & Push

```bash
git add pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
git push origin main
```

### 3. GitHub Actions Automatically:
- ✅ Builds APK & AppBundle
- ✅ Creates Git tag `v1.1.0`
- ✅ Creates GitHub Release with version notes
- ✅ Uploads build artifacts

### 4. Download Release

Go to: **GitHub Repository → Releases → Latest**

---

## 📱 Build Artifacts Generated

After successful release:
- `app-release.apk` - For direct Android distribution
- `app-release.aab` - For Google Play Store
- `build/` directory artifacts

**Download from:** GitHub Actions → Artifacts (or Releases)

---

## 🔢 Version Numbering System

```
version: MAJOR.MINOR.PATCH+BUILD

DukaanDoc 1.0.0+1
         │ │ │ │
         │ │ │ └─ BUILD NUMBER (1-9999) - increment per build
         │ │ └─── PATCH (0-999) - bug fixes, minor updates
         │ └───── MINOR (0-999) - new features, backwards compatible  
         └─────── MAJOR (0-999) - breaking changes, major features
```

### Version Bump Examples:

| Scenario | Old | New | Reason |
|----------|-----|-----|--------|
| Bug fix | 1.0.0 | 1.0.1 | Patch fix |
| New feature | 1.0.1 | 1.1.0 | Minor feature |
| Major release | 1.5.2 | 2.0.0 | Breaking change |
| Build/Play Store update | 1.1.0 | 1.1.0+2 | Rebuild, keep version |

---

## 🎯 Real-World Examples

### Example 1: Security Patch
```yaml
# pubspec.yaml
# OLD
version: 1.0.0+1

# NEW (security fix)
version: 1.0.1+1
```

**Commit:** `chore: security patch - fix data validation`

---

### Example 2: New Feature Release
```yaml
# pubspec.yaml
# OLD
version: 1.0.0+1

# NEW (new feature)
version: 1.1.0+1
```

**Commit:** `feat: add export to CSV functionality`

---

### Example 3: Play Store Rebuild
```yaml
# pubspec.yaml
# OLD
version: 1.1.0+1

# NEW (same version, different build)
version: 1.1.0+2
```

**Reason:** Google Play rejected, minor fix applied, re-upload

---

## ⚙️ GitHub Actions - What Happens

### Trigger
```
push to main branch → pubspec.yaml changed
```

### Workflow Steps
1. **Checkout** code from GitHub
2. **Install** Flutter SDK
3. **Analyze** code quality
4. **Test** run test suite
5. **Build** APK (split by architecture)
6. **Build** AppBundle for Play Store
7. **Create Release** with version tag
8. **Upload** artifacts to GitHub
9. **Generate** release notes

### Monitoring
1. Go to GitHub repo
2. Click **Actions** tab
3. Watch build progress
4. See logs if failed

---

## 📤 Play Store Upload

1. **Download** `app-release.aab` from GitHub Release
2. **Go to** [Google Play Console](https://play.google.com/console)
3. **Select** your app
4. **New Release** → Production/Beta/Internal Testing
5. **Upload** the AAB file
6. **Add** release notes
7. **Review** and **Publish**

---

## 🍎 App Store Upload (iOS)

1. **Build iOS**: `flutter build ipa --release`
2. **Upload via**: Xcode or [App Store Connect](https://appstoreconnect.apple.com)
3. **Test** via TestFlight
4. **Submit** to App Review

---

## ❌ Troubleshooting

### Build Failed?
1. Check **Actions** tab → see error logs
2. Common issues:
   - Invalid `pubspec.yaml` syntax
   - File upload syntax errors
   - Disk space issues

### Release Not Created?
1. Verify push is to **main** branch
2. Check `pubspec.yaml` was changed
3. Wait 1-2 minutes for Actions to start
4. Look for `v1.x.x` tag in Git

### Can't Download Artifacts?
1. Go to **Actions** → Latest workflow run
2. Scroll down to **Artifacts**
3. Download directly (or from Releases page)

---

## 📝 Version History Log

Keep track of your releases:

```
v1.1.0 - 2026-05-21 - New CSV export, UX improvements
v1.0.1 - 2026-05-15 - Bug fixes, performance improvements
v1.0.0 - 2026-05-01 - Initial release, core features
```

---

## 🎓 Best Practices

✅ **DO:**
- Commit messages should be clear and descriptive
- Test locally before pushing
- One version bump per feature/bugfix batch
- Keep version numbers sequential
- Document major changes

❌ **DON'T:**
- Skip patch versions (1.0.0 → 1.0.3) without reason
- Push directly to main without testing
- Upload to Play Store without testing build
- Use version like "1.0" (always use X.Y.Z format)
- Forget to increment build number for rebuilds

---

## 🔔 Notifications

Get release notifications:
1. GitHub → Watch Repository
2. Choose "Releases only" or "All activity"
3. Get email on new releases

---

**DukaanDoc Release System Ready! 🚀**

Version 1.0.0 is live and configured for continuous releases.
