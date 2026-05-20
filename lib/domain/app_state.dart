import 'package:flutter/material.dart';

import '../models/line_item.dart';
import 'app_models.dart';
import 'khata_models.dart';

@immutable
class AppState {
  const AppState({
    required this.mainTabIndex,
    required this.onboardingComplete,
    required this.ownerName,
    required this.shopName,
    required this.shopPhone,
    required this.shopWhatsapp,
    required this.shopCity,
    required this.shopAddress,
    required this.shopEmail,
    required this.footerNote,
    required this.currency,
    required this.localeTag,
    required this.darkMode,
    required this.logoRelativePath,
    required this.invoiceDraftNumber,
    required this.editingInvoiceId,
    required this.customerName,
    required this.customerPhone,
    required this.discount,
    required this.taxPercent,
    required this.selectedInvoiceColorIndex,
    required this.invoiceLines,
    required this.invoiceDraftPaymentType,
    required this.draftKhataCustomerId,
    required this.draftReminderAtMs,
    required this.draftReminderNote,
    required this.receiptDraftNumber,
    required this.receiptLines,
    required this.businessRole,
    required this.cardWhatsapp,
    required this.cardEmail,
    required this.cardStyle,
    required this.cardShareCount,
    required this.invoiceHistory,
    required this.receiptHistory,
    required this.khataCustomers,
    required this.customerPayments,
  });

  final int mainTabIndex;

  final bool onboardingComplete;
  final String ownerName;

  final String shopName;
  final String shopPhone;
  final String shopWhatsapp;
  final String shopCity;
  final String shopAddress;
  final String shopEmail;
  final String footerNote;

  final CurrencyCode currency;
  final String localeTag;
  final bool darkMode;
  final String? logoRelativePath;

  final int invoiceDraftNumber;
  final String? editingInvoiceId;
  final String customerName;
  final String customerPhone;
  final double discount;
  final double taxPercent;
  final int selectedInvoiceColorIndex;
  final List<LineItem> invoiceLines;

  /// `cash` | `online` | `khata`
  final String invoiceDraftPaymentType;
  final String? draftKhataCustomerId;
  final int? draftReminderAtMs;
  final String draftReminderNote;

  final int receiptDraftNumber;
  final List<LineItem> receiptLines;

  final String businessRole;
  final String cardWhatsapp;
  final String cardEmail;
  final CardStyle cardStyle;
  final int cardShareCount;

  final List<StoredInvoice> invoiceHistory;
  final List<StoredReceipt> receiptHistory;

  final List<KhataCustomer> khataCustomers;
  final List<CustomerPayment> customerPayments;

  static List<LineItem> defaultLines() => [];

  factory AppState.initial() {
    return AppState(
      mainTabIndex: 0,
      onboardingComplete: false,
      ownerName: '',
      shopName: '',
      shopPhone: '',
      shopWhatsapp: '',
      shopCity: '',
      shopAddress: '',
      shopEmail: '',
      footerNote: 'Thank you for shopping with us!',
      currency: CurrencyCode.pkr,
      localeTag: 'en',
      darkMode: false,
      logoRelativePath: null,
      invoiceDraftNumber: 1,
      editingInvoiceId: null,
      customerName: '',
      customerPhone: '',
      discount: 0,
      taxPercent: 0,
      selectedInvoiceColorIndex: 0,
      invoiceLines: const [],
      invoiceDraftPaymentType: 'cash',
      draftKhataCustomerId: null,
      draftReminderAtMs: null,
      draftReminderNote: '',
      receiptDraftNumber: 1,
      receiptLines: const [],
      businessRole: 'General Trader',
      cardWhatsapp: '',
      cardEmail: '',
      cardStyle: CardStyle.initial,
      cardShareCount: 0,
      invoiceHistory: const [],
      receiptHistory: const [],
      khataCustomers: const [],
      customerPayments: const [],
    );
  }

  String get shopLineForPreview => '$shopAddress · $shopPhone';

  String get currencySymbol => currency.symbol;

  double subtotal(List<LineItem> lines) =>
      lines.fold<double>(0, (a, b) => a + b.lineTotal);

  double taxAmount(List<LineItem> lines) => subtotal(lines) * taxPercent / 100;

  double grandTotal(List<LineItem> lines) {
    final s = subtotal(lines);
    final tax = s * taxPercent / 100;
    return (s - discount + tax).clamp(0, double.infinity);
  }

