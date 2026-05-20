import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DukaanDoc'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'your preferences'**
  String get settingsSubtitle;

  /// No description provided for @shopProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop name & address'**
  String get shopProfile;

  /// No description provided for @shopLogo.
  ///
  /// In en, this message translates to:
  /// **'Shop logo'**
  String get shopLogo;

  /// No description provided for @invoiceFooter.
  ///
  /// In en, this message translates to:
  /// **'Invoice footer text'**
  String get invoiceFooter;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get darkModeSubtitle;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup to phone'**
  String get backup;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all invoices & cards'**
  String get backupSubtitle;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restore;

  /// No description provided for @restoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import JSON backup'**
  String get restoreSubtitle;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearData;

  /// No description provided for @clearDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wipe everything from phone'**
  String get clearDataSubtitle;

  /// No description provided for @clearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get clearConfirmTitle;

  /// No description provided for @clearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes invoices, receipts, settings, and your logo from this device.'**
  String get clearConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice history'**
  String get historyTitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get emptyHistory;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'see all'**
  String get seeAll;

  /// No description provided for @recentDocuments.
  ///
  /// In en, this message translates to:
  /// **'Recent documents'**
  String get recentDocuments;

  /// No description provided for @notificationsSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon'**
  String get notificationsSoon;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @restoreOk.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restoreOk;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @logoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Logo updated'**
  String get logoUpdated;

  /// No description provided for @logoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Logo removed'**
  String get logoRemoved;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @settingsGroupBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get settingsGroupBusiness;

  /// No description provided for @settingsGroupPrefs.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsGroupPrefs;

  /// No description provided for @settingsGroupData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsGroupData;

  /// No description provided for @settingsTagline.
  ///
  /// In en, this message translates to:
  /// **'Free forever · No login · Your data stays on this device'**
  String get settingsTagline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseGallery;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get removeLogo;

  /// No description provided for @shopProfileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop profile'**
  String get shopProfileDialogTitle;

  /// No description provided for @footerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice footer'**
  String get footerDialogTitle;

  /// No description provided for @currencyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyDialogTitle;

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageDialogTitle;

  /// No description provided for @shopLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Shown on invoices, receipts, and cards'**
  String get shopLogoHint;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get dataCleared;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
