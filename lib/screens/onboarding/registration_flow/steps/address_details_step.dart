// lib/screens/onboarding/registration_flow/steps/address_details_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';
import '../../../../data/countries_cities_data.dart';

class AddressDetailsStep extends ConsumerStatefulWidget {
  const AddressDetailsStep({Key? key}) : super(key: key);

  @override
  ConsumerState<AddressDetailsStep> createState() => _AddressDetailsStepState();
}

class _AddressDetailsStepState extends ConsumerState<AddressDetailsStep> {
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final model = ref.read(registrationProvider);
    _currentAddressController.text = model.currentAddress;
    _permanentAddressController.text = model.permanentAddress;
  }

  @override
  void dispose() {
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(registrationProvider);
    final countries = CountryCityData.getCountries();
    final currentCities = model.currentCountry.isNotEmpty
        ? CountryCityData.getCitiesForCountry(model.currentCountry)
        : <String>[];
    final permanentCities = model.permanentCountry.isNotEmpty
        ? CountryCityData.getCitiesForCountry(model.permanentCountry)
        : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Address Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us where you currently reside',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Current Address Section
          _buildSectionHeader('Current Residential Address', Icons.location_on),
          const SizedBox(height: 16),

          // Current Country Dropdown
          _buildDropdownField(
            label: 'Country',
            value:
                model.currentCountry.isNotEmpty ? model.currentCountry : null,
            items: countries,
            icon: Icons.public,
            required: true,
            onChanged: (value) {
              // Reset city when country changes
              RegistrationController.updateAddress(
                ref,
                currentCountry: value,
                currentCity: '', // Reset city
              );
            },
          ),
          const SizedBox(height: 16),

          // Current City Dropdown
          _buildDropdownField(
            label: 'City',
            value: model.currentCity.isNotEmpty &&
                    currentCities.contains(model.currentCity)
                ? model.currentCity
                : null,
            items: currentCities,
            icon: Icons.location_city,
            required: true,
            enabled: model.currentCountry.isNotEmpty,
            onChanged: (value) {
              RegistrationController.updateAddress(ref, currentCity: value);
            },
          ),
          const SizedBox(height: 16),

          // Current Street Address
          _buildTextField(
            controller: _currentAddressController,
            label: 'Street Address',
            hint: 'House #, Street, Area',
            icon: Icons.home_outlined,
            required: true,
            maxLines: 2,
            onChanged: (value) {
              RegistrationController.updateAddress(ref, currentAddress: value);
            },
          ),
          const SizedBox(height: 24),

          // Divider
          const Divider(thickness: 1, height: 40),

          // Permanent Address Section
          _buildSectionHeader('Permanent Address', Icons.location_city),
          const SizedBox(height: 16),

          // Same as Current Address Checkbox
          CheckboxListTile(
            title: const Text(
              'Same as current address',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            value: model.sameAsCurrent,
            onChanged: (value) {
              RegistrationController.updateAddress(ref, sameAsCurrent: value);
            },
            activeColor: const Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),

          // Show permanent address fields only if not same as current
          if (!model.sameAsCurrent) ...[
            // Permanent Country Dropdown
            _buildDropdownField(
              label: 'Country',
              value: model.permanentCountry.isNotEmpty
                  ? model.permanentCountry
                  : null,
              items: countries,
              icon: Icons.public,
              required: true,
              onChanged: (value) {
                RegistrationController.updateAddress(
                  ref,
                  permanentCountry: value,
                  permanentCity: '', // Reset city
                );
              },
            ),
            const SizedBox(height: 16),

            // Permanent City Dropdown
            _buildDropdownField(
              label: 'City',
              value: model.permanentCity.isNotEmpty &&
                      permanentCities.contains(model.permanentCity)
                  ? model.permanentCity
                  : null,
              items: permanentCities,
              icon: Icons.location_city,
              required: true,
              enabled: model.permanentCountry.isNotEmpty,
              onChanged: (value) {
                RegistrationController.updateAddress(ref, permanentCity: value);
              },
            ),
            const SizedBox(height: 16),

            // Permanent Street Address
            _buildTextField(
              controller: _permanentAddressController,
              label: 'Street Address',
              hint: 'House #, Street, Area',
              icon: Icons.home_outlined,
              required: true,
              maxLines: 2,
              onChanged: (value) {
                RegistrationController.updateAddress(ref,
                    permanentAddress: value);
              },
            ),
          ],

          const SizedBox(height: 32),

          // Info note
          _buildInfoNote(
            'Your address information is used for official documentation and emergency contact purposes.',
          ),
        ],
      ),
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
    bool enabled = true,
    required Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon:
            Icon(icon, color: enabled ? const Color(0xFF1976D2) : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabled ? const Color(0xFFE0E0E0) : Colors.grey[300]!,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            items.isEmpty ? 'Select country first' : 'Select $label',
            style: TextStyle(color: Colors.grey[600]),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: enabled ? const Color(0xFF757575) : Colors.grey,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
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
