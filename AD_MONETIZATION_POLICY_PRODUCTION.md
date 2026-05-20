AD MONETIZATION — Production Safety Lock (policy-ready)

Safe vs Unsafe screens
- SAFE (banners/native allowed): Home, Settings, About
- UNSAFE (no ads allowed): Invoice editor, Export/Share/Print flows, History item action sheets, Payment/Calculation screens, Notification detail flows

Interstitial rules
- Trigger only on explicit user action (e.g., "More templates")
- Max 1 interstitial per session
- Do not show on app start, during save/export, or while editing

Banner rules
- Place in `Scaffold` `bottomNavigationBar` with at least 16dp padding from interactive elements
- Refresh >= 30 seconds
- Pause refresh while any text field is focused

Rewarded ads
- Allowed only for non-essential cosmetic features (e.g., optional templates)
- Do not gate critical features (exporting/printing)
- Limit: 2 rewarded views per user per day

Invalid traffic prevention
- Use test ad units during QA and register test devices
- Do not programmatically click or auto-focus ads
- Monitor CTR; disable placements if CTR spikes
- Use mediation filters to block sensitive categories

Accidental click prevention
- Ensure 48px (16dp) spacing between ad and critical buttons
- Do not animate ads near touch targets
- Do not place ads in lists where item swipe/drag could overlap ad

Frequency caps
- Interstitial: 1 per session
- Banner refresh: >=30s
- Rewarded: <=2/day

CPM optimization (policy-safe)
- Use MAX mediation and native ads in passive Home lists to increase eCPM
- Prioritize networks with higher eCPM but adhere to placement rules
- Monitor and remove placements that trigger invalid traffic alerts

Code-level enforcement pseudo-code

// AppController (pseudo)
class AppController {
  bool hasShownInterstitialThisSession = false;

  void onAppBackgrounded() {
    hasShownInterstitialThisSession = false; // reset on background
  }

  bool canShowInterstitial(String screenName) {
    if (hasShownInterstitialThisSession) return false;
    if (screenName == 'InvoiceEditor' || screenName == 'ExportFlow' || screenName == 'HistoryAction') return false;
    return true;
  }

  void showInterstitial(String screenName) {
    if (!canShowInterstitial(screenName)) return;
    // show interstitial
    hasShownInterstitialThisSession = true;
  }

  bool canShowBanner(String screenName, bool isTextInputFocused) {
    if (isTextInputFocused) return false;
    if (screenName == 'InvoiceEditor' || screenName == 'ExportFlow') return false;
    return ['Home','Settings','About'].contains(screenName);
  }
}

// Banner refresh control
if (banner.isVisible && !isTextInputFocused) {
  scheduleRefresh(after: 30s);
}

// Rewarded gating
int rewardedToday = getRewardCountToday();
if (rewardedToday >= 2) { disableRewarded(); }

Implementation checklist
- [ ] Implement `hasShownInterstitialThisSession` and reset logic
- [ ] Block ads on forbidden screens in code
- [ ] Pause banner refresh on input focus
- [ ] Configure test ad IDs for QA
- [ ] Document ad placements in Play/App Store notes
