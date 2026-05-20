import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/repositories/app_repository.dart';
import '../domain/app_models.dart';
import '../domain/app_state.dart';
import '../domain/khata_models.dart';
import '../models/line_item.dart';
import '../services/reminder_service.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  throw UnimplementedError('Override appRepositoryProvider after Hive init');
});

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  final _uuid = const Uuid();

  AppRepository get _repo => ref.read(appRepositoryProvider);

  Future<void> _persist() => _repo.save(state);

  @override
  AppState build() {
    return _normalizeNumbers(ref.read(appRepositoryProvider).load());
  }

  AppState _normalizeNumbers(AppState s) {
    final maxInv = s.invoiceHistory
        .map((e) => e.number)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxRec = s.receiptHistory
        .map((e) => e.number)
        .fold<int>(0, (a, b) => a > b ? a : b);
    var out = s;
    if (out.invoiceDraftNumber <= maxInv) {
      out = out.copyWith(invoiceDraftNumber: maxInv + 1);
    }
    if (out.receiptDraftNumber <= maxRec) {
      out = out.copyWith(receiptDraftNumber: maxRec + 1);
    }
    return out;
  }

  Future<void> replaceState(AppState next) async {
    state = _normalizeNumbers(next);
    await _persist();
  }

  Future<void> resetToFresh() async {
    state = AppState.initial();
    await _persist();
  }

  Future<void> completeOnboarding({
    required String shopName,
    required String ownerName,
    required String shopAddress,
    required String shopPhone,
    required String shopWhatsapp,
    required CurrencyCode currency,
    String? logoRelativePath,
  }) async {
    state = state.copyWith(
      onboardingComplete: true,
      shopName: shopName.trim(),
      ownerName: ownerName.trim(),
      shopAddress: shopAddress.trim(),
      shopPhone: shopPhone.trim(),
      shopWhatsapp: shopWhatsapp.trim(),
      cardWhatsapp: shopWhatsapp.trim().isNotEmpty
          ? shopWhatsapp.trim()
          : shopPhone.trim(),
      currency: currency,
      clearLogo: logoRelativePath == null,
      logoRelativePath: logoRelativePath,
    );
    await _persist();
  }

  void setMainTab(int i) {
    state = state.copyWith(mainTabIndex: i);
    _persist();
  }

  void setOwnerName(String v) {
    state = state.copyWith(ownerName: v);
    _persist();
  }

  void setShopName(String v) {
    state = state.copyWith(shopName: v);
    _persist();
  }

  void setShopPhone(String v) {
    state = state.copyWith(shopPhone: v);
    _persist();
  }

  void setShopWhatsapp(String v) {
    state = state.copyWith(shopWhatsapp: v);
    _persist();
  }

  void setShopCity(String v) {
    state = state.copyWith(shopCity: v);
    _persist();
  }

  void setShopAddress(String v) {
    state = state.copyWith(shopAddress: v);
    _persist();
  }

  void setShopEmail(String v) {
    state = state.copyWith(shopEmail: v);
    _persist();
  }

  void setFooterNote(String v) {
    state = state.copyWith(footerNote: v);
    _persist();
  }

  void setCurrency(CurrencyCode c) {
    state = state.copyWith(currency: c);
    _persist();
  }

  void setLocaleTag(String tag) {
    state = state.copyWith(localeTag: tag);
    _persist();
  }

  void setDarkMode(bool v) {
    state = state.copyWith(darkMode: v);
    _persist();
  }

  Future<void> setLogoPath(String? relative) async {
    state = state.copyWith(
      logoRelativePath: relative,
      clearLogo: relative == null,
    );
    await _persist();
  }

  void setCustomerName(String v) {
    state = state.copyWith(customerName: v);
    _persist();
  }

  void setCustomerPhone(String v) {
    state = state.copyWith(customerPhone: v);
    _persist();
  }

  void setDiscount(double v) {
    state = state.copyWith(discount: v);
    _persist();
  }

  void setTaxPercent(double v) {
    state = state.copyWith(taxPercent: v);
    _persist();
  }

  void setInvoiceColorIndex(int i) {
    state = state.copyWith(selectedInvoiceColorIndex: i);
    _persist();
  }

  void setCardStyle(CardStyle style) {
    state = state.copyWith(cardStyle: style);
    _persist();
  }

  void setBusinessRole(String v) {
    state = state.copyWith(businessRole: v);
    _persist();
  }

  void setCardWhatsapp(String v) {
    state = state.copyWith(cardWhatsapp: v);
    _persist();
  }

  void setCardEmail(String v) {
    state = state.copyWith(cardEmail: v);
    _persist();
  }

  void bumpCardShareCount() {
    state = state.copyWith(cardShareCount: state.cardShareCount + 1);
    _persist();
  }

  void setInvoiceDraftPaymentType(String type) {
    final t = type == 'online' || type == 'khata' ? type : 'cash';
    state = state.copyWith(
      invoiceDraftPaymentType: t,
      clearDraftKhataCustomer: t != 'khata',
      clearDraftReminder: t != 'khata',
    );
    _persist();
  }

  void setDraftKhataCustomerId(String? id) {
    final c = state.khataCustomerById(id);
    if (c == null) {
      state = state.copyWith(clearDraftKhataCustomer: true);
      _persist();
      return;
    }
    state = state.copyWith(
      draftKhataCustomerId: id,
      customerName: c.name,
      customerPhone: c.phone,
    );
    _persist();
  }

  void setDraftReminder({int? atMs, String? note}) {
    state = state.copyWith(
      draftReminderAtMs: atMs,
      draftReminderNote: note ?? state.draftReminderNote,
    );
    _persist();
  }

  void clearDraftReminder() {
    state = state.copyWith(clearDraftReminder: true, draftReminderNote: '');
    _persist();
  }

  Future<void> addKhataCustomer(KhataCustomer c) async {
    final list = [...state.khataCustomers, c];
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(khataCustomers: list);
    await _persist();
  }

  Future<void> updateKhataCustomer(KhataCustomer c) async {
    final list = state.khataCustomers.map((e) => e.id == c.id ? c : e).toList();
    state = state.copyWith(khataCustomers: list);
    await _persist();
  }

  Future<void> deleteKhataCustomer(String id) async {
    if (state.customerDue(id) > 0.009) return;
    final hasInv = state.invoiceHistory.any(
      (e) => e.isKhata && e.khataCustomerId == id,
    );
    if (hasInv) return;
    state = state.copyWith(
      khataCustomers: state.khataCustomers.where((e) => e.id != id).toList(),
    );
    await _persist();
  }

  Future<void> receivePayment({
    required String customerId,
    required double amount,
    required String method,
    required String note,
    required DateTime paidAt,
  }) async {
    if (amount <= 0) return;
    final pay = CustomerPayment(
      id: _uuid.v4(),
      customerId: customerId,
      amount: amount,
      method: method == 'online' ? 'online' : 'cash',
      note: note,
      paidAtMs: paidAt.millisecondsSinceEpoch,
    );
    final payments = [...state.customerPayments, pay];
    final dueAfter = state.customerDue(customerId) - amount;

    var invoices = [...state.invoiceHistory];
    if (dueAfter <= 0.009) {
      invoices = invoices.map((e) {
        if (e.isKhata &&
            e.khataCustomerId == customerId &&
            e.status != 'paid') {
          return _copyInvoice(e, status: 'paid');
        }
        return e;
      }).toList();
      for (final e in state.invoiceHistory.where(
        (e) => e.isKhata && e.khataCustomerId == customerId,
      )) {
        await ReminderService.cancelForInvoice(e.id);
      }
    }

    final customers = state.khataCustomers.map((c) {
      if (c.id != customerId) return c;
      return c.copyWith(updatedAtMs: DateTime.now().millisecondsSinceEpoch);
    }).toList();

    state = state.copyWith(
      customerPayments: payments,
      khataCustomers: customers,
      invoiceHistory: invoices,
    );
    await _persist();
  }

  StoredInvoice _copyInvoice(
    StoredInvoice e, {
    String? status,
    int? reminderAtMs,
    String? reminderNote,
  }) {
    return StoredInvoice(
      id: e.id,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      number: e.number,
      status: status ?? e.status,
      customerName: e.customerName,
      customerPhone: e.customerPhone,
      lines: e.lines,
      discount: e.discount,
      taxPercent: e.taxPercent,
      selectedInvoiceColorIndex: e.selectedInvoiceColorIndex,
      footerNote: e.footerNote,
      shopName: e.shopName,
      shopPhone: e.shopPhone,
      shopAddress: e.shopAddress,
      paymentType: e.paymentType,
      khataCustomerId: e.khataCustomerId,
      reminderAtMs: reminderAtMs ?? e.reminderAtMs,
      reminderNote: reminderNote ?? e.reminderNote,
    );
  }

  void updateInvoiceLine(
    int index, {
    String? name,
    int? qty,
    double? unitPrice,
  }) {
    if (index < 0 || index >= state.invoiceLines.length) return;
    final e = state.invoiceLines[index];
    final next = [...state.invoiceLines];
    next[index] = e.copyWith(name: name, qty: qty, unitPrice: unitPrice);
    state = state.copyWith(invoiceLines: next);
    _persist();
  }

  void addInvoiceLine() {
    state = state.copyWith(
      invoiceLines: [
        ...state.invoiceLines,
        LineItem(name: '', qty: 1, unitPrice: 0),
      ],
    );
    _persist();
  }

  void removeInvoiceLine(int index) {
    final next = [...state.invoiceLines]..removeAt(index);
    state = state.copyWith(invoiceLines: next);
    _persist();
  }

  void updateReceiptLine(
    int index, {
    String? name,
    int? qty,
    double? unitPrice,
  }) {
    if (index < 0 || index >= state.receiptLines.length) return;
    final e = state.receiptLines[index];
    final next = [...state.receiptLines];
    next[index] = e.copyWith(name: name, qty: qty, unitPrice: unitPrice);
    state = state.copyWith(receiptLines: next);
    _persist();
  }

  void addReceiptLine() {
    state = state.copyWith(
      receiptLines: [
        ...state.receiptLines,
        LineItem(name: '', qty: 1, unitPrice: 0),
      ],
    );
    _persist();
  }

  void removeReceiptLine(int index) {
    final next = [...state.receiptLines]..removeAt(index);
    state = state.copyWith(receiptLines: next);
    _persist();
  }

  StoredInvoice _snapshotInvoiceDraft({required String status}) {
    final now = DateTime.now();
    final id = state.editingInvoiceId ?? _uuid.v4();
    final existing = state.invoiceHistory.where((e) => e.id == id).firstOrNull;
    final pt = state.invoiceDraftPaymentType;
    final isKhata = pt == 'khata';
    final remMs = isKhata ? state.draftReminderAtMs : null;
    final remNote = isKhata ? state.draftReminderNote : '';
    return StoredInvoice(
      id: id,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      number: state.invoiceDraftNumber,
      status: status,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      lines: [...state.invoiceLines],
      discount: state.discount,
      taxPercent: state.taxPercent,
      selectedInvoiceColorIndex: state.selectedInvoiceColorIndex,
      footerNote: state.footerNote,
      shopName: state.shopName,
      shopPhone: state.shopPhone,
      shopAddress: state.shopAddress,
      paymentType: pt,
      khataCustomerId: isKhata ? state.draftKhataCustomerId : null,
      reminderAtMs: remMs,
      reminderNote: remNote,
    );
  }

  Future<void> _scheduleReminderIfNeeded(StoredInvoice inv) async {
    if (!inv.isKhata || inv.reminderAtMs == null) return;
    final when = DateTime.fromMillisecondsSinceEpoch(inv.reminderAtMs!);
    final cust = state.khataCustomerById(inv.khataCustomerId);
    final name = cust?.name.trim().isNotEmpty == true
        ? cust!.name.trim()
        : inv.customerName.trim();
    final title = 'Payment reminder';
    final body =
        '$name — ${state.currencySymbol} ${inv.grandTotal().toStringAsFixed(0)} due.';
    await ReminderService.scheduleInvoiceReminder(
      invoiceId: inv.id,
      when: when,
      title: title,
      body: body,
    );
  }

  Future<void> upsertInvoiceFromDraft({String status = 'pending'}) async {
    final snap = _snapshotInvoiceDraft(status: status);
    final list = [...state.invoiceHistory];
    final idx = list.indexWhere((e) => e.id == snap.id);
    if (idx >= 0) {
      list[idx] = snap;
    } else {
      list.add(snap);
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final nextDraft = state.invoiceDraftNumber + 1;
    state = state.copyWith(
      invoiceHistory: list,
      invoiceDraftNumber: nextDraft,
      editingInvoiceId: null,
      clearEditingInvoice: true,
      customerName: '',
      customerPhone: '',
      discount: 0,
      taxPercent: 0,
      invoiceLines: const [],
      invoiceDraftPaymentType: 'cash',
      clearDraftKhataCustomer: true,
      clearDraftReminder: true,
      draftReminderNote: '',
    );
    await _persist();
    await _scheduleReminderIfNeeded(snap);
  }

  Future<void> loadInvoiceIntoDraft(StoredInvoice inv) async {
    state = state.copyWith(
      editingInvoiceId: inv.id,
      invoiceDraftNumber: inv.number,
      customerName: inv.customerName,
      customerPhone: inv.customerPhone,
      discount: inv.discount,
      taxPercent: inv.taxPercent,
      selectedInvoiceColorIndex: inv.selectedInvoiceColorIndex,
      invoiceLines: inv.lines.map((e) => e.copyWith()).toList(),
      invoiceDraftPaymentType: inv.paymentType,
      draftKhataCustomerId: inv.khataCustomerId,
      clearDraftReminder: true,
      draftReminderNote: '',
    );
    await _persist();
  }

  Future<void> startNewInvoiceDraft() async {
    final maxInv = state.invoiceHistory
        .map((e) => e.number)
        .fold<int>(0, (a, b) => a > b ? a : b);
    state = state.copyWith(
      clearEditingInvoice: true,
      invoiceDraftNumber: maxInv + 1,
      customerName: '',
      customerPhone: '',
      discount: 0,
      taxPercent: 0,
      invoiceLines: const [],
      invoiceDraftPaymentType: 'cash',
      clearDraftKhataCustomer: true,
      clearDraftReminder: true,
      draftReminderNote: '',
    );
    await _persist();
  }

  Future<void> deleteInvoice(String id) async {
    await ReminderService.cancelForInvoice(id);
    state = state.copyWith(
      invoiceHistory: state.invoiceHistory.where((e) => e.id != id).toList(),
    );
    await _persist();
  }

  /// Persists the current draft as a history row after export/share or khata save.
  Future<void> recordInvoiceExport({String? forceStatus}) async {
    final pt = state.invoiceDraftPaymentType;
    final isKhata = pt == 'khata';
    if (isKhata &&
        (state.draftKhataCustomerId == null ||
            state.draftKhataCustomerId!.isEmpty)) {
      return;
    }
    final status = forceStatus ?? (isKhata ? 'pending' : 'paid');
    final id = state.editingInvoiceId ?? _uuid.v4();
    final now = DateTime.now();
    final existing = state.invoiceHistory.where((e) => e.id == id).firstOrNull;
    final snap = StoredInvoice(
      id: id,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      number: state.invoiceDraftNumber,
      status: status,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      lines: [...state.invoiceLines],
      discount: state.discount,
      taxPercent: state.taxPercent,
      selectedInvoiceColorIndex: state.selectedInvoiceColorIndex,
      footerNote: state.footerNote,
      shopName: state.shopName,
      shopPhone: state.shopPhone,
      shopAddress: state.shopAddress,
      paymentType: pt,
      khataCustomerId: isKhata ? state.draftKhataCustomerId : null,
      reminderAtMs: isKhata ? state.draftReminderAtMs : null,
      reminderNote: isKhata ? state.draftReminderNote : '',
    );
    final list = [...state.invoiceHistory];
    final idx = list.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      list[idx] = snap;
    } else {
      list.insert(0, snap);
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    var next = state.copyWith(invoiceHistory: list);
    if (state.editingInvoiceId == null) {
      next = next.copyWith(invoiceDraftNumber: state.invoiceDraftNumber + 1);
    }
    next = next.copyWith(
      editingInvoiceId: null,
      clearEditingInvoice: true,
      customerName: '',
      customerPhone: '',
      discount: 0,
      taxPercent: 0,
      invoiceLines: const [],
      invoiceDraftPaymentType: 'cash',
      clearDraftKhataCustomer: true,
      clearDraftReminder: true,
      draftReminderNote: '',
    );
    state = next;
    await _persist();
    await _scheduleReminderIfNeeded(snap);
  }

  /// Save khata invoice to ledger without sharing PDF.
  Future<bool> saveKhataInvoiceToLedger() async {
    if (state.invoiceDraftPaymentType != 'khata') {
      return false;
    }
    if (state.draftKhataCustomerId == null ||
        state.draftKhataCustomerId!.isEmpty) {
      return false;
    }
    await recordInvoiceExport();
    return true;
  }

  Future<void> recordReceiptExport() async {
    await saveReceiptSnapshot();
  }

  StoredReceipt _snapshotReceiptDraft() {
    final now = DateTime.now();
    return StoredReceipt(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      number: state.receiptDraftNumber,
      lines: [...state.receiptLines],
      shopName: state.shopName,
      shopPhone: state.shopPhone,
      shopAddress: state.shopAddress,
    );
  }

  Future<void> saveReceiptSnapshot() async {
    final snap = _snapshotReceiptDraft();
    final list = [snap, ...state.receiptHistory];
    state = state.copyWith(
      receiptHistory: list,
      receiptDraftNumber: state.receiptDraftNumber + 1,
      receiptLines: const [],
    );
    await _persist();
  }

  Future<void> deleteReceipt(String id) async {
    state = state.copyWith(
      receiptHistory: state.receiptHistory.where((e) => e.id != id).toList(),
    );
    await _persist();
  }

  Future<File> exportCustomersCsvFile() async {
    final dir = await getTemporaryDirectory();
    final f = File(
      '${dir.path}/khata_customers_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    final buf = StringBuffer();
    buf.writeln('name,phone,whatsapp,address,note,due,updatedAt');
    final s = state;
    for (final c in s.khataCustomers) {
      final due = s.customerDue(c.id).toStringAsFixed(0);
      buf.writeln(
        '"${_esc(c.name)}","${_esc(c.phone)}","${_esc(c.whatsapp)}","${_esc(c.address)}","${_esc(c.note)}",$due,${c.updatedAt.toIso8601String()}',
      );
    }
    await f.writeAsString(buf.toString());
    return f;
  }

  Future<File> exportInvoicesCsvFile() async {
    final dir = await getTemporaryDirectory();
    final f = File(
      '${dir.path}/invoices_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    final buf = StringBuffer();
    buf.writeln(
      'number,date,customer,phone,total,status,paymentType,khataCustomerId',
    );
    final s = state;
    for (final inv in s.invoiceHistory) {
      buf.writeln(
        '${inv.number},${inv.updatedAt.toIso8601String()},"${_esc(inv.customerName)}","${_esc(inv.customerPhone)}",${inv.grandTotal().toStringAsFixed(0)},${inv.status},${inv.paymentType},${inv.khataCustomerId ?? ''}',
      );
    }
    await f.writeAsString(buf.toString());
    return f;
  }

  String _esc(String v) => v.replaceAll('"', '""');
}

extension FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
