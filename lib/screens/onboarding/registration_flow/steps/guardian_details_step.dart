// lib/screens/onboarding/registration_flow/steps/guardian_details_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

class GuardianDetailsStep extends ConsumerStatefulWidget {
  const GuardianDetailsStep({Key? key}) : super(key: key);

  @override
  ConsumerState<GuardianDetailsStep> createState() =>
      _GuardianDetailsStepState();
}

class _GuardianDetailsStepState extends ConsumerState<GuardianDetailsStep> {
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final model = ref.read(registrationProvider);
    _guardianNameController.text = model.guardianName;
    _guardianPhoneController.text = model.guardianPhone;
  }

  @override
  void dispose() {
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(registrationProvider);
    final relationOptions = [
      'Father',
      'Mother',
      'Brother',
      'Sister',
      'Uncle',
      'Aunt',
      'Spouse',
      'Guardian',
      'Other',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Parent/Guardian Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Emergency contact information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Icon illustration
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.family_restroom,
                size: 50,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Guardian Name
          _buildTextField(
            controller: _guardianNameController,
            label: 'Guardian Name',
            hint: 'Full name of parent/guardian',
            icon: Icons.person_outline,
            required: true,
            onChanged: (value) {
              RegistrationController.updateGuardianDetails(
                ref,
                guardianName: value,
              );
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Guardian name is required';
              }
              if (value.trim().length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Guardian Phone
          _buildTextField(
            controller: _guardianPhoneController,
            label: 'Guardian Contact Number',
            hint: '+92 300 1234567',
            icon: Icons.phone_outlined,
            required: true,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              RegistrationController.updateGuardianDetails(
                ref,
                guardianPhone: value,
              );
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Guardian contact is required';
              }
              final phoneRegex = RegExp(r'^[0-9+\-\s()]{10,15}$');
              if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Relationship Dropdown
          _buildDropdownField(
            label: 'Relationship',
            value: model.guardianRelation.isNotEmpty
                ? model.guardianRelation
                : null,
            items: relationOptions,
            icon: Icons.people_outline,
            required: true,
            onChanged: (value) {
              RegistrationController.updateGuardianDetails(
                ref,
                guardianRelation: value,
              );
            },
          ),
          const SizedBox(height: 32),

          // Info note
          _buildInfoNote(
            'This contact will be notified in case of emergencies. Please ensure the information is accurate and up-to-date.',
          ),
          const SizedBox(height: 24),

          // Additional info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1976D2).withOpacity(0.1),
                  const Color(0xFF1976D2).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: Color(0xFF1976D2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Privacy & Security',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your guardian\'s information is kept confidential and used only for emergency purposes.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF44336)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    bool required = false,
    required Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint:
              Text('Select $label', style: TextStyle(color: Colors.grey[600])),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF757575)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
