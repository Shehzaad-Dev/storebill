import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/app_state.dart';

class AppRepository {
  static const _boxName = 'dukaan_v2';
  static const _keyApp = 'app';

  Box<dynamic>? _box;

  /// [useFlutterPath] false uses [Hive.init] path only — for tests / isolates where `initFlutter` hangs.
  Future<void> init({bool useFlutterPath = true}) async {
    if (useFlutterPath) {
      await Hive.initFlutter();
    }
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  AppState load() {
    final raw = _box?.get(_keyApp);
    if (raw is Map) {
      return AppState.fromJson(Map<dynamic, dynamic>.from(raw));
    }
    return AppState.initial();
  }

  Future<void> save(AppState state) async {
    await _box?.put(_keyApp, state.toJson());
  }

  Future<void> clearAll() async {
    await _box?.clear();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logoDir = Directory('${dir.path}/logo');
      if (await logoDir.exists()) {
        await logoDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  Future<String> appDocumentsPath() async {
    final d = await getApplicationDocumentsDirectory();
    return d.path;
  }

  Future<File?> readLogoFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final root = await appDocumentsPath();
    final f = File('$root/$relativePath');
    if (await f.exists()) return f;
    return null;
  }

  Future<String?> saveLogoBytes(List<int> bytes, {String ext = 'png'}) async {
    final root = await appDocumentsPath();
    final dir = Directory('$root/logo');
    if (!await dir.exists()) await dir.create(recursive: true);
    final path = 'logo/shop_logo.$ext';
    final f = File('$root/$path');
    await f.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<void> exportBackupJsonTo(File outFile, AppState state) async {
    final map = state.toJson();
    final logo = await readLogoFile(state.logoRelativePath);
    if (logo != null && await logo.exists()) {
      map['logoBase64'] = base64Encode(await logo.readAsBytes());
    }
    await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
  }

  Future<AppState> importBackupJsonFrom(File file) async {
    final text = await file.readAsString();
    final map = jsonDecode(text);
    if (map is! Map) throw const FormatException('Invalid backup');
    final m = Map<dynamic, dynamic>.from(map);
    final b64 = m.remove('logoBase64');
    var state = AppState.fromJson(m);
    if (b64 is String && b64.isNotEmpty) {
      final bytes = base64Decode(b64);
      final rel = await saveLogoBytes(bytes);
      state = state.copyWith(logoRelativePath: rel);
    }
    await save(state);
    return state;
  }
}
