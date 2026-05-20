AD MONETIZATION SAFETY RULES — StoreBill (copy-paste implementation rules)

1) Banner ads
- Allowed only on: Home, Settings, About pages
- Not allowed on: Invoice editor, Export/Share dialogs, History item action sheets, Notifications list
- Placement: Use `bottomNavigationBar` or `Scaffold` bottom with 16dp vertical padding from interactive elements.
- Refresh: >= 30 seconds. Pause refresh while text inputs are focused.

2) Interstitial ads
- Trigger only on explicit user actions (e.g., tapping "More templates" or promotional CTA).
- Frequency: Maximum 1 interstitial per app session. Track a boolean `hasShownInterstitialThisSession` in `AppController`.
- Do NOT show on app start, during save/export/print flows, or during invoice editing.

3) Rewarded ads
- Allowed only for non-essential, clearly-labeled cosmetic rewards (e.g., extra templates). Do NOT gate essential functionality (exporting, printing, creating invoices).
- Limit: Maximum 2 rewarded views per user per day.

4) Native ads
- If used, only in passive lists (Home feed) with clear ad labeling and spacing. Do NOT mix native ad tappable area with critical item actions.

5) Frequency & session rules
- Interstitial: 1 per session
- Banner refresh: >=30s, pause during input
- Rewarded: <=2/day

6) Invalid traffic & accidental click prevention
- Use test ads during QA; register test devices in each ad SDK.
- Do not place ads near navigation or action buttons; ensure minimum tappable distances (>=16dp).
- Disable auto-clickable overlays and do not animate ads near touch targets.
- Implement server-side / SDK mediation filters to block sensitive categories (gambling, adult content).

7) CPM optimization (policy-safe)
- Use mediation (AppLovin MAX) to increase fill-rate and competition.
- Prioritize native ads on Home list and rewarded/optional ads for non-essential items.
- Monitor invalid traffic metrics, adjust placements if CTR spikes unexpectedly.

8) Implementation checklist (developer)
- [ ] Remove any ad widget calls from invoice editor and export flows
- [ ] Add `hasShownInterstitialThisSession` flag and reset when app backgrounded
- [ ] Pause banner refresh during text input via FocusNode listeners
- [ ] Configure test devices and use test ad IDs in debug builds
- [ ] Include "This app contains ads" disclosure in Settings