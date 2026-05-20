import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../application/app_controller.dart';
import '../domain/app_models.dart';
import '../l10n/app_localizations.dart';
import '../theme/dukaan_theme.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final onCard = scheme.onSurface;
    final muted = scheme.onSurfaceVariant;

    String clip(String t, int max) {
      final x = t.trim();
      if (x.length <= max) return x.isEmpty ? '—' : x;
      return '${x.substring(0, max)}…';
    }

    void snack(String m) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }

    Future<void> exportBackup() async {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: l.backup,
        fileName: 'dukaan_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (path == null) return;
      try {
        final repo = ref.read(appRepositoryProvider);
        final file = File(path.endsWith('.json') ? path : '$path.json');
        await repo.exportBackupJsonTo(file, ref.read(appControllerProvider));
        if (context.mounted) snack(l.backupSaved);
      } catch (_) {
        if (context.mounted) snack(l.backupFailed);
      }
    }

    Future<void> importBackup() async {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: false,
      );
      if (res == null || res.files.isEmpty) return;
      final p = res.files.single.path;
      if (p == null) return;
      try {
        final repo = ref.read(appRepositoryProvider);
        await repo.importBackupJsonFrom(File(p));
        ref.invalidate(appControllerProvider);
        if (context.mounted) snack(l.restoreOk);
      } catch (_) {
        if (context.mounted) snack(l.restoreFailed);
      }
    }

    Future<void> exportCustomersCsv() async {
      try {
        final f = await ref
            .read(appControllerProvider.notifier)
            .exportCustomersCsvFile();
        await Share.shareXFiles([
          XFile(f.path),
        ], text: 'Khata customers export');
      } catch (_) {
        if (context.mounted) snack(l.backupFailed);
      }
    }

    Future<void> exportInvoicesCsv() async {
      try {
        final f = await ref
            .read(appControllerProvider.notifier)
            .exportInvoicesCsvFile();
        await Share.shareXFiles([XFile(f.path)], text: 'Invoices export');
      } catch (_) {
        if (context.mounted) snack(l.backupFailed);
      }
    }

    Future<void> clearAll() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.clearConfirmTitle),
          content: Text(l.clearConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: DukaanColors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete),
            ),
          ],
        ),
      );
      if (ok != true) {
        return;
      }
      try {
        await ref.read(appRepositoryProvider).clearAll();
        ref.invalidate(appControllerProvider);
        if (context.mounted) {
          snack(l.dataCleared);
          context.go('/onboarding');
        }
      } catch (_) {
        if (context.mounted) snack(l.backupFailed);
      }
    }

    Future<void> showShopDialog() async {
      final name = TextEditingController(text: s.shopName);
      final phone = TextEditingController(text: s.shopPhone);
      final city = TextEditingController(text: s.shopCity);
      final address = TextEditingController(text: s.shopAddress);
      final email = TextEditingController(text: s.shopEmail);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.shopProfileDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: city,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: address,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () {
                ctrl.setShopName(name.text);
                ctrl.setShopPhone(phone.text);
                ctrl.setShopCity(city.text);
                ctrl.setShopAddress(address.text);
                ctrl.setShopEmail(email.text);
                Navigator.pop(ctx);
              },
              child: Text(l.save),
            ),
          ],
        ),
      );
    }

    Future<void> showFooterDialog() async {
      final c = TextEditingController(text: s.footerNote);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.footerDialogTitle),
          content: TextField(
            controller: c,
            maxLines: 3,
            decoration: const InputDecoration(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () {
                ctrl.setFooterNote(c.text);
                Navigator.pop(ctx);
              },
              child: Text(l.save),
            ),
          ],
        ),
      );
    }

    Future<void> pickLogoSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l.chooseGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final xfile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1600,
                  );
                  if (xfile == null) return;
                  try {
                    final bytes = await xfile.readAsBytes();
                    var ext = xfile.path.split('.').last.toLowerCase();
                    if (!['png', 'jpg', 'jpeg', 'webp'].contains(ext)) {
                      ext = 'png';
                    }
                    if (ext == 'jpg') {
                      ext = 'jpeg';
                    }
                    final repo = ref.read(appRepositoryProvider);
                    final rel = await repo.saveLogoBytes(bytes, ext: ext);
                    await ctrl.setLogoPath(rel);
                    if (context.mounted) snack(l.logoUpdated);
                  } catch (_) {
                    if (context.mounted) snack(l.backupFailed);
                  }
                },
              ),
              if (s.logoRelativePath != null)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: DukaanColors.red),
                  title: Text(l.removeLogo),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ctrl.setLogoPath(null);
                    if (context.mounted) snack(l.logoRemoved);
                  },
                ),
            ],
          ),
        ),
      );
    }

    Future<void> showCurrencyDialog() async {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(l.currencyDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                children: CurrencyCode.values
                    .map(
                      (c) => ListTile(
                        title: Text('${c.symbol} · ${c.label}'),
                        selected: s.currency == c,
                        trailing: s.currency == c
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () {
                          ctrl.setCurrency(c);
                          Navigator.pop(ctx);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.cancel),
              ),
            ],
          );
        },
      );
    }

    Future<void> showLanguageDialog() async {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.languageDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l.languageEnglish),
                selected: s.localeTag == 'en',
                trailing: s.localeTag == 'en'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  ctrl.setLocaleTag('en');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(l.languageUrdu),
                selected: s.localeTag == 'ur',
                trailing: s.localeTag == 'ur'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  ctrl.setLocaleTag('ur');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Material(
          color: DukaanColors.black,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.request_quote_rounded,
                      color: DukaanColors.black,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.settingsTitle,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        l.settingsSubtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: const Color(0xFF666666),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              _sec(l.settingsGroupBusiness),
              _group(context, [
                _tile(
                  context,
                  Icons.storefront_rounded,
                  l.shopProfile,
                  clip('${s.shopName} · ${s.shopAddress}', 48),
                  onCard,
                  muted,
                  showShopDialog,
                ),
                _tile(
                  context,
                  Icons.image_outlined,
                  l.shopLogo,
                  l.shopLogoHint,
                  onCard,
                  muted,
                  pickLogoSheet,
                ),
                _tile(
                  context,
                  Icons.edit_note_rounded,
                  l.invoiceFooter,
                  clip(s.footerNote, 56),
                  onCard,
                  muted,
                  showFooterDialog,
                ),
                _tile(
                  context,
                  Icons.badge_outlined,
                  'Business card',
                  'Preview, QR, share image',
                  onCard,
                  muted,
                  () => context.push('/card'),
                ),
              ]),
              _sec('Exports'),
              _group(context, [
                _tile(
                  context,
                  Icons.people_outline_rounded,
                  'Export customers',
                  'CSV (Khata book)',
                  onCard,
                  muted,
                  exportCustomersCsv,
                ),
                _tile(
                  context,
                  Icons.receipt_long_outlined,
                  'Export invoices',
                  'CSV (all invoices)',
                  onCard,
                  muted,
                  exportInvoicesCsv,
                ),
              ]),
              _sec(l.settingsGroupPrefs),
              _group(context, [
                _tile(
                  context,
                  Icons.currency_rupee_rounded,
                  l.currency,
                  '${s.currency.symbol} · ${s.currency.label}',
                  onCard,
                  muted,
                  showCurrencyDialog,
                ),
                _tile(
                  context,
                  Icons.language_rounded,
                  l.language,
                  s.localeTag == 'ur' ? l.languageUrdu : l.languageEnglish,
                  onCard,
                  muted,
                  showLanguageDialog,
                ),
                _toggleTile(
                  context,
                  Icons.dark_mode_outlined,
                  l.darkMode,
                  l.darkModeSubtitle,
                  onCard,
                  muted,
                  s.darkMode,
                  ctrl.setDarkMode,
                ),
              ]),
              _sec(l.settingsGroupData),
              _group(context, [
                _tile(
                  context,
                  Icons.storage_rounded,
                  l.backup,
                  l.backupSubtitle,
                  onCard,
                  muted,
                  exportBackup,
                ),
                _tile(
                  context,
                  Icons.restore_rounded,
                  l.restore,
                  l.restoreSubtitle,
                  onCard,
                  muted,
                  importBackup,
                ),
                _tile(
                  context,
                  Icons.delete_outline_rounded,
                  l.clearData,
                  l.clearDataSubtitle,
                  onCard,
                  muted,
                  clearAll,
                  danger: true,
                ),
              ]),
              _sec('Legal'),
              _group(context, [
                _tile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'View privacy policy',
                  onCard,
                  muted,
                  () async => context.push('/privacy'),
                ),
                _tile(
                  context,
                  Icons.article_outlined,
                  'Terms & Conditions',
                  'View terms of use',
                  onCard,
                  muted,
                  () async => context.push('/terms'),
                ),
                _tile(
                  context,
                  Icons.info_outline,
                  'About',
                  'App info and support',
                  onCard,
                  muted,
                  () async => context.push('/about'),
                ),
              ]),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: DukaanColors.g2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${l.appTitle} v1.0',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.settingsTagline,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: DukaanColors.g4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sec(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          t.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: DukaanColors.g4,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _group(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : DukaanColors.g2,
        ),
      ),
      child: Column(children: _joinDividers(children, isDark)),
    );
  }

  List<Widget> _joinDividers(List<Widget> items, bool isDark) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? const Color(0xFF2A2A2A) : DukaanColors.g2,
          ),
        );
      }
    }
    return out;
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color titleColor,
    Color subColor,
    Future<void> Function() onTap, {
    bool danger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DukaanColors.g2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: danger ? DukaanColors.red : DukaanColors.black,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: danger ? DukaanColors.red : titleColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      style: GoogleFonts.dmSans(fontSize: 10, color: subColor),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: subColor.withValues(alpha: 0.5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleTile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color titleColor,
    Color subColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DukaanColors.g2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: DukaanColors.black),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: GoogleFonts.dmSans(fontSize: 10, color: subColor),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DukaanColors.black,
            activeTrackColor: DukaanColors.g3,
          ),
        ],
      ),
    );
  }
}
