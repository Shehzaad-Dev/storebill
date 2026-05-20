class LineItem {
  LineItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  final String name;
  final int qty;
  final double unitPrice;

  double get lineTotal => qty * unitPrice;

  LineItem copyWith({String? name, int? qty, double? unitPrice}) {
    return LineItem(
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
      };

  static LineItem fromMap(Map<dynamic, dynamic> m) {
    return LineItem(
      name: (m['name'] ?? '').toString(),
      qty: (m['qty'] is int) ? m['qty'] as int : int.tryParse('${m['qty']}') ?? 0,
      unitPrice: (m['unitPrice'] is num) ? (m['unitPrice'] as num).toDouble() : double.tryParse('${m['unitPrice']}') ?? 0,
    );
  }
}