  KhataCustomer? khataCustomerById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final c in khataCustomers) {
      if (c.id == id) return c;
    }
    return null;
  }

  double totalKhataInvoicedForCustomer(String customerId) {
    return invoiceHistory
        .where((e) => e.isKhata && e.khataCustomerId == customerId)
        .fold<double>(0, (a, e) => a + e.grandTotal());
  }

  double totalPaymentsForCustomer(String customerId) {
    return customerPayments
        .where((e) => e.customerId == customerId)
        .fold<double>(0, (a, e) => a + e.amount);
  }

  double customerDue(String customerId) {
    return (totalKhataInvoicedForCustomer(customerId) -
            totalPaymentsForCustomer(customerId))
        .clamp(0, double.infinity);
  }

  double get totalKhataOutstanding {
    return khataCustomers.fold<double>(0, (a, c) => a + customerDue(c.id));
  }

  int get khataCustomersWithDue =>
      khataCustomers.where((c) => customerDue(c.id) > 0.009).length;

  DateTime? lastActivityForCustomer(String customerId) {
    DateTime? best;
    for (final inv in invoiceHistory) {
      if (inv.isKhata && inv.khataCustomerId == customerId) {
        if (best == null || inv.updatedAt.isAfter(best)) best = inv.updatedAt;
      }
    }
    for (final p in customerPayments) {
      if (p.customerId == customerId) {
        final t = p.paidAt;
        if (best == null || t.isAfter(best)) best = t;
      }
    }
    final c = khataCustomerById(customerId);
    if (c != null) {
      if (best == null || c.updatedAt.isAfter(best)) best = c.updatedAt;
    }
    return best;
  }

  int? nextReminderMsForCustomer(String customerId) {
    int? best;
    for (final inv in invoiceHistory) {
      if (!inv.isKhata || inv.khataCustomerId != customerId) continue;
      final r = inv.reminderAtMs;
      if (r == null) continue;
      if (best == null || r < best) best = r;
    }
    return best;
  }

  bool customerHasOverdueReminder(String customerId) {
    final r = nextReminderMsForCustomer(customerId);
    if (r == null) return false;
    return DateTime.now().millisecondsSinceEpoch > r &&
        customerDue(customerId) > 0.009;
  }

  static const List<Color> invoiceAccentColors = [
    Color(0xFF0A0A0A),
    Color(0xFF185FA5),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
    Color(0xFF7C3AED),
    Color(0xFFB45309),
    Color(0xFF374151),
  ];

  Color get invoiceAccent =>
      invoiceAccentColors[selectedInvoiceColorIndex.clamp(
        0,
        invoiceAccentColors.length - 1,
      )];

  String get monogram {
    final t = shopName.trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1).toUpperCase();
  }

  int get invoiceCount => invoiceHistory.length;

  double get totalBilledAllTime =>
      invoiceHistory.fold<double>(0, (a, b) => a + b.grandTotal());

  AppState copyWith({
    int? mainTabIndex,
    bool? onboardingComplete,
    String? ownerName,
    String? shopName,
    String? shopPhone,
    String? shopWhatsapp,
    String? shopCity,
    String? shopAddress,
    String? shopEmail,
    String? footerNote,
    CurrencyCode? currency,
    String? localeTag,
    bool? darkMode,
    String? logoRelativePath,
    bool clearLogo = false,
    int? invoiceDraftNumber,
    String? editingInvoiceId,
    bool clearEditingInvoice = false,
    String? customerName,
    String? customerPhone,
    double? discount,
    double? taxPercent,
    int? selectedInvoiceColorIndex,
    List<LineItem>? invoiceLines,
    String? invoiceDraftPaymentType,
    String? draftKhataCustomerId,
    bool clearDraftKhataCustomer = false,
    int? draftReminderAtMs,
    bool clearDraftReminder = false,
    String? draftReminderNote,
    int? receiptDraftNumber,
    List<LineItem>? receiptLines,
    String? businessRole,
    String? cardWhatsapp,
    String? cardEmail,
    CardStyle? cardStyle,
    int? cardShareCount,
    List<StoredInvoice>? invoiceHistory,
    List<StoredReceipt>? receiptHistory,
    List<KhataCustomer>? khataCustomers,
    List<CustomerPayment>? customerPayments,
  }) {
    return AppState(
      mainTabIndex: mainTabIndex ?? this.mainTabIndex,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      ownerName: ownerName ?? this.ownerName,
      shopName: shopName ?? this.shopName,
      shopPhone: shopPhone ?? this.shopPhone,
      shopWhatsapp: shopWhatsapp ?? this.shopWhatsapp,
      shopCity: shopCity ?? this.shopCity,
      shopAddress: shopAddress ?? this.shopAddress,
      shopEmail: shopEmail ?? this.shopEmail,
      footerNote: footerNote ?? this.footerNote,
      currency: currency ?? this.currency,
      localeTag: localeTag ?? this.localeTag,
      darkMode: darkMode ?? this.darkMode,
      logoRelativePath: clearLogo
          ? null
          : (logoRelativePath ?? this.logoRelativePath),
      invoiceDraftNumber: invoiceDraftNumber ?? this.invoiceDraftNumber,
      editingInvoiceId: clearEditingInvoice
          ? null
          : (editingInvoiceId ?? this.editingInvoiceId),
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      discount: discount ?? this.discount,
      taxPercent: taxPercent ?? this.taxPercent,
      selectedInvoiceColorIndex:
          selectedInvoiceColorIndex ?? this.selectedInvoiceColorIndex,
      invoiceLines: invoiceLines ?? this.invoiceLines,
      invoiceDraftPaymentType:
          invoiceDraftPaymentType ?? this.invoiceDraftPaymentType,
      draftKhataCustomerId: clearDraftKhataCustomer
          ? null
          : (draftKhataCustomerId ?? this.draftKhataCustomerId),
      draftReminderAtMs: clearDraftReminder
          ? null
          : (draftReminderAtMs ?? this.draftReminderAtMs),
      draftReminderNote: draftReminderNote ?? this.draftReminderNote,
      receiptDraftNumber: receiptDraftNumber ?? this.receiptDraftNumber,
      receiptLines: receiptLines ?? this.receiptLines,
      businessRole: businessRole ?? this.businessRole,
      cardWhatsapp: cardWhatsapp ?? this.cardWhatsapp,
      cardEmail: cardEmail ?? this.cardEmail,
      cardStyle: cardStyle ?? this.cardStyle,
      cardShareCount: cardShareCount ?? this.cardShareCount,
      invoiceHistory: invoiceHistory ?? this.invoiceHistory,
      receiptHistory: receiptHistory ?? this.receiptHistory,
      khataCustomers: khataCustomers ?? this.khataCustomers,
      customerPayments: customerPayments ?? this.customerPayments,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 3,
    'mainTabIndex': mainTabIndex,
    'onboardingComplete': onboardingComplete,
    'ownerName': ownerName,
    'shopName': shopName,
    'shopPhone': shopPhone,
    'shopWhatsapp': shopWhatsapp,
    'shopCity': shopCity,
    'shopAddress': shopAddress,
    'shopEmail': shopEmail,
    'footerNote': footerNote,
    'currency': currency.label,
    'localeTag': localeTag,
    'darkMode': darkMode,
    'logoRelativePath': logoRelativePath,
    'invoiceDraftNumber': invoiceDraftNumber,
    'editingInvoiceId': editingInvoiceId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'discount': discount,
    'taxPercent': taxPercent,
    'selectedInvoiceColorIndex': selectedInvoiceColorIndex,
    'invoiceLines': invoiceLines.map((e) => e.toMap()).toList(),
    'invoiceDraftPaymentType': invoiceDraftPaymentType,
    'draftKhataCustomerId': draftKhataCustomerId,
    'draftReminderAtMs': draftReminderAtMs,
    'draftReminderNote': draftReminderNote,
    'receiptDraftNumber': receiptDraftNumber,
    'receiptLines': receiptLines.map((e) => e.toMap()).toList(),
    'businessRole': businessRole,
    'cardWhatsapp': cardWhatsapp,
    'cardEmail': cardEmail,
    'cardStyle': cardStyle.toMap(),
    'cardShareCount': cardShareCount,
    'invoiceHistory': invoiceHistory.map((e) => e.toMap()).toList(),
    'receiptHistory': receiptHistory.map((e) => e.toMap()).toList(),
    'khataCustomers': khataCustomers.map((e) => e.toMap()).toList(),
    'customerPayments': customerPayments.map((e) => e.toMap()).toList(),
  };

  factory AppState.fromJson(Map<dynamic, dynamic> m) {
    final base = AppState.initial();
    if (m.isEmpty) return base;

    List<LineItem> linesFrom(Object? o) {
      final list = (o as List?) ?? const [];
      return list
          .map((e) => LineItem.fromMap(Map<dynamic, dynamic>.from(e as Map)))
          .toList();
    }

    final invHist = ((m['invoiceHistory'] as List?) ?? const [])
        .map((e) => StoredInvoice.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    final recHist = ((m['receiptHistory'] as List?) ?? const [])
        .map((e) => StoredReceipt.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    final customers = ((m['khataCustomers'] as List?) ?? const [])
        .map((e) => KhataCustomer.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    final payments = ((m['customerPayments'] as List?) ?? const [])
        .map(
          (e) => CustomerPayment.fromMap(Map<dynamic, dynamic>.from(e as Map)),
        )
        .toList();

    final migratedOnboarding = m.containsKey('onboardingComplete')
        ? m['onboardingComplete'] == true
        : true;
    final draftPt = '${m['invoiceDraftPaymentType'] ?? 'cash'}';
    final safePt = draftPt == 'online' || draftPt == 'khata' ? draftPt : 'cash';
    final remMs = (m['draftReminderAtMs'] is int)
        ? m['draftReminderAtMs'] as int
        : int.tryParse('${m['draftReminderAtMs']}');

    return AppState(
      mainTabIndex: (m['mainTabIndex'] is int)
          ? m['mainTabIndex'] as int
          : base.mainTabIndex,
      onboardingComplete: migratedOnboarding,
      ownerName: '${m['ownerName'] ?? ''}',
      shopName: '${m['shopName'] ?? base.shopName}',
      shopPhone: '${m['shopPhone'] ?? base.shopPhone}',
      shopWhatsapp: '${m['shopWhatsapp'] ?? m['cardWhatsapp'] ?? ''}',
      shopCity: '${m['shopCity'] ?? base.shopCity}',
      shopAddress: '${m['shopAddress'] ?? base.shopAddress}',
      shopEmail: '${m['shopEmail'] ?? ''}',
      footerNote: '${m['footerNote'] ?? base.footerNote}',
      currency: CurrencyCodeX.fromLabel('${m['currency'] ?? 'PKR'}'),
      localeTag: '${m['localeTag'] ?? 'en'}',
      darkMode: m['darkMode'] == true,
      logoRelativePath: m['logoRelativePath'] as String?,
      invoiceDraftNumber: (m['invoiceDraftNumber'] is int)
          ? m['invoiceDraftNumber'] as int
          : base.invoiceDraftNumber,
      editingInvoiceId: m['editingInvoiceId'] as String?,
      customerName: '${m['customerName'] ?? ''}',
      customerPhone: '${m['customerPhone'] ?? ''}',
      discount: (m['discount'] is num)
          ? (m['discount'] as num).toDouble()
          : double.tryParse('${m['discount']}') ?? 0,
      taxPercent: (m['taxPercent'] is num)
          ? (m['taxPercent'] as num).toDouble()
          : double.tryParse('${m['taxPercent']}') ?? 0,
      selectedInvoiceColorIndex: (m['selectedInvoiceColorIndex'] is int)
          ? m['selectedInvoiceColorIndex'] as int
          : 0,
      invoiceLines: linesFrom(m['invoiceLines']).isEmpty
          ? base.invoiceLines
          : linesFrom(m['invoiceLines']),
      invoiceDraftPaymentType: safePt,
      draftKhataCustomerId: m['draftKhataCustomerId'] as String?,
      draftReminderAtMs: remMs,
      draftReminderNote: '${m['draftReminderNote'] ?? ''}',
      receiptDraftNumber: (m['receiptDraftNumber'] is int)
          ? m['receiptDraftNumber'] as int
          : base.receiptDraftNumber,
      receiptLines: linesFrom(m['receiptLines']).isEmpty
          ? base.receiptLines
          : linesFrom(m['receiptLines']),
      businessRole: '${m['businessRole'] ?? base.businessRole}',
      cardWhatsapp: '${m['cardWhatsapp'] ?? base.cardWhatsapp}',
      cardEmail: '${m['cardEmail'] ?? ''}',
      cardStyle: m['cardStyle'] is Map
          ? CardStyle.fromMap(Map<dynamic, dynamic>.from(m['cardStyle'] as Map))
          : CardStyle.initial,
      cardShareCount: (m['cardShareCount'] is int)
          ? m['cardShareCount'] as int
          : 0,
      invoiceHistory: invHist,
      receiptHistory: recHist,
      khataCustomers: customers,
      customerPayments: payments,
    );
  }
}
