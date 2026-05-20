import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../application/app_controller.dart';
import '../models/line_item.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';

class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final lines = s.receiptLines;
    final dateStr = DateFormat('dd/MM/y').format(DateTime.now());
    final total = s.subtotal(lines);
    final fmt = DocumentExporter.money(s);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _PageHeader(onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 24 + bottom),
              children: [
                Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(13),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Text(s.shopName.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: DukaanColors.black)),
                        const SizedBox(height: 4),
                        Text(s.shopAddress, style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g5)),
                        Text('Tel: ${s.shopPhone}', style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g5)),
                        Divider(color: DukaanColors.g3.withValues(alpha: 0.6), height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Receipt #: ${s.receiptDraftNumber.toString().padLeft(3, '0')}', style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4)),
                            Text(dateStr, style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: DukaanColors.g3.withValues(alpha: 0.6)),
                        for (final e in lines)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(child: Text('${e.name} x${e.qty}', style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g5))),
                                Text(fmt.format(e.lineTotal), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: DukaanColors.black)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Divider(color: DukaanColors.g3.withValues(alpha: 0.6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL', style: GoogleFonts.dmSans(fontSize: 12, color: DukaanColors.g5, fontWeight: FontWeight.w700)),
                            Text(fmt.format(total), style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: DukaanColors.black)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('--- THANK YOU ---', style: GoogleFonts.dmSans(fontSize: 9, color: DukaanColors.g4, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _CardSection(
                  title: 'QUICK ADD ITEMS',
                  icon: Icons.bolt_rounded,
                  child: Column(
                    children: [
                      for (var i = 0; i < lines.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _ReceiptLineEditor(ref: ref, index: i, item: lines[i]),
                        ),
                      OutlinedButton.icon(
                        onPressed: ctrl.addReceiptLine,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? DukaanColors.darkSurfaceVariant : DukaanColors.g1,
                          side: const BorderSide(color: DukaanColors.g3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                        icon: const Icon(Icons.add, size: 16, color: DukaanColors.g4),
                        label: Text('Add item', style: GoogleFonts.dmSans(fontSize: 12, color: DukaanColors.g4)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? DukaanColors.darkSurfaceVariant : DukaanColors.g2,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(fmt.format(total), style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: DukaanColors.black,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await DocumentExporter.buildReceiptPdfAndPrint(s: s, lines: lines, receiptNumber: s.receiptDraftNumber);
                          await ctrl.recordReceiptExport();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt saved to history')));
                          }
                        },
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: Text('Print receipt', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: const BorderSide(color: DukaanColors.g3),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final b = StringBuffer('${s.shopName}\nReceipt #${s.receiptDraftNumber}\n');
                          for (final e in lines) {
                            b.writeln('${e.name} x${e.qty}  ${fmt.format(e.lineTotal)}');
                          }
                          b.writeln('Total: ${fmt.format(total)}');
                          final pdf = await DocumentExporter.buildReceiptPdfBytes(s: s, lines: lines, receiptNumber: s.receiptDraftNumber);
                          final f = await DocumentExporter.writeTempPdf(pdf.toList(), 'receipt_${s.receiptDraftNumber}.pdf');
                          await Share.shareXFiles([XFile(f.path)], text: b.toString());
                          await ctrl.recordReceiptExport();
                        },
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: Text('Send', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DukaanColors.black,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 14, 13),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(40, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Quick receipt', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: DukaanColors.g4),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ReceiptLineEditor extends StatefulWidget {
  const _ReceiptLineEditor({required this.ref, required this.index, required this.item});

  final WidgetRef ref;
  final int index;
  final LineItem item;

  @override
  State<_ReceiptLineEditor> createState() => _ReceiptLineEditorState();
}

class _ReceiptLineEditorState extends State<_ReceiptLineEditor> {
  late TextEditingController _name;
  late TextEditingController _qty;
  late TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item.name);
    _qty = TextEditingController(text: '${widget.item.qty}');
    _price = TextEditingController(text: widget.item.unitPrice == widget.item.unitPrice.roundToDouble() ? '${widget.item.unitPrice.toInt()}' : '${widget.item.unitPrice}');
  }

  @override
  void didUpdateWidget(covariant _ReceiptLineEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.name != widget.item.name && widget.item.name != _name.text) _name.text = widget.item.name;
    if (oldWidget.item.qty != widget.item.qty) _qty.text = '${widget.item.qty}';
    if (oldWidget.item.unitPrice != widget.item.unitPrice) {
      _price.text = widget.item.unitPrice == widget.item.unitPrice.roundToDouble() ? '${widget.item.unitPrice.toInt()}' : '${widget.item.unitPrice}';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ref.read(appControllerProvider.notifier);
    final fill = Theme.of(context).brightness == Brightness.dark ? DukaanColors.darkSurfaceVariant : DukaanColors.g1;
    InputDecoration deco() => InputDecoration(
          hintText: null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          filled: true,
          fillColor: fill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: DukaanColors.g3, width: 0.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: DukaanColors.g3, width: 0.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: DukaanColors.black)),
        );

    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 340;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                decoration: deco().copyWith(hintText: 'Item name'),
                onChanged: (v) => ctrl.updateReceiptLine(widget.index, name: v),
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qty,
                      decoration: deco().copyWith(hintText: 'Qty'),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        final q = int.tryParse(v);
                        if (q != null) ctrl.updateReceiptLine(widget.index, qty: q);
                      },
                      style: GoogleFonts.dmSans(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _price,
                      decoration: deco().copyWith(hintText: 'Price'),
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      onChanged: (v) => ctrl.updateReceiptLine(widget.index, unitPrice: double.tryParse(v) ?? 0),
                      style: GoogleFonts.dmSans(fontSize: 12),
                    ),
                  ),
                  IconButton(onPressed: () => ctrl.removeReceiptLine(widget.index), icon: const Icon(Icons.close)),
                ],
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _name,
                decoration: deco().copyWith(hintText: 'Item'),
                onChanged: (v) => ctrl.updateReceiptLine(widget.index, name: v),
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                controller: _qty,
                decoration: deco().copyWith(hintText: 'Qty'),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  final q = int.tryParse(v);
                  if (q != null) ctrl.updateReceiptLine(widget.index, qty: q);
                },
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _price,
                decoration: deco().copyWith(hintText: 'Price'),
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                onChanged: (v) => ctrl.updateReceiptLine(widget.index, unitPrice: double.tryParse(v) ?? 0),
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
            ),
            IconButton(onPressed: () => ctrl.removeReceiptLine(widget.index), icon: const Icon(Icons.close, size: 20)),
          ],
        );
      },
    );
  }
}
