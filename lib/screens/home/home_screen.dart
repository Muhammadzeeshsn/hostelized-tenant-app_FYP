import 'package:flutter/material.dart';

/// Brand colors
const _brandBlue = Color(0xFF003A60); // #003A60
const _cardBlue = Color(0xFF0A3A5A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---------- Mock data (replace with API later) ----------
  final _hostelName = 'Punjab Hostel';

  final _user = const {
    'firstName': 'Ali',
    'personalId': 'A-879-12',
    'program': 'B.Tech',
    'roll': 'FAXX-XXX-XXX',
    // leave empty to show placeholder avatar
    'avatar': '',
  };

  final List<Map<String, num>> _dues = const [
    {'amount': 4000, 'discount': 0}, // Mess Fee
    {'amount': 3000, 'discount': 0}, // Hostel Fee
    {'amount': 7000, 'discount': 0}, // Laundry Fee
    {'amount': 5000, 'discount': 1000}, // Service Charge
  ];

  final List<_Notice> _notices = [
    _Notice(
      dotColor: Colors.red,
      text:
          'Last Date to pay Hostel Fees is 20/9/2023 for the month of September.',
    ),
    _Notice(
      text:
          'Your service request was completed yesterday. Head to the ticket section to provide your feedback!',
    ),
    _Notice(
      text: 'Your mess has been turned off from 29/08/2023 to 5/09/2023.',
    ),
    _Notice(
      text:
          'Your Service request for house keeping on 30/08/2023 could not be completed. Kindly reschedule.',
    ),
  ];
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final total = _dues.fold<num>(0, (t, e) => t + (e['amount'] ?? 0));
    final discount = _dues.fold<num>(0, (t, e) => t + (e['discount'] ?? 0));
    final payable = total - discount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: _HmsBubble(),
        ),
        title: Text(
          _hostelName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: _brandBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: _brandBlue,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _HeaderRow(
              name: _user['firstName'] as String,
              avatarUrl: _user['avatar'] as String?,
              onAvatarTap: () {}, // later: go to profile
            ),
            const SizedBox(height: 16),

            _MetaRow(
              icon: Icons.account_balance_rounded,
              label: 'Personal ID',
              value: _user['personalId'] as String,
            ),
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.school_rounded,
              label: 'Study Program',
              value: _user['program'] as String,
            ),
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.featured_play_list_rounded,
              label: 'Roll Number',
              value: _user['roll'] as String,
            ),

            const SizedBox(height: 20),

            _DuesCard(
              total: total,
              discount: discount,
              payable: payable,
              onPayNow: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pay Now tapped (placeholder)')),
                );
              },
            ),

            const SizedBox(height: 20),

            _HostelCardButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hostel Card tapped')),
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Notifications dialog
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: _brandBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: _notices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final n = _notices[i];
                      return _NoticeTile(
                        notice: n,
                        onMarkRead: () {
                          setState(() => n.read = true);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _brandBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        for (final n in _notices) n.read = true;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Clear Notifications',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// HMS round bubble logo
class _HmsBubble extends StatelessWidget {
  const _HmsBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _brandBlue,
        shape: BoxShape.circle,
      ),
      child: const Text(
        'HMS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

/// Greeting + avatar
class _HeaderRow extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const _HeaderRow({required this.name, this.avatarUrl, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Hi, $name',
            style: text.headlineSmall?.copyWith(
              color: _brandBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: _brandBlue.withOpacity(.15),
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: _brandBlue, size: 28)
                : null,
          ),
        ),
      ],
    );
  }
}

/// Meta info row (icon + label + value)
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final grey = Colors.black.withOpacity(.65);
    return Row(
      children: [
        Icon(icon, color: _brandBlue, size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: grey, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Dues card (dark blue block)
class _DuesCard extends StatelessWidget {
  final num total;
  final num discount;
  final num payable;
  final VoidCallback onPayNow;

  const _DuesCard({
    required this.total,
    required this.discount,
    required this.payable,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget row(String label, String l, String r, {bool bold = false}) {
      final style = text.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(flex: 6, child: Text(label, style: style)),
            Expanded(flex: 4, child: Text(l, style: style)),
            Expanded(flex: 4, child: Text(r, style: style)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dues',
            style: text.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  '',
                  style: text.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Amount',
                  style: text.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Discount',
                  style: text.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 18),
          row('Mess Fee', 'Rs 4000', 'Rs 0'),
          row('Hostel Fee', 'Rs 3000', 'Rs 0'),
          row('Laundry Fee', 'Rs 7000', 'Rs 0'),
          row('Service Charge', 'Rs 5000', 'Rs 1000'),
          const Divider(color: Colors.white30, height: 18),
          row(
            'Total Amount',
            'Rs ${total.toStringAsFixed(0)}',
            'Rs ${discount.toStringAsFixed(0)}',
            bold: true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Due Date',
                style: text.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Text(
                '31/12/2022',
                style: text.bodySmall?.copyWith(color: Colors.white),
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2CB0A5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onPayNow,
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hostel card CTA
class _HostelCardButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HostelCardButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _brandBlue.withOpacity(.25), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _brandBlue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.badge_outlined, color: _brandBlue),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hostel Card',
                  style: TextStyle(
                    color: _brandBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _brandBlue.withOpacity(.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notification model
class _Notice {
  final String text;
  final Color dotColor;
  bool read;

  _Notice({
    required this.text,
    this.dotColor = Colors.white,
    this.read = false,
  });
}

/// Notification tile inside dialog
class _NoticeTile extends StatelessWidget {
  final _Notice notice;
  final VoidCallback onMarkRead;

  const _NoticeTile({required this.notice, required this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _brandBlue.withOpacity(.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dot
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: notice.read ? Colors.white38 : notice.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notice.text,
              style: const TextStyle(color: Colors.white, height: 1.25),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: onMarkRead,
            child: const Text('Mark read'),
          ),
        ],
      ),
    );
  }
}
