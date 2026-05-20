// Offline-first khata (customer ledger) models.

class KhataCustomer {
  const KhataCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.note,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String name;
  final String phone;
  final String whatsapp;
  final String address;
  final String note;
  final int createdAtMs;
  final int updatedAtMs;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
  DateTime get updatedAt => DateTime.fromMillisecondsSinceEpoch(updatedAtMs);

  KhataCustomer copyWith({
    String? name,
    String? phone,
    String? whatsapp,
    String? address,
    String? note,
    int? updatedAtMs,
  }) {
    return KhataCustomer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      note: note ?? this.note,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'whatsapp': whatsapp,
        'address': address,
        'note': note,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  static KhataCustomer fromMap(Map<dynamic, dynamic> m) {
    return KhataCustomer(
      id: '${m['id']}',
      name: '${m['name'] ?? ''}',
      phone: '${m['phone'] ?? ''}',
      whatsapp: '${m['whatsapp'] ?? ''}',
      address: '${m['address'] ?? ''}',
      note: '${m['note'] ?? ''}',
      createdAtMs: (m['createdAtMs'] is int) ? m['createdAtMs'] as int : int.tryParse('${m['createdAtMs']}') ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtMs: (m['updatedAtMs'] is int) ? m['updatedAtMs'] as int : int.tryParse('${m['updatedAtMs']}') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class CustomerPayment {
  const CustomerPayment({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.method,
    required this.note,
    required this.paidAtMs,
  });

  final String id;
  final String customerId;
  final double amount;
  /// `cash` | `online`
  final String method;
  final String note;
  final int paidAtMs;

  DateTime get paidAt => DateTime.fromMillisecondsSinceEpoch(paidAtMs);

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerId': customerId,
        'amount': amount,
        'method': method,
        'note': note,
        'paidAtMs': paidAtMs,
      };

  static CustomerPayment fromMap(Map<dynamic, dynamic> m) {
    return CustomerPayment(
      id: '${m['id']}',
      customerId: '${m['customerId'] ?? ''}',
      amount: (m['amount'] is num) ? (m['amount'] as num).toDouble() : double.tryParse('${m['amount']}') ?? 0,
      method: '${m['method'] ?? 'cash'}',
      note: '${m['note'] ?? ''}',
      paidAtMs: (m['paidAtMs'] is int) ? m['paidAtMs'] as int : int.tryParse('${m['paidAtMs']}') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
