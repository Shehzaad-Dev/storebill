import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a [RepaintBoundary] into PNG bytes.
Future<void> shareWidgetPng({
  required GlobalKey boundaryKey,
  required String filename,
}) async {
  final ctx = boundaryKey.currentContext;
  if (ctx == null) return;
  await Future<void>.delayed(const Duration(milliseconds: 32));
  if (!ctx.mounted) return;
  final boundary = ctx.findRenderObject();
  if (boundary is! RenderRepaintBoundary) return;
  final image = await boundary.toImage(pixelRatio: 3);
  final bd = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bd == null) return;
  final bytes = bd.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles([XFile(file.path)], text: 'Business card');
}
