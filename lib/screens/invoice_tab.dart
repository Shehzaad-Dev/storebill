import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../application/app_controller.dart';
import '../domain/app_state.dart';
import '../domain/khata_models.dart';
import '../models/line_item.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';

class InvoiceTab extends ConsumerStatefulWidget {
  const InvoiceTab({super.key});

  @override
  ConsumerState<InvoiceTab> createState() => _InvoiceTabState();
}

class _InvoiceTabState extends ConsumerState<InvoiceTab> {
  late final TextEditingController _shopName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _footer;
  late final TextEditingController _custName;
  late final TextEditingController _custPhone;
  late final TextEditingController _discount;
  late final TextEditingController _tax;

  @override
  void initState() {
    super.initState();
    final s = ref.read(appControllerProvider);
    _shopName = TextEditingController(text: s.shopName);
    _phone = TextEditingController(text: s.shopPhone);
    _city = TextEditingController(text: s.shopCity);
    _footer = TextEditingController(text: s.footerNote);
    _custName = TextEditingController(text: s.customerName);
    _custPhone = TextEditingController(text: s.customerPhone);
    _discount = TextEditingController(
      text: s.discount == 0 ? '0' : s.discount.toString(),
    );
    _tax = TextEditingController(
      text: s.taxPercent == 0 ? '0' : s.taxPercent.toString(),
    );
  }

  @override
  void dispose() {
    _shopName.dispose();
    _phone.dispose();
    _city.dispose();
    _footer.dispose();
    _custName.dispose();
    _custPhone.dispose();
    _discount.dispose();
    _tax.dispose();
    super.dispose();
  }

  Future<Uint8List?> _logoBytes() async {
    final s = ref.read(appControllerProvider);
    final repo = ref.read(appRepositoryProvider);
    final f = await repo.readLogoFile(s.logoRelativePath);
    if (f == null || !await f.exists()) return null;
    return f.readAsBytes();
  }

  String _fmt(AppState s, double v) => DocumentExporter.money(s).format(v);

  Future<void> _afterExportActions() async {
    await ref.read(appControllerProvider.notifier).recordInvoiceExport();
  }

  bool _ensureKhataOk(AppState s) {
    if (s.invoiceDraftPaymentType != 'khata') {
      return true;
    }
    if (s.draftKhataCustomerId != null && s.draftKhataCustomerId!.isNotEmpty) {
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select a customer for Khata / Udhar')),
    );
    return false;
  }

