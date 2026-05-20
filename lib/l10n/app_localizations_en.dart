// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DukaanDoc';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'your preferences';

  @override
  String get shopProfile => 'Shop name & address';

  @override
  String get shopLogo => 'Shop logo';

  @override
  String get invoiceFooter => 'Invoice footer text';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'App theme';

  @override
  String get backup => 'Backup to phone';

  @override
  String get backupSubtitle => 'Export all invoices & cards';

  @override
  String get restore => 'Restore backup';

  @override
  String get restoreSubtitle => 'Import JSON backup';

  @override
  String get clearData => 'Clear all data';

  @override
  String get clearDataSubtitle => 'Wipe everything from phone';

  @override
  String get clearConfirmTitle => 'Delete everything?';

  @override
  String get clearConfirmBody =>
      'This permanently deletes invoices, receipts, settings, and your logo from this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get historyTitle => 'Invoice history';

  @override
  String get search => 'Search';

  @override
  String get emptyHistory => 'No invoices yet';

  @override
  String get seeAll => 'see all';

  @override
  String get recentDocuments => 'Recent documents';

  @override
  String get notificationsSoon => 'Notifications coming soon';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get restoreOk => 'Backup restored';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get logoUpdated => 'Logo updated';

  @override
  String get logoRemoved => 'Logo removed';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get settingsGroupBusiness => 'Business profile';

  @override
  String get settingsGroupPrefs => 'Preferences';

  @override
  String get settingsGroupData => 'Data';

  @override
  String get settingsTagline =>
      'Free forever · No login · Your data stays on this device';

  @override
  String get save => 'Save';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get removeLogo => 'Remove logo';

  @override
  String get shopProfileDialogTitle => 'Shop profile';

  @override
  String get footerDialogTitle => 'Invoice footer';

  @override
  String get currencyDialogTitle => 'Currency';

  @override
  String get languageDialogTitle => 'Language';

  @override
  String get shopLogoHint => 'Shown on invoices, receipts, and cards';

  @override
  String get dataCleared => 'All data cleared';
}
