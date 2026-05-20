import 'package:flutter/material.dart';

import '../models/line_item.dart';

enum CurrencyCode { pkr, usd, aed, sar, inr }

extension CurrencyCodeX on CurrencyCode {
  String get symbol => switch (this) {
        CurrencyCode.pkr => 'Rs',
        CurrencyCode.usd => r'$',
        CurrencyCode.aed => 'AED',
        CurrencyCode.sar => 'SAR',
        CurrencyCode.inr => '₹',
      };

  String get label => switch (this) {
        CurrencyCode.pkr => 'PKR',
        CurrencyCode.usd => 'USD',
        CurrencyCode.aed => 'AED',
        CurrencyCode.sar => 'SAR',
        CurrencyCode.inr => 'INR',
      };

  static CurrencyCode fromLabel(String v) {
    return CurrencyCode.values.firstWhere(
      (e) => e.label == v,
      orElse: () => CurrencyCode.pkr,
    );
  }
}

enum CardBackgroundMode { templateSolid, customSolid, linearGradient }

class CardStyle {
  const CardStyle({
    required this.mode,
    required this.templateIndex,
    required this.customColor,
    required this.gradientA,
    required this.gradientB,
    required this.gradientBegin,
    required this.gradientEnd,
  });

  final CardBackgroundMode mode;
  final int templateIndex;
  final Color customColor;
  final Color gradientA;
  final Color gradientB;
  final Alignment gradientBegin;
  final Alignment gradientEnd;

  static const List<Color> templateColors = [
    Color(0xFF0A0A0A),
    Color(0xFF1E3A5F),
    Color(0xFF14532D),
    Color(0xFF3B0764),
    Color(0xFF374151),
    Color(0xFF7F1D1D),
  ];

  static const List<String> templateNames = [
    'Midnight black',
    'Navy executive',
    'Forest prestige',
    'Royal purple',
    'Slate grey',
    'Crimson',
  ];

  Decoration buildDecoration() {
    switch (mode) {
      case CardBackgroundMode.templateSolid:
        final i = templateIndex.clamp(0, templateColors.length - 1);
        return BoxDecoration(color: templateColors[i], borderRadius: BorderRadius.circular(14));
      case CardBackgroundMode.customSolid:
        return BoxDecoration(color: customColor, borderRadius: BorderRadius.circular(14));
      case CardBackgroundMode.linearGradient:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(begin: gradientBegin, end: gradientEnd, colors: [gradientA, gradientB]),
        );
    }
  }

  Map<String, dynamic> toMap() => {
        'mode': mode.name,
        'templateIndex': templateIndex,
        'customColor': customColor.toARGB32(),
        'gradientA': gradientA.toARGB32(),
        'gradientB': gradientB.toARGB32(),
        'gbx': gradientBegin.x,
        'gby': gradientBegin.y,
        'gex': gradientEnd.x,
        'gey': gradientEnd.y,
      };

  static CardStyle fromMap(Map<dynamic, dynamic> m) {
    final mode = CardBackgroundMode.values.firstWhere(
      (e) => e.name == (m['mode'] ?? 'templateSolid'),
      orElse: () => CardBackgroundMode.templateSolid,
    );
    return CardStyle(
      mode: mode,
      templateIndex: (m['templateIndex'] is int) ? m['templateIndex'] as int : int.tryParse('${m['templateIndex']}') ?? 0,
      customColor: _c(m['customColor'], const Color(0xFF0A0A0A)),
      gradientA: _c(m['gradientA'], const Color(0xFF0A0A0A)),
      gradientB: _c(m['gradientB'], const Color(0xFF374151)),
      gradientBegin: Alignment(
        (m['gbx'] is num) ? (m['gbx'] as num).toDouble() : -1,
        (m['gby'] is num) ? (m['gby'] as num).toDouble() : -1,
      ),
      gradientEnd: Alignment(
        (m['gex'] is num) ? (m['gex'] as num).toDouble() : 1,
        (m['gey'] is num) ? (m['gey'] as num).toDouble() : 1,
      ),
    );
  }

  static Color _c(Object? v, Color d) {
    if (v is int) return Color(v);
    return d;
  }

  static const CardStyle initial = CardStyle(
    mode: CardBackgroundMode.templateSolid,
    templateIndex: 0,
    customColor: Color(0xFF0A0A0A),
    gradientA: Color(0xFF0A0A0A),
    gradientB: Color(0xFF374151),
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
  );

  CardStyle copyWith({
    CardBackgroundMode? mode,
    int? templateIndex,
    Color? customColor,
    Color? gradientA,
    Color? gradientB,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
  }) {
    return CardStyle(
      mode: mode ?? this.mode,
      templateIndex: templateIndex ?? this.templateIndex,
      customColor: customColor ?? this.customColor,
      gradientA: gradientA ?? this.gradientA,
      gradientB: gradientB ?? this.gradientB,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }
}

