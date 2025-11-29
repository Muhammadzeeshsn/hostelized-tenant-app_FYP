// lib/models/invoice.dart

class Invoice {
  final String id, period, status;
  final num amount;
  final String issuedAt;
  final String? dueAt;
  final String? paidAt;

  Invoice({
    required this.id,
    required this.period,
    required this.amount,
    required this.status,
    required this.issuedAt,
    this.dueAt,
    this.paidAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
    id: j['id'],
    period: j['period'],
    amount: j['amount'],
    status: j['status'],
    issuedAt: j['issuedAt'],
    dueAt: j['dueAt'],
    paidAt: j['paidAt'],
  );
}

class Paged<T> {
  final List<T> items;
  final int total, page, pageSize;
  Paged({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
