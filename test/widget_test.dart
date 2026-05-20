import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:storebill/data/repositories/app_repository.dart';
import 'package:storebill/domain/app_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test(
    'AppRepository opens Hive in a temp directory (no initFlutter)',
    () async {
      final dir = await Directory.systemTemp.createTemp('invoice_hive_test_');
      Hive.init(dir.path);
      final repo = AppRepository();
      await repo.init(useFlutterPath: false);
      final s = repo.load();
      expect(s.currency, CurrencyCode.pkr);
      expect(s.invoiceHistory, isEmpty);
      await Hive.close();
      await dir.delete(recursive: true);
    },
  );

  testWidgets('MaterialApp renders without hanging', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('DukaanDoc'))),
    );
    await tester.pump();
    expect(find.text('DukaanDoc'), findsOneWidget);
  });
}
