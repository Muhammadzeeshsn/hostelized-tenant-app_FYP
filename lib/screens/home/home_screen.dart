// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../models/home.dart';
import '../../services/mock_data_service.dart';
import '../wallet/wallet_screen.dart';
import '../hostel_card/hostel_card_screen.dart';

/// Brand colors matching the design
const _brandBlue = Color(0xFF003A60);
const _cardBlue = Color(0xFF004A70);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  TenantHome? _homeData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await MockDataService.getHomeData();
      setState(() {
        _homeData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      ),
    );
  }

  void _showHostelCardOverlay() {
    // Show hostel card in overlay dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const HostelCardOverlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHomeData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final tenant = _homeData!.tenant;
    final hostel = _homeData!.hostel;
    final balance = _homeData!.balance;
    final notices = _homeData!.notices;

    final firstName = tenant?['firstName'] ?? 'Guest';
    final personalId = tenant?['personalId'] ?? 'N/A';
    final program = tenant?['program'] ?? 'N/A';
    final rollNumber = tenant?['rollNumber'] ?? 'N/A';
    final avatarUrl = tenant?['avatarUrl'] ?? '';
    final hostelName = hostel?['name'] ?? 'Hostel';

    final breakdown = (balance['breakdown'] as List?) ?? [];
    final totalAmount = balance['totalDues'] ?? 0;
    final totalDiscount = balance['totalDiscount'] ?? 0;
    final dueDate = balance['dueDate'] ?? 'N/A';

    // Format due date
    final formattedDueDate = _formatDate(dueDate);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // HMS Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: _brandBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'HMS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      // Hostel Name
                      Expanded(
                        child: Center(
                          child: Text(
                            hostelName,
                            style: const TextStyle(
                              color: _brandBlue,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Notification Bell
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: _brandBlue,
                              size: 28,
                            ),
                            onPressed: () => _showNotifications(notices),
                          ),
                          if (notices.any((n) => n['read'] == false))
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Greeting and Avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hi, $firstName',
                        style: const TextStyle(
                          color: _brandBlue,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: _brandBlue.withOpacity(0.1),
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: _brandBlue,
                                size: 35,
                              )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Personal Info Rows
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Personal ID',
                    value: personalId,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Study Program',
                    value: program,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.format_list_numbered,
                    label: 'Roll Number',
                    value: rollNumber,
                  ),

                  const SizedBox(height: 28),

                  // Dues Card
                  Container(
                    decoration: BoxDecoration(
                      color: _cardBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dues',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Table Header
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Discount',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(color: Colors.white30, height: 24),

                        // Dues Breakdown
                        ...breakdown.map((item) {
                          final name = item['name'] ?? '';
                          final amount = item['amount'] ?? 0;
                          final discount = item['discount'] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Rs $amount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Rs $discount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const Divider(color: Colors.white30, height: 24),

                        // Total
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Rs $totalAmount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Rs $totalDiscount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Due Date and Pay Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due Date',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDueDate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: _navigateToWallet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2CB0A5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hostel Card Button
                  InkWell(
                    onTap: _showHostelCardOverlay,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _brandBlue.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _brandBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: _brandBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Hostel Card',
                              style: TextStyle(
                                color: _brandBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: _brandBlue.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showNotifications(List<dynamic> notices) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: _brandBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: notices.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          itemCount: notices.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final notice = notices[i];
                            return _NoticeTile(
                              notice: notice,
                              onMarkRead: () {
                                Navigator.pop(context);
                                _loadHomeData();
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _brandBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _loadHomeData();
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _brandBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NoticeTile extends StatelessWidget {
  final Map<String, dynamic> notice;
  final VoidCallback onMarkRead;

  const _NoticeTile({required this.notice, required this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    final message = notice['message'] ?? '';
    final priority = notice['priority'] ?? 'normal';
    final isRead = notice['read'] == true;
    final dotColor = priority == 'high' ? Colors.red : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: _brandBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isRead ? Colors.white38 : dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
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

// Hostel Card Overlay Dialog
class HostelCardOverlayDialog extends StatelessWidget {
  const HostelCardOverlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data - replace with actual data
    final cardData = {
      'name': 'Ali',
      'hostelName': 'Comsats University, Islamabad',
      'hostelId': 'PH-123',
      'allottedHostel': 'Punjab Hostel',
      'roomNo': 'A1',
      'contactNo': '1234XXXXXX',
      'course': 'BSSE',
      'rollNo': 'FAXX-XXX-XXXX',
      'dob': '25/XX/XXXX',
      'photoUrl': '',
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.grey[600],
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Hostel Name
                    Text(
                      cardData['hostelName'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Profile Photo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _brandBlue,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: cardData['photoUrl']?.isNotEmpty == true
                            ? Image.network(
                                cardData['photoUrl']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderPhoto();
                                },
                              )
                            : _buildPlaceholderPhoto(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Name
                    Text(
                      cardData['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Card Details
                    _buildDetailRow('Hostel Id', cardData['hostelId'] ?? ''),
                    _buildDetailRow(
                        'Allotted Hostel', cardData['allottedHostel'] ?? ''),
                    _buildDetailRow('Room No.', cardData['roomNo'] ?? ''),
                    _buildDetailRow('Contact No.', cardData['contactNo'] ?? ''),
                    _buildDetailRow('Course', cardData['course'] ?? ''),
                    _buildDetailRow('Roll No.', cardData['rollNo'] ?? ''),
                    _buildDetailRow('D.O.B', cardData['dob'] ?? ''),

                    const SizedBox(height: 24),

                    // Barcode placeholder
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '||||| |||| ||||| ||||',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Print Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preparing card for printing...'),
                              backgroundColor: _brandBlue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Print',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[400]!,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                ': $value',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
