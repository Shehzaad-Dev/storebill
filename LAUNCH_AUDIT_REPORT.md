StoreBill — Launch Audit Report

Executive summary
- App: StoreBill (invoice, receipt, khata, business card)
- Status: Core features implemented; completed immediate fixes requested (empty drafts, refresh, history search/edit/delete, legal pages added)
- Remaining work: Icon PNG generation, in-app notification UX polish and delivery, final audit checklist items below

1) Play Store & App Store Approval Audit
Critical issues to fix before submission:
- Make Privacy Policy and Terms accessible from settings and store listing (done in-app; ensure hosted URL for Play Store if required)
- Ads disclosure present in Privacy Policy (done)
- Avoid advertising in core flows: ensure no interstitials in invoice creation; place banners only on non-critical screens (Home, Settings)
- Remove any references to third-party analytics that collect user data without disclosure

Exact fixes:
- Provide a hosted privacy policy URL for Play Console.
- Update app store listing assets (screenshots, feature graphics) showing offline-first and data-local claims.

2) Offline-first best practices
Recommendations:
- Local DB: Use Hive (already included) or encrypted SQLite. For sensitive data, use SQLCipher or hive with encrypted box.
- Auto-save: Drafts auto-saved (implemented). Ensure debounced saves on input.
- Backup/export: Provide JSON export/import, CSV export for invoices/customers (implemented). Document restore steps.
- Data recovery: Show explicit message during restore if schema mismatch occurs.
- Permissions: Use runtime permission requests only when needed (storage, camera, notifications).
- Uninstall warning: In settings, explain that uninstall deletes local data unless backed up.

3) Required legal & trust pages (created)
- Privacy Policy (in-app) — created.
- Terms & Conditions — created.
- About & Contact — created.
- Delete Data Instructions & Data Responsibility notice — include in Settings (clear data already present).
- Ad disclosure: included in Privacy Policy; ensure it states ad networks collect device identifiers.

4) Monetization & Ads Audit
Suggested setup:
- Primary: Banner ads on Home and Settings only.
- Interstitials: Rare and only after clear user action (e.g., after exporting invoice), frequency capped at 1 per session.
- Rewarded: Not required for utility app — avoid unless offering premium templates.
- Avoid placing banners near invoice action buttons; use bottom safe margins.
- Implement invalid traffic prevention: avoid auto-refreshing ad containers; integrate AdMob with test device IDs during QA.
- High-CPM: Use rewarded or interstitial sparingly; prioritize UX over revenue.

5) Hidden professional features (priority)
- Critical: Backup/export, Auto-save, Search, Edit/Delete history, Notification permission flow.
- Recommended: Update checker, Rate app popup (after N uses), Feedback/report form, Dark mode (exists), Empty-state screens.
- Optional: Root/emulator detection, PDF password protection, Clipboard scrub on copy.

6) Business trust & quality signals
- Improve branding: consistent name `StoreBill`, refine color palette, use professional typography (Google Fonts present).
- Screenshots: Show invoices, export, and history screens.
- Add company/support email and privacy URL in store listings.

7) Store listing optimization
- App title: `StoreBill — Invoice & Billing` (short) or `StoreBill: Invoices, Khata & Business Card` (long)
- Short desc: `Create professional invoices offline — export PDF, track payments.`
- Long desc: emphasize offline-first, privacy, easy backups, business features.
- Keywords: invoice, billing, receipt, ledger, khata, invoice maker, business card.
- Screenshots: Home, New Invoice (preview), Export PDF, Khata ledger, Business card.

8) Security & device safety
- Use encrypted local storage for sensitive data (consider Hive encryption or SQLCipher).
- When exporting CSV/PDF warn user about sharing sensitive info.
- Clipboard: clear clipboard after copying sensitive values.
- Disable screenshot for sensitive screens if needed (platform-specific flags).

9) Performance & stability
- Lazy load invoice history list (already implemented filtering) and avoid heavy synchronous operations on UI thread.
- Compress images used for logos before embedding into PDF.
- Minimize app size: remove unused assets and dev deps.

10) Final release checklist
Must-fix:
- Provide hosted Privacy Policy URL for Play Store.
- Produce final PNG icons (512x512 and 1024x1024) and adaptive Android icons.
- Verify no duplicate invoice saves. (fixed)
- Ensure no ads during invoice creation or export flows.

Optional but recommended:
- Implement notification detail page listing due khata invoices and quick actions.
- Implement analytics with privacy-safe settings and non-identifying events only.


Implementation notes & next steps
- I added in-app Privacy/Terms/About pages and linked them from Settings.
- I added `assets/storebill_icon.svg` for your icon; convert to PNGs.
- I removed the features button from Home and ensured history search/edit/delete is present.

If you want, I can:
- Generate PNG icons (requires embedding binary data — I can output base64 files or provide scripts to create them locally).
- Implement in-app notification listing and permission flow.
- Produce a hosted privacy policy HTML file for you to upload and point at in Play Console.

