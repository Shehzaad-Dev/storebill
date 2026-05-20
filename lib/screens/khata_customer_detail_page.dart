import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../application/app_controller.dart';
import '../domain/app_models.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';

class KhataCustomerDetailPage extends ConsumerWidget {
  const KhataCustomerDetailPage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final c = s.khataCustomerById(customerId);
    if (c == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer')),
        body: const Center(child: Text('Customer not found')),
      );
    }
    final fmt = DocumentExporter.money(s);
    final due = s.customerDue(customerId);
    final paid = s.totalPaymentsForCustomer(customerId);
    final invoiced = s.totalKhataInvoicedForCustomer(customerId);
    final invs = s.invoiceHistory.where((e) => e.isKhata && e.khataCustomerId == customerId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final pays = s.customerPayments.where((e) => e.customerId == customerId).toList()..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    final cleared = due < 0.01;
    final nextRem = s.nextReminderMsForCustomer(customerId);
    final overdue = s.customerHasOverdueReminder(customerId);

    Future<void> receiveSheet() async {
      final amt = TextEditingController();
      final note = TextEditingController();
      String method = 'cash';
      DateTime paidAt = DateTime.now();
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: MediaQuery.paddingOf(ctx).bottom + 16),
            child: StatefulBuilder(
              builder: (ctx, setSt) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Receive payment', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amt,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ChoiceChip(label: const Text('Cash'), selected: method == 'cash', onSelected: (_) => setSt(() => method = 'cash')),
                        const SizedBox(width: 8),
                        ChoiceChip(label: const Text('Online'), selected: method == 'online', onSelected: (_) => setSt(() => method = 'online')),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Payment date'),
                      subtitle: Text(DateFormat('d MMM y').format(paidAt)),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final d = await showDatePicker(context: ctx, initialDate: paidAt, firstDate: DateTime(2020), lastDate: DateTime(2100));
                        if (d != null) setSt(() => paidAt = d);
                      },
                    ),
                    TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (optional)')),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final v = double.tryParse(amt.text) ?? 0;
                        if (v <= 0) return;
                        await ctrl.receivePayment(customerId: customerId, amount: v, method: method, note: note.text, paidAt: paidAt);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded')));
                        }
                      },
                      child: const Text('Save payment'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: DukaanColors.black,
        foregroundColor: Colors.white,
        title: Text(c.name, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final name = TextEditingController(text: c.name);
              final phone = TextEditingController(text: c.phone);
              final wa = TextEditingController(text: c.whatsapp);
              final addr = TextEditingController(text: c.address);
              final note = TextEditingController(text: c.note);
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Edit customer'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                        TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
                        TextField(controller: wa, decoration: const InputDecoration(labelText: 'WhatsApp')),
                        TextField(controller: addr, decoration: const InputDecoration(labelText: 'Address')),
                        TextField(controller: note, decoration: const InputDecoration(labelText: 'Note')),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () async {
                        await ctrl.updateKhataCustomer(
                          c.copyWith(
                            name: name.text,
                            phone: phone.text,
                            whatsapp: wa.text,
                            address: addr.text,
                            note: note.text,
                            updatedAtMs: DateTime.now().millisecondsSinceEpoch,
                          ),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cleared)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'This customer has cleared all dues.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF15803D)),
              ),
            ),
          _summaryCard(context, 'Active due', fmt.format(due), overdue ? DukaanColors.red : DukaanColors.black),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _summaryCard(context, 'Total paid', fmt.format(paid), DukaanColors.g5)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard(context, 'Khata billed', fmt.format(invoiced), DukaanColors.g5)),
            ],
          ),
          const SizedBox(height: 8),
          _summaryCard(context, 'Khata invoices', '${invs.length}', DukaanColors.g5),
          if (nextRem != null) ...[
            const SizedBox(height: 8),
            _summaryCard(
              context,
              'Next reminder',
              DateFormat('d MMM y').format(DateTime.fromMillisecondsSinceEpoch(nextRem)),
              overdue ? DukaanColors.red : DukaanColors.g5,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: cleared ? null : () => receiveSheet(),
            style: FilledButton.styleFrom(backgroundColor: DukaanColors.black, minimumSize: const Size.fromHeight(46)),
            icon: const Icon(Icons.payments_outlined, size: 20),
            label: const Text('Receive payment'),
          ),
          const SizedBox(height: 22),
          Text('PAYMENTS', style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          if (pays.isEmpty)
            Text('No payments yet.', style: GoogleFonts.dmSans(fontSize: 12, color: DukaanColors.g4))
          else
            ...pays.map((p) => _tile(title: '${p.method.toUpperCase()} · ${fmt.format(p.amount)}', sub: DateFormat('d MMM y').format(p.paidAt), note: p.note)),
          const SizedBox(height: 22),
          Text('KHATA INVOICES', style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          if (invs.isEmpty)
            Text('No udhar invoices linked yet.', style: GoogleFonts.dmSans(fontSize: 12, color: DukaanColors.g4))
          else
            ...invs.map((e) => _invTile(context, ref, e)),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, String k, String v, Color vColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DukaanColors.g3),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 9, color: DukaanColors.g4, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(v, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: vColor)),
        ],
      ),
    );
  }

  Widget _tile({required String title, required String sub, String note = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: DukaanColors.g3)),
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(note.isEmpty ? sub : '$sub · $note', style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g4)),
      ),
    );
  }

  Widget _invTile(BuildContext context, WidgetRef ref, StoredInvoice e) {
    final s = ref.watch(appControllerProvider);
    final fmt = DocumentExporter.money(s);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: DukaanColors.g3)),
        title: Text('INV #${e.number.toString().padLeft(3, '0')} · ${fmt.format(e.grandTotal())}', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('d MMM y').format(e.updatedAt), style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g4)),
        trailing: Chip(
          label: Text(e.status == 'paid' ? 'Paid' : 'Due', style: GoogleFonts.dmSans(fontSize: 10)),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () {
          ref.read(appControllerProvider.notifier).loadInvoiceIntoDraft(e);
          ref.read(appControllerProvider.notifier).setMainTab(1);
          context.go('/');
        },
      ),
    );
  }
}
