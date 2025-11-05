class TenantHome {
  final Map<String, dynamic>? tenant;
  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hostel;
  final Map<String, dynamic> balance;
  final List<dynamic> notices;

  TenantHome({
    this.tenant,
    this.room,
    this.hostel,
    required this.balance,
    required this.notices,
  });

  factory TenantHome.fromJson(Map<String, dynamic> j) => TenantHome(
    tenant: j['tenant'],
    room: j['room'],
    hostel: j['hostel'],
    balance: Map<String, dynamic>.from(j['balance']),
    notices: (j['notices'] as List?) ?? [],
  );
}
