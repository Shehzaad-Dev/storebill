import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app/router.dart';
import 'application/app_controller.dart';
import 'data/repositories/app_repository.dart';
import 'l10n/app_localizations.dart';
import 'services/reminder_service.dart';
import 'theme/dukaan_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }
  await ReminderService.init();
  final repo = AppRepository();
  await repo.init();
  final router = createAppRouter(repo);
  runApp(
    ProviderScope(
      overrides: [appRepositoryProvider.overrideWithValue(repo)],
      child: StoreBillApp(router: router),
    ),
  );
}

class StoreBillApp extends ConsumerWidget {
  const StoreBillApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appControllerProvider);
    return MaterialApp.router(
      title: 'StoreBill',
      debugShowCheckedModeBanner: false,
      theme: buildDukaanTheme(dark: false),
      darkTheme: buildDukaanTheme(dark: true),
      themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(s.localeTag),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
