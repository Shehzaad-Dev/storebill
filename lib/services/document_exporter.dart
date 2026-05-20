import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/app_state.dart';
import '../models/line_item.dart';

abstract final class DocumentExporter {
  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  static NumberFormat money(AppState s) => NumberFormat.currency(symbol: '${s.currencySymbol} ', decimalDigits: 0);

  static Future<void> openWhatsAppWithPhone(String phone, {String? message, List<XFile>? files}) async {
    final d = _digits(phone);
    if (d.isEmpty) return;
    if (files != null && files.isNotEmpty) {
      await Share.shareXFiles(files, text: message ?? '');
      return;
    }
    if (message == null || message.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$d?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<File> writeTempPdf(List<int> bytes, String name) async {
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/$name');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  static Future<void> sharePdfFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text ?? 'Invoice PDF');
  }

  static PdfColor _pdfColor(Color c) => PdfColor.fromInt(c.toARGB32());

  static Future<Uint8List> buildInvoicePdfBytes({
    required AppState s,
    required List<LineItem> lines,
    required int invoiceNumber,
    Uint8List? logoBytes,
  }) async {
    final doc = pw.Document();
    final currency = money(s);
    final date = DateFormat('d MMM y').format(DateTime.now());
    final accent = s.invoiceAccent;

    pw.Widget? logoWidget;
    if (logoBytes != null && logoBytes.isNotEmpty) {
      logoWidget = pw.Image(pw.MemoryImage(logoBytes), width: 52, height: 52);
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          padding: const pw.EdgeInsets.all(18),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 4,
                decoration: pw.BoxDecoration(
                  color: _pdfColor(accent),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logoWidget != null) ...[logoWidget, pw.SizedBox(width: 12)],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(s.shopName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                        pw.SizedBox(height: 4),
                        pw.Text(s.shopLineForPreview, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        if (s.shopEmail.trim().isNotEmpty) pw.Text(s.shopEmail, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INV #${invoiceNumber.toString().padLeft(3, '0')}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text(date, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              if (s.customerName.trim().isNotEmpty)
                pw.Text(
                  'Bill to: ${s.customerName}${s.customerPhone.trim().isNotEmpty ? ' · ${s.customerPhone}' : ''}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                ),
              if (s.customerName.trim().isNotEmpty) pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _cell('Item', bold: true),
                      _cell('Qty', bold: true, center: true),
                      _cell('Price', bold: true, right: true),
                      _cell('Total', bold: true, right: true),
                    ],
                  ),
                  ...lines.map(
                    (e) => pw.TableRow(
                      children: [
                        _cell(e.name.isEmpty ? '—' : e.name),
                        _cell('${e.qty}', center: true),
                        _cell(currency.format(e.unitPrice), right: true),
                        _cell(currency.format(e.lineTotal), right: true),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              _moneyRow('Subtotal', currency.format(s.subtotal(lines))),
              _moneyRow('Discount', currency.format(s.discount)),
              _moneyRow('Tax (${s.taxPercent}%)', currency.format(s.taxAmount(lines))),
              pw.Divider(thickness: 0.8, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.Text(currency.format(s.grandTotal(lines)), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Center(child: pw.Text(s.footerNote, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600))),
            ],
          ),
        ),
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  static pw.Widget _moneyRow(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(k, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
          pw.Text(v, style: const pw.TextStyle(fontSize: 11, color: PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false, bool center = false, bool right = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : (right ? pw.TextAlign.right : pw.TextAlign.left),
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.black,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Future<void> shareInvoicePdf({
    required AppState s,
    required List<LineItem> lines,
    required int invoiceNumber,
    Uint8List? logoBytes,
  }) async {
    final bytes = await buildInvoicePdfBytes(s: s, lines: lines, invoiceNumber: invoiceNumber, logoBytes: logoBytes);
    final file = await writeTempPdf(bytes.toList(), 'invoice_$invoiceNumber.pdf');
    await sharePdfFile(file);
  }

  static Future<void> printInvoice({
    required AppState s,
    required List<LineItem> lines,
    required int invoiceNumber,
    Uint8List? logoBytes,
  }) async {
    final bytes = await buildInvoicePdfBytes(s: s, lines: lines, invoiceNumber: invoiceNumber, logoBytes: logoBytes);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<void> buildReceiptPdfAndPrint({
    required AppState s,
    required List<LineItem> lines,
    required int receiptNumber,
  }) async {
    final bytes = await buildReceiptPdfBytes(s: s, lines: lines, receiptNumber: receiptNumber);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<Uint8List> buildReceiptPdfBytes({
    required AppState s,
    required List<LineItem> lines,
    required int receiptNumber,
  }) async {
    final doc = _receiptDocument(s, lines, receiptNumber);
    return Uint8List.fromList(await doc.save());
  }

  static pw.Document _receiptDocument(AppState s, List<LineItem> lines, int receiptNumber) {
    final doc = pw.Document();
    final currency = money(s);
    final date = DateFormat('dd/MM/y').format(DateTime.now());

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (_) => pw.Container(
          color: PdfColors.white,
          padding: const pw.EdgeInsets.all(10),
          child: pw.DefaultTextStyle(
            style: pw.TextStyle(fontSize: 9, color: PdfColors.black, font: pw.Font.helvetica()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(child: pw.Text(s.shopName.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 2),
                pw.Center(child: pw.Text(s.shopAddress, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9))),
                pw.Center(child: pw.Text('Tel: ${s.shopPhone}', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9))),
                pw.Divider(color: PdfColors.grey400, borderStyle: pw.BorderStyle.dashed),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Receipt #: ${receiptNumber.toString().padLeft(3, '0')}', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9)),
                    pw.Text(date, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9)),
                  ],
                ),
                pw.Divider(color: PdfColors.grey400, borderStyle: pw.BorderStyle.dashed),
                ...lines.map(
                  (e) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('${e.name} x${e.qty}', style: const pw.TextStyle(fontSize: 10))),
                      pw.Text(currency.format(e.lineTotal), style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Divider(color: PdfColors.grey400, borderStyle: pw.BorderStyle.dashed),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text(currency.format(s.subtotal(lines)), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('--- THANK YOU ---', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9))),
              ],
            ),
          ),
        ),
      ),
    );
    return doc;
  }

  static String invoiceSummaryText(AppState s, List<LineItem> lines, int invoiceNumber) {
    final b = StringBuffer();
    b.writeln('${s.shopName} — Invoice #${invoiceNumber.toString().padLeft(3, '0')}');
    b.writeln(s.shopLineForPreview);
    b.writeln('---');
    for (final e in lines) {
      b.writeln('${e.name} ×${e.qty} = ${s.currencySymbol} ${e.lineTotal.toStringAsFixed(0)}');
    }
    b.writeln('Total: ${s.currencySymbol} ${s.grandTotal(lines).toStringAsFixed(0)}');
    b.writeln(s.footerNote);
    return b.toString();
  }
}