  Future<void> _pickCustomerSheet(AppState s, AppController ctrl) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: const Text('New customer'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/khata/add');
                },
              ),
              const Divider(height: 1),
              SizedBox(
                height: 320,
                child: s.khataCustomers.isEmpty
                    ? const Center(child: Text('No customers yet'))
                    : ListView(
                        children: s.khataCustomers
                            .map(
                              (KhataCustomer c) => ListTile(
                                title: Text(c.name),
                                subtitle: Text(c.phone.isEmpty ? '—' : c.phone),
                                trailing: Text(
                                  DocumentExporter.money(
                                    s,
                                  ).format(s.customerDue(c.id)),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: s.customerDue(c.id) < 0.01
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                onTap: () {
                                  ctrl.setDraftKhataCustomerId(c.id);
                                  Navigator.pop(ctx);
                                },
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reminderInDays(int days) {
    final at = DateTime.now().add(Duration(days: days));
    final nine = DateTime(at.year, at.month, at.day, 9);
    ref
        .read(appControllerProvider.notifier)
        .setDraftReminder(
          atMs: nine.millisecondsSinceEpoch,
          note: 'Payment reminder',
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final lines = s.invoiceLines;
    final dateStr = DateFormat('d MMM y').format(DateTime.now());
    final invNo = s.invoiceDraftNumber.toString().padLeft(3, '0');
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        _PageHeader(
          title: 'New invoice',
          onBack: () => ctrl.setMainTab(0),
          onRefresh: () => ctrl.startNewInvoiceDraft(),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 24 + bottomInset),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _LivePreview(
                invNo: invNo,
                dateStr: dateStr,
                shopName: s.shopName,
                shopLine: s.shopLineForPreview,
                lines: lines,
                totalStr: _fmt(s, s.grandTotal(lines)),
                footer: s.footerNote,
                accent: s.invoiceAccent,
                currencyLabel: s.currencySymbol,
              ),
              const SizedBox(height: 9),
              _CardSection(
                title: 'SHOP DETAILS',
                icon: Icons.storefront_rounded,
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Shop name',
                      child: TextField(
                        controller: _shopName,
                        onChanged: ctrl.setShopName,
                        style: GoogleFonts.dmSans(fontSize: 13),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Phone',
                            child: TextField(
                              controller: _phone,
                              onChanged: ctrl.setShopPhone,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.dmSans(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LabeledField(
                            label: 'City',
                            child: TextField(
                              controller: _city,
                              onChanged: ctrl.setShopCity,
                              style: GoogleFonts.dmSans(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _LabeledField(
                      label: 'Footer note',
                      child: TextField(
                        controller: _footer,
                        onChanged: ctrl.setFooterNote,
                        style: GoogleFonts.dmSans(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              _CardSection(
                title: 'BILL TO',
                icon: Icons.person_outline_rounded,
                child: Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'Customer name',
                        child: TextField(
                          controller: _custName,
                          onChanged: ctrl.setCustomerName,
                          decoration: const InputDecoration(
                            hintText: 'Customer name',
                          ),
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LabeledField(
                        label: 'Phone (optional)',
                        child: TextField(
                          controller: _custPhone,
                          onChanged: ctrl.setCustomerPhone,
                          decoration: const InputDecoration(
                            hintText: '0300-...',
                          ),
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _CardSection(
                title: 'PAYMENT',
                icon: Icons.payments_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Cash'),
                          selected: s.invoiceDraftPaymentType == 'cash',
                          onSelected: (_) =>
                              ctrl.setInvoiceDraftPaymentType('cash'),
                        ),
                        ChoiceChip(
                          label: const Text('Online'),
                          selected: s.invoiceDraftPaymentType == 'online',
                          onSelected: (_) =>
                              ctrl.setInvoiceDraftPaymentType('online'),
                        ),
                        ChoiceChip(
                          label: const Text('Loan / Khata'),
                          selected: s.invoiceDraftPaymentType == 'khata',
                          onSelected: (_) =>
                              ctrl.setInvoiceDraftPaymentType('khata'),
                        ),
                      ],
                    ),
                    if (s.invoiceDraftPaymentType == 'khata') ...[
                      const SizedBox(height: 10),
                      Text(
                        'LINK CUSTOMER',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: DukaanColors.g4,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () => _pickCustomerSheet(s, ctrl),
                        icon: const Icon(Icons.group_outlined, size: 18),
                        label: Text(
                          s.draftKhataCustomerId == null
                              ? 'Select or create customer'
                              : (s
                                        .khataCustomerById(
                                          s.draftKhataCustomerId,
                                        )
                                        ?.name ??
                                    'Linked'),
                          style: GoogleFonts.dmSans(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'REMINDER (OFFLINE)',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: DukaanColors.g4,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Tomorrow'),
                            onPressed: () => _reminderInDays(1),
                          ),
                          ActionChip(
                            label: const Text('3 days'),
                            onPressed: () => _reminderInDays(3),
                          ),
                          ActionChip(
                            label: const Text('7 days'),
                            onPressed: () => _reminderInDays(7),
                          ),
                          ActionChip(
                            label: const Text('Pick date'),
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 7),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null && context.mounted) {
                                final nine = DateTime(
                                  d.year,
                                  d.month,
                                  d.day,
                                  9,
                                );
                                ctrl.setDraftReminder(
                                  atMs: nine.millisecondsSinceEpoch,
                                  note: 'Payment reminder',
                                );
                              }
                            },
                          ),
                          if (s.draftReminderAtMs != null)
                            ActionChip(
                              label: const Text('Clear reminder'),
                              onPressed: () => ctrl.clearDraftReminder(),
                            ),
                        ],
                      ),
                      if (s.draftReminderAtMs != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Scheduled: ${DateFormat('d MMM y').format(DateTime.fromMillisecondsSinceEpoch(s.draftReminderAtMs!))} · 9:00',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: DukaanColors.g5,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              _CardSection(
                title: 'ITEMS',
                icon: Icons.list_alt_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 4, child: _head('Item')),
                        Expanded(child: _head('Qty', center: true)),
                        Expanded(flex: 2, child: _head('Price', right: true)),
                        const SizedBox(width: 28),
                      ],
                    ),
                    const SizedBox(height: 4),
                    for (var i = 0; i < lines.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: _InvoiceLineEditor(
                          ref: ref,
                          index: i,
                          item: lines[i],
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: ctrl.addInvoiceLine,
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? DukaanColors.darkSurfaceVariant
                            : DukaanColors.g1,
                        side: const BorderSide(color: DukaanColors.g3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: DukaanColors.g4,
                      ),
                      label: Text(
                        'Add item',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: DukaanColors.g4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? DukaanColors.darkSurfaceVariant
                            : DukaanColors.g2,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        children: [
                          _totalRow(
                            context,
                            'Subtotal',
                            _fmt(s, s.subtotal(lines)),
                          ),
                          _totalRow(context, 'Discount', _fmt(s, s.discount)),
                          _totalRow(
                            context,
                            'Tax (${s.taxPercent}%)',
                            _fmt(s, s.taxAmount(lines)),
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.4),
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _fmt(s, s.grandTotal(lines)),
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Discount amount',
                            child: TextField(
                              controller: _discount,
                              onChanged: (v) =>
                                  ctrl.setDiscount(double.tryParse(v) ?? 0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              style: GoogleFonts.dmSans(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LabeledField(
                            label: 'Tax %',
                            child: TextField(
                              controller: _tax,
                              onChanged: (v) =>
                                  ctrl.setTaxPercent(double.tryParse(v) ?? 0),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                              style: GoogleFonts.dmSans(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _CardSection(
                title: 'INVOICE COLOR',
                icon: Icons.palette_outlined,
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: List.generate(AppState.invoiceAccentColors.length, (
                    i,
                  ) {
                    final on = s.selectedInvoiceColorIndex == i;
                    return GestureDetector(
                      onTap: () => ctrl.setInvoiceColorIndex(i),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppState.invoiceAccentColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: on ? DukaanColors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (s.invoiceDraftPaymentType == 'khata')
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF14532D),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final cur = ref.read(appControllerProvider);
                      if (!_ensureKhataOk(cur)) return;
                      final ok = await ref
                          .read(appControllerProvider.notifier)
                          .saveKhataInvoiceToLedger();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Saved to Khata ledger'
                                  : 'Could not save — check customer',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                    ),
                    label: Text(
                      'Save to Khata (ledger only)',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: DukaanColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final cur = ref.read(appControllerProvider);
                        if (!_ensureKhataOk(cur)) return;
                        final lg = await _logoBytes();
                        await DocumentExporter.shareInvoicePdf(
                          s: cur,
                          lines: cur.invoiceLines,
                          invoiceNumber: cur.invoiceDraftNumber,
                          logoBytes: lg,
                        );
                        await _afterExportActions();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invoice saved and PDF ready to share',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: Text(
                        'Save PDF',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: const BorderSide(color: DukaanColors.g3),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final cur = ref.read(appControllerProvider);
                        if (!_ensureKhataOk(cur)) return;
                        final lg = await _logoBytes();
                        final pdf = await DocumentExporter.buildInvoicePdfBytes(
                          s: cur,
                          lines: cur.invoiceLines,
                          invoiceNumber: cur.invoiceDraftNumber,
                          logoBytes: lg,
                        );
                        final f = await DocumentExporter.writeTempPdf(
                          pdf.toList(),
                          'invoice_$invNo.pdf',
                        );
                        final msg = DocumentExporter.invoiceSummaryText(
                          cur,
                          cur.invoiceLines,
                          cur.invoiceDraftNumber,
                        );
                        await DocumentExporter.openWhatsAppWithPhone(
                          cur.customerPhone.trim().isNotEmpty
                              ? cur.customerPhone
                              : cur.shopPhone,
                          message: msg,
                          files: [XFile(f.path)],
                        );
                        await _afterExportActions();
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final cur = ref.read(appControllerProvider);
                        if (!_ensureKhataOk(cur)) return;
                        final lg = await _logoBytes();
                        await DocumentExporter.printInvoice(
                          s: cur,
                          lines: cur.invoiceLines,
                          invoiceNumber: cur.invoiceDraftNumber,
                          logoBytes: lg,
                        );
                        await _afterExportActions();
                      },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: Text(
                        'Print',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: DukaanColors.g2,
                        foregroundColor: DukaanColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final cur = ref.read(appControllerProvider);
                        if (!_ensureKhataOk(cur)) return;
                        final lg = await _logoBytes();
                        final pdf = await DocumentExporter.buildInvoicePdfBytes(
                          s: cur,
                          lines: cur.invoiceLines,
                          invoiceNumber: cur.invoiceDraftNumber,
                          logoBytes: lg,
                        );
                        final f = await DocumentExporter.writeTempPdf(
                          pdf.toList(),
                          'invoice_$invNo.pdf',
                        );
                        await Share.shareXFiles(
                          [XFile(f.path)],
                          text: DocumentExporter.invoiceSummaryText(
                            cur,
                            cur.invoiceLines,
                            cur.invoiceDraftNumber,
                          ),
                        );
                        await _afterExportActions();
                      },
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: Text(
                        'Share',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ctrl.startNewInvoiceDraft(),
                child: const Text('Start fresh invoice'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _head(String t, {bool center = false, bool right = false}) {
    return Text(
      t.toUpperCase(),
      textAlign: center
          ? TextAlign.center
          : (right ? TextAlign.right : TextAlign.left),
      style: GoogleFonts.dmSans(
        fontSize: 9,
        color: DukaanColors.g4,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _totalRow(BuildContext context, String k, String v) {
    final c = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: c.withValues(alpha: 0.65),
            ),
          ),
          Text(
            v,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.onBack,
    this.onRefresh,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({
    required this.invNo,
    required this.dateStr,
    required this.shopName,
    required this.shopLine,
    required this.lines,
    required this.totalStr,
    required this.footer,
    required this.accent,
    required this.currencyLabel,
  });

  final String invNo;
  final String dateStr;
  final String shopName;
  final String shopLine;
  final List<LineItem> lines;
  final String totalStr;
  final String footer;
  final Color accent;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, color: accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'INV #$invNo',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: DukaanColors.g5,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: DukaanColors.g4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    shopName,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DukaanColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shopLine,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: DukaanColors.g5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Column(
                children: [
                  for (final e in lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${e.name} ×${e.qty}',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: DukaanColors.g5,
                              ),
                            ),
                          ),
                          Text(
                            '$currencyLabel ${e.lineTotal.toStringAsFixed(0)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: DukaanColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: accent.withValues(alpha: 0.12),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: DukaanColors.g5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    totalStr,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DukaanColors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Text(
                footer,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 9, color: DukaanColors.g4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.title,
    required this.icon,
    required this.child,
  });

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
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: DukaanColors.g4),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: DukaanColors.g4,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          child,
        ],
      ),
    );
  }
}

class _InvoiceLineEditor extends StatefulWidget {
  const _InvoiceLineEditor({
    required this.ref,
    required this.index,
    required this.item,
  });

  final WidgetRef ref;
  final int index;
  final LineItem item;

  @override
  State<_InvoiceLineEditor> createState() => _InvoiceLineEditorState();
}

class _InvoiceLineEditorState extends State<_InvoiceLineEditor> {
  late TextEditingController _name;
  late TextEditingController _qty;
  late TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item.name);
    _qty = TextEditingController(text: '${widget.item.qty}');
    _price = TextEditingController(
      text: widget.item.unitPrice == widget.item.unitPrice.roundToDouble()
          ? '${widget.item.unitPrice.toInt()}'
          : '${widget.item.unitPrice}',
    );
  }

  @override
  void didUpdateWidget(covariant _InvoiceLineEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.name != widget.item.name &&
        widget.item.name != _name.text) {
      _name.text = widget.item.name;
    }
    if (oldWidget.item.qty != widget.item.qty) {
      _qty.text = '${widget.item.qty}';
    }
    if (oldWidget.item.unitPrice != widget.item.unitPrice) {
      _price.text =
          widget.item.unitPrice == widget.item.unitPrice.roundToDouble()
          ? '${widget.item.unitPrice.toInt()}'
          : '${widget.item.unitPrice}';
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
    final fill = Theme.of(context).brightness == Brightness.dark
        ? DukaanColors.darkSurfaceVariant
        : DukaanColors.g1;
    InputDecoration deco() => InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: DukaanColors.g3, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: DukaanColors.g3, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: DukaanColors.black),
      ),
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
                onChanged: (v) => ctrl.updateInvoiceLine(widget.index, name: v),
                style: GoogleFonts.dmSans(fontSize: 12),
                decoration: deco(),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qty,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        final q = int.tryParse(v);
                        if (q != null) {
                          ctrl.updateInvoiceLine(widget.index, qty: q);
                        }
                      },
                      style: GoogleFonts.dmSans(fontSize: 12),
                      decoration: deco(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _price,
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (v) => ctrl.updateInvoiceLine(
                        widget.index,
                        unitPrice: double.tryParse(v) ?? 0,
                      ),
                      style: GoogleFonts.dmSans(fontSize: 12),
                      decoration: deco(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ctrl.removeInvoiceLine(widget.index),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _name,
                onChanged: (v) => ctrl.updateInvoiceLine(widget.index, name: v),
                style: GoogleFonts.dmSans(fontSize: 12),
                decoration: deco(),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                controller: _qty,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  final q = int.tryParse(v);
                  if (q != null) {
                    ctrl.updateInvoiceLine(widget.index, qty: q);
                  }
                },
                style: GoogleFonts.dmSans(fontSize: 12),
                decoration: deco(),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _price,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: (v) => ctrl.updateInvoiceLine(
                  widget.index,
                  unitPrice: double.tryParse(v) ?? 0,
                ),
                style: GoogleFonts.dmSans(fontSize: 12),
                decoration: deco(),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => ctrl.removeInvoiceLine(widget.index),
                icon: const Icon(Icons.close, size: 18, color: DukaanColors.g4),
              ),
            ),
          ],
        );
      },
    );
  }
}
