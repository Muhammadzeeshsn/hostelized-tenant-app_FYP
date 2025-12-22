// lib/screens/hostel_card/hostel_card_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/mock_data_service.dart';

const _brandBlue = Color(0xFF003A60);

class HostelCardScreen extends ConsumerStatefulWidget {
  const HostelCardScreen({super.key});

  @override
  ConsumerState<HostelCardScreen> createState() => _HostelCardScreenState();
}

class _HostelCardScreenState extends ConsumerState<HostelCardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await MockDataService.getProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _profileData?['firstName'] ?? '';
    final hostelId = _profileData?['personalId'] ?? '';
    final hostelName = 'Punjab Hostel'; // From hostel data
    final roomNo = 'A1'; // From room data
    final phone = _profileData?['phone'] ?? '';
    final course = _profileData?['program'] ?? '';
    final rollNo = _profileData?['rollNumber'] ?? '';
    final dob = _profileData?['dateOfBirth'] ?? '';
    final avatarUrl = _profileData?['avatarUrl'] ?? '';
    final institution = 'Comsats University, Islamabad';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Hostel Card',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            // Card Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Institution Name
                  Text(
                    institution,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _brandBlue, width: 4),
                    ),
                    child: ClipOval(
                      child: avatarUrl.isNotEmpty
                          ? Image.network(avatarUrl, fit: BoxFit.cover)
                          : Container(
                              color: _brandBlue.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: _brandBlue,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    firstName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details
                  _DetailRow('Hostel Id', hostelId),
                  _DetailRow('Allotted Hostel', hostelName),
                  _DetailRow('Room No.', roomNo),
                  _DetailRow('Contact No.', phone),
                  _DetailRow('Course', course),
                  _DetailRow('Roll No.', rollNo),
                  _DetailRow('D.O.B', _formatDate(dob)),

                  const SizedBox(height: 24),

                  // Barcode
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/barcode.png', // Placeholder
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            '||||||||||||||||||||',
                            style: TextStyle(
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Print Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Print functionality coming soon'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A7A8C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Print',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Continue to Dashboard
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text(
                'Continue to Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: _brandBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              ': $value',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