class StoredInvoice {
  StoredInvoice({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.number,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.lines,
    required this.discount,
    required this.taxPercent,
    required this.selectedInvoiceColorIndex,
    required this.footerNote,
    required this.shopName,
    required this.shopPhone,
    required this.shopAddress,
    this.paymentType = 'cash',
    this.khataCustomerId,
    this.reminderAtMs,
    this.reminderNote = '',
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int number;
  final String status; // paid | pending
  final String customerName;
  final String customerPhone;
  final List<LineItem> lines;
  final double discount;
  final double taxPercent;
  final int selectedInvoiceColorIndex;
  final String footerNote;
  final String shopName;
  final String shopPhone;
  final String shopAddress;

  /// `cash` | `online` | `khata`
  final String paymentType;
  final String? khataCustomerId;
  final int? reminderAtMs;
  final String reminderNote;

  bool get isKhata => paymentType == 'khata';

  DateTime? get reminderAt => reminderAtMs != null ? DateTime.fromMillisecondsSinceEpoch(reminderAtMs!) : null;

  double subtotal() => lines.fold<double>(0, (a, b) => a + b.lineTotal);

  double taxAmount() => subtotal() * taxPercent / 100;

  double grandTotal() => (subtotal() - discount + taxAmount()).clamp(0, double.infinity);

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'number': number,
        'status': status,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'lines': lines.map((e) => e.toMap()).toList(),
        'discount': discount,
        'taxPercent': taxPercent,
        'selectedInvoiceColorIndex': selectedInvoiceColorIndex,
        'footerNote': footerNote,
        'shopName': shopName,
        'shopPhone': shopPhone,
        'shopAddress': shopAddress,
        'paymentType': paymentType,
        'khataCustomerId': khataCustomerId,
        'reminderAtMs': reminderAtMs,
        'reminderNote': reminderNote,
      };

  static StoredInvoice fromMap(Map<dynamic, dynamic> m) {
    final linesRaw = (m['lines'] as List?) ?? const [];
    final pt = '${m['paymentType'] ?? 'cash'}';
    return StoredInvoice(
      id: '${m['id']}',
      createdAt: DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((m['updatedAt'] as int?) ?? 0),
      number: (m['number'] is int) ? m['number'] as int : int.tryParse('${m['number']}') ?? 1,
      status: '${m['status'] ?? 'pending'}',
      customerName: '${m['customerName'] ?? ''}',
      customerPhone: '${m['customerPhone'] ?? ''}',
      lines: linesRaw.map((e) => LineItem.fromMap(Map<dynamic, dynamic>.from(e as Map))).toList(),
      discount: (m['discount'] is num) ? (m['discount'] as num).toDouble() : double.tryParse('${m['discount']}') ?? 0,
      taxPercent: (m['taxPercent'] is num) ? (m['taxPercent'] as num).toDouble() : double.tryParse('${m['taxPercent']}') ?? 0,
      selectedInvoiceColorIndex: (m['selectedInvoiceColorIndex'] is int) ? m['selectedInvoiceColorIndex'] as int : 0,
      footerNote: '${m['footerNote'] ?? ''}',
      shopName: '${m['shopName'] ?? ''}',
      shopPhone: '${m['shopPhone'] ?? ''}',
      shopAddress: '${m['shopAddress'] ?? ''}',
      paymentType: pt == 'online' || pt == 'khata' ? pt : 'cash',
      khataCustomerId: m['khataCustomerId'] as String?,
      reminderAtMs: (m['reminderAtMs'] is int) ? m['reminderAtMs'] as int : int.tryParse('${m['reminderAtMs']}'),
      reminderNote: '${m['reminderNote'] ?? ''}',
    );
  }
}

class StoredReceipt {
  StoredReceipt({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.number,
    required this.lines,
    required this.shopName,
    required this.shopPhone,
    required this.shopAddress,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int number;
  final List<LineItem> lines;
  final String shopName;
  final String shopPhone;
  final String shopAddress;

  double total() => lines.fold<double>(0, (a, b) => a + b.lineTotal);

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'number': number,
        'lines': lines.map((e) => e.toMap()).toList(),
        'shopName': shopName,
        'shopPhone': shopPhone,
        'shopAddress': shopAddress,
      };

  static StoredReceipt fromMap(Map<dynamic, dynamic> m) {
    final linesRaw = (m['lines'] as List?) ?? const [];
    return StoredReceipt(
      id: '${m['id']}',
      createdAt: DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((m['updatedAt'] as int?) ?? 0),
      number: (m['number'] is int) ? m['number'] as int : int.tryParse('${m['number']}') ?? 1,
      lines: linesRaw.map((e) => LineItem.fromMap(Map<dynamic, dynamic>.from(e as Map))).toList(),
      shopName: '${m['shopName'] ?? ''}',
      shopPhone: '${m['shopPhone'] ?? ''}',
      shopAddress: '${m['shopAddress'] ?? ''}',
    );
  }
}
