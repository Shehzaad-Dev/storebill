import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../application/app_controller.dart';
import '../domain/app_models.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';

class InvoiceHistoryPage extends ConsumerStatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  ConsumerState<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends ConsumerState<InvoiceHistoryPage> {
  final _search = TextEditingController();
  String _query = '';
  _Sort _sort = _Sort.newest;
  _PayFilter _payFilter = _PayFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<StoredInvoice> _filtered(List<StoredInvoice> all) {
    var list = [...all];
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        return e.customerName.toLowerCase().contains(q) ||
            e.shopName.toLowerCase().contains(q) ||
            '${e.number}'.contains(q) ||
            e.id.toLowerCase().contains(q);
      }).toList();
    }
    switch (_payFilter) {
      case _PayFilter.open:
        list = list.where((e) => e.status != 'paid').toList();
        break;
      case _PayFilter.paid:
        list = list.where((e) => e.status == 'paid').toList();
        break;
      case _PayFilter.khata:
        list = list.where((e) => e.isKhata).toList();
        break;
      case _PayFilter.all:
        break;
    }
    switch (_sort) {
      case _Sort.newest:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case _Sort.oldest:
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case _Sort.amountHigh:
        list.sort((a, b) => b.grandTotal().compareTo(a.grandTotal()));
        break;
      case _Sort.amountLow:
        list.sort((a, b) => a.grandTotal().compareTo(b.grandTotal()));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final list = _filtered(s.invoiceHistory);
    final fmt = DocumentExporter.money(s);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Material(
            color: DukaanColors.black,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 14, 13),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Invoice history',
                        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search customer or #',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _payFilter == _PayFilter.all,
                        onSelected: (_) => setState(() => _payFilter = _PayFilter.all),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Open'),
                        selected: _payFilter == _PayFilter.open,
                        onSelected: (_) => setState(() => _payFilter = _PayFilter.open),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Paid'),
                        selected: _payFilter == _PayFilter.paid,
                        onSelected: (_) => setState(() => _payFilter = _PayFilter.paid),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Khata'),
                        selected: _payFilter == _PayFilter.khata,
                        onSelected: (_) => setState(() => _payFilter = _PayFilter.khata),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Newest'),
                        selected: _sort == _Sort.newest,
                        onSelected: (_) => setState(() => _sort = _Sort.newest),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Oldest'),
                        selected: _sort == _Sort.oldest,
                        onSelected: (_) => setState(() => _sort = _Sort.oldest),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Amount ↓'),
                        selected: _sort == _Sort.amountHigh,
                        onSelected: (_) => setState(() => _sort = _Sort.amountHigh),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Amount ↑'),
                        selected: _sort == _Sort.amountLow,
                        onSelected: (_) => setState(() => _sort = _Sort.amountLow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No invoices yet', style: GoogleFonts.dmSans(color: DukaanColors.g4)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final inv = list[i];
                      final date = DateFormat('d MMM · h:mm a').format(inv.updatedAt);
                      return Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _sheet(context, inv, ctrl),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(color: DukaanColors.black, borderRadius: BorderRadius.circular(9)),
                                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inv.customerName.isEmpty ? 'Walk-in' : inv.customerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    Text(
                                      'INV #${inv.number.toString().padLeft(3, '0')} · $date${inv.isKhata ? ' · Khata' : ''}',
                                      style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4),
                                    ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(fmt.format(inv.grandTotal()), style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(inv.status.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 9, color: inv.status == 'paid' ? DukaanColors.green : const Color(0xFFB45309))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _sheet(BuildContext context, StoredInvoice inv, AppController ctrl) async {
    final full = ref.read(appControllerProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit in invoice tab'),
                onTap: () {
                  ctrl.loadInvoiceIntoDraft(inv);
                  ctrl.setMainTab(1);
                  Navigator.pop(ctx);
                  context.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Share PDF'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(appRepositoryProvider);
                  final bytes = await repo.readLogoFile(full.logoRelativePath);
                  Uint8List? lg;
                  if (bytes != null && await bytes.exists()) lg = await bytes.readAsBytes();
                  await DocumentExporter.shareInvoicePdf(
                    s: full,
                    lines: inv.lines,
                    invoiceNumber: inv.number,
                    logoBytes: lg,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text('Print'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(appRepositoryProvider);
                  final bytes = await repo.readLogoFile(full.logoRelativePath);
                  Uint8List? lg;
                  if (bytes != null && await bytes.exists()) lg = await bytes.readAsBytes();
                  await DocumentExporter.printInvoice(s: full, lines: inv.lines, invoiceNumber: inv.number, logoBytes: lg);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text('WhatsApp'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(appRepositoryProvider);
                  final bytes = await repo.readLogoFile(full.logoRelativePath);
                  Uint8List? lg;
                  if (bytes != null && await bytes.exists()) lg = await bytes.readAsBytes();
                  final pdf = await DocumentExporter.buildInvoicePdfBytes(s: full, lines: inv.lines, invoiceNumber: inv.number, logoBytes: lg);
                  final f = await DocumentExporter.writeTempPdf(pdf.toList(), 'invoice_${inv.number}.pdf');
                  final msg = DocumentExporter.invoiceSummaryText(full, inv.lines, inv.number);
                  await DocumentExporter.openWhatsAppWithPhone(
                    inv.customerPhone.trim().isNotEmpty ? inv.customerPhone : full.shopPhone,
                    message: msg,
                    files: [XFile(f.path)],
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: DukaanColors.red),
                title: Text('Delete', style: TextStyle(color: DukaanColors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete invoice?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) await ctrl.deleteInvoice(inv.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _Sort { newest, oldest, amountHigh, amountLow }

enum _PayFilter { all, open, paid, khata }
