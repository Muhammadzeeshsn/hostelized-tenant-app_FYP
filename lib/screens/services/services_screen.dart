// lib/screens/services/services_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _brandBlue = Color(0xFF003A60);

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String? _selectedService;
  final _detailsController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showAllServices = false;

  @override
  void dispose() {
    _detailsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // All available services
  final List<Map<String, dynamic>> _allServices = [
    {
      'title': 'Electrician',
      'icon': Icons.electrical_services,
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Cleaner',
      'icon': Icons.cleaning_services,
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Carpenter',
      'icon': Icons.handyman,
      'color': const Color(0xFF795548),
    },
    {
      'title': 'Internet',
      'icon': Icons.wifi,
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Plumber',
      'icon': Icons.plumbing,
      'color': const Color(0xFF00BCD4),
    },
    {
      'title': 'AC Repair',
      'icon': Icons.ac_unit,
      'color': const Color(0xFF9C27B0),
    },
    {
      'title': 'Laundry',
      'icon': Icons.local_laundry_service,
      'color': const Color(0xFF03A9F4),
    },
    {
      'title': 'Security',
      'icon': Icons.security,
      'color': const Color(0xFF607D8B),
    },
    {
      'title': 'Housekeeping',
      'icon': Icons.home_work,
      'color': const Color(0xFFE91E63),
    },
    {
      'title': 'Other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF9E9E9E),
    },
  ];

  List<Map<String, dynamic>> get _displayedServices {
    return _showAllServices ? _allServices : _allServices.take(6).toList();
  }

  bool get _hasMoreServices => _allServices.length > 6;

  bool get _canSubmit {
    return _selectedService != null &&
        _detailsController.text.trim().length >= 10;
  }

  void _generateTicket() {
    if (!_canSubmit) {
      String message = '';
      if (_selectedService == null) {
        message = 'Please select a service';
      } else if (_detailsController.text.trim().length < 10) {
        message = 'Details must be at least 10 characters';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Navigate to success screen
    context.push('/service-success', extra: {
      'service': _selectedService,
      'details': _detailsController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Choose the Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _brandBlue,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instruction
                    Text(
                      'Select the service you need',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Service Grid - 3 items per row
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Changed to 3
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _displayedServices.length,
                      itemBuilder: (context, index) {
                        final service = _displayedServices[index];
                        final isSelected = _selectedService == service['title'];

                        return _ServiceCard(
                          service: service,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedService = service['title'];
                            });
                          },
                        );
                      },
                    ),

                    // View More Button
                    if (_hasMoreServices) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAllServices = !_showAllServices;
                            });
                          },
                          icon: Icon(
                            _showAllServices
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: _brandBlue,
                          ),
                          label: Text(
                            _showAllServices
                                ? 'View Less'
                                : 'View More Services',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _brandBlue,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Details Section
                    Text(
                      'Describe Your Issue *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Minimum 10 characters required',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Text Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? _brandBlue
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _detailsController,
                        focusNode: _focusNode,
                        maxLines: 6,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText:
                              'Example: "My room fan is making loud noise and not working properly since yesterday morning."',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          counterText:
                              '${_detailsController.text.length}/500 (min: 10)',
                          counterStyle: TextStyle(
                            color: _detailsController.text.length >= 10
                                ? Colors.green
                                : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _generateTicket : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[500],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _canSubmit ? 2 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_number, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              _canSubmit
                                  ? 'Generate Ticket'
                                  : 'Complete Form to Submit',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _brandBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _brandBlue : Colors.grey[300]!,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _brandBlue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with smaller size for 3-column layout
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : service['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    service['icon'],
                    size: 24,
                    color: isSelected ? Colors.white : service['color'],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    service['title'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: _brandBlue,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUCCESS SCREEN
// =============================================================================

class ServiceSuccessScreen extends StatelessWidget {
  final String service;
  final String details;

  const ServiceSuccessScreen({
    super.key,
    required this.service,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final ticketId =
        'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success Animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green[600],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              const Text(
                'Ticket Created Successfully!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _brandBlue,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Your service request has been submitted',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Ticket Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _DetailRow('Ticket ID', ticketId, true),
                    const Divider(height: 24),
                    _DetailRow('Service', service, false),
                    const Divider(height: 24),
                    _DetailRow('Details', details, false),
                    const Divider(height: 24),
                    _DetailRow('Status', 'Pending', false),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to ticket details
                        context.go('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Ticket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: _brandBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailRow(this.label, this.value, this.isHighlight);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? _brandBlue : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
