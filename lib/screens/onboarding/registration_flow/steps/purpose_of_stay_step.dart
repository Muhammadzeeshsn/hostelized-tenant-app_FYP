// lib/screens/onboarding/registration_flow/steps/purpose_of_stay_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

class PurposeOfStayStep extends ConsumerStatefulWidget {
  const PurposeOfStayStep({Key? key}) : super(key: key);

  @override
  ConsumerState<PurposeOfStayStep> createState() => _PurposeOfStayStepState();
}

class _PurposeOfStayStepState extends ConsumerState<PurposeOfStayStep> {
  final _institutionController = TextEditingController();
  final _courseDegreeController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _jobDetailsController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _designationController = TextEditingController();
  final _otherPurposeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final model = ref.read(registrationProvider);
    _institutionController.text = model.institutionName;
    _courseDegreeController.text = model.courseDegree;
    _regNumberController.text = model.registrationNumber;
    _jobDetailsController.text = model.jobBusinessDetails;
    _businessAddressController.text = model.businessStreetAddress;
    _designationController.text = model.designation;
    _otherPurposeController.text = model.otherPurposeDetails;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _courseDegreeController.dispose();
    _regNumberController.dispose();
    _jobDetailsController.dispose();
    _businessAddressController.dispose();
    _designationController.dispose();
    _otherPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(registrationProvider);
    final purposeOptions = ['Student', 'Business', 'Job', 'Tourist', 'Other'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Purpose of Stay',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your accommodation needs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Purpose Selection
          _buildDropdownField(
            label: 'Select Purpose',
            value: model.purposeOfStay.isNotEmpty ? model.purposeOfStay : null,
            items: purposeOptions,
            icon: Icons.business_center_outlined,
            required: true,
            onChanged: (value) {
              RegistrationController.updatePurposeOfStay(
                ref,
                purposeOfStay: value,
              );
            },
          ),
          const SizedBox(height: 32),

          // Conditional Fields based on purpose
          if (model.purposeOfStay.toLowerCase() == 'student')
            _buildStudentFields(),
          if (model.purposeOfStay.toLowerCase() == 'business' ||
              model.purposeOfStay.toLowerCase() == 'job')
            _buildBusinessJobFields(),
          if (model.purposeOfStay.toLowerCase() == 'other')
            _buildOtherPurposeField(),
          if (model.purposeOfStay.toLowerCase() == 'tourist')
            _buildTouristInfo(),
        ],
      ),
    );
  }

  Widget _buildStudentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Student Information', Icons.school),
        const SizedBox(height: 16),

        // Institution Name
        _buildTextField(
          controller: _institutionController,
          label: 'Institution Name',
          hint: 'University of Engineering and Technology',
          icon: Icons.account_balance,
          required: true,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              institutionName: value,
            );
          },
        ),
        const SizedBox(height: 16),

        // Course/Degree
        _buildTextField(
          controller: _courseDegreeController,
          label: 'Course/Degree',
          hint: 'Bachelor of Computer Science',
          icon: Icons.menu_book,
          required: true,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              courseDegree: value,
            );
          },
        ),
        const SizedBox(height: 16),

        // Registration Number (Optional)
        _buildTextField(
          controller: _regNumberController,
          label: 'Registration Number',
          hint: 'CS-2020-001 (Optional)',
          icon: Icons.badge_outlined,
          required: false,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              registrationNumber: value,
            );
          },
        ),
        const SizedBox(height: 24),

        _buildInfoNote(
          'Student verification may be required. Keep your student ID handy.',
        ),
      ],
    );
  }

  Widget _buildBusinessJobFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Employment Information', Icons.work),
        const SizedBox(height: 16),

        // Job/Business Details
        _buildTextField(
          controller: _jobDetailsController,
          label: 'Job/Business Details',
          hint: 'Software Engineer at Tech Corp',
          icon: Icons.work_outline,
          required: true,
          maxLines: 2,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              jobBusinessDetails: value,
            );
          },
        ),
        const SizedBox(height: 16),

        // Business Street Address
        _buildTextField(
          controller: _businessAddressController,
          label: 'Office/Business Address',
          hint: 'Street, Area, City',
          icon: Icons.location_on_outlined,
          required: true,
          maxLines: 2,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              businessStreetAddress: value,
            );
          },
        ),
        const SizedBox(height: 16),

        // Designation
        _buildTextField(
          controller: _designationController,
          label: 'Designation',
          hint: 'Senior Software Engineer',
          icon: Icons.badge_outlined,
          required: true,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              designation: value,
            );
          },
        ),
        const SizedBox(height: 24),

        _buildInfoNote(
          'Employment verification may be requested for long-term stays.',
        ),
      ],
    );
  }

  Widget _buildOtherPurposeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Additional Details', Icons.info_outline),
        const SizedBox(height: 16),

        // Other Purpose Details
        _buildTextField(
          controller: _otherPurposeController,
          label: 'Please specify your purpose',
          hint: 'Describe your reason for stay',
          icon: Icons.description_outlined,
          required: true,
          maxLines: 4,
          onChanged: (value) {
            RegistrationController.updatePurposeOfStay(
              ref,
              otherPurposeDetails: value,
            );
          },
        ),
        const SizedBox(height: 24),

        _buildInfoNote(
          'Please provide detailed information about your purpose of stay.',
        ),
      ],
    );
  }

  Widget _buildTouristInfo() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.luggage,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Tourist Stay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No additional information required',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildInfoNote(
          'Tourist accommodations are available for short-term stays.',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onChanged: onChanged,
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
