import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';
import '../registration_model.dart';

class PersonalInfoStep extends ConsumerStatefulWidget {
  const PersonalInfoStep({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Track which fields have been interacted with
  final _touchedFields = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final model = ref.read(registrationProvider);
    _firstNameController.text = model.firstName;
    _lastNameController.text = model.lastName;
    _emailController.text = model.email;
    _phoneController.text = model.phoneNumber;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Mark field as touched
  void _markFieldTouched(String fieldName) {
    setState(() {
      _touchedFields[fieldName] = true;
    });
  }

  // Check if field should show error
  bool _shouldShowError(String fieldName, String? error) {
    return _touchedFields[fieldName] == true && error != null;
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(registrationProvider);

    // Gender options
    final genderOptions = ['Male', 'Female', 'Other'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E), // Dark blue for better contrast
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please fill in your personal details to continue',
              style: TextStyle(
                color: Color(0xFF757575), // Medium gray for better readability
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name *',
                labelStyle: const TextStyle(
                  color: Color(0xFF424242), // Dark gray
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF44336)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFF44336), width: 2),
                ),
                hintText: 'John',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF757575),
                ),
                errorMaxLines: 2,
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First name is required';
                }
                if (value.length < 2) {
                  return 'First name must be at least 2 characters';
                }
                return null;
              },
              onChanged: (value) {
                RegistrationController.updatePersonalInfo(
                  ref,
                  firstName: value,
                );
              },
              onTap: () => _markFieldTouched('firstName'),
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                color: Color(0xFF212121), // Very dark gray for text
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name *',
                labelStyle: const TextStyle(
                  color: Color(0xFF424242),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF44336)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFF44336), width: 2),
                ),
                hintText: 'Doe',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF757575),
                ),
                errorMaxLines: 2,
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Last name is required';
                }
                if (value.length < 2) {
                  return 'Last name must be at least 2 characters';
                }
                return null;
              },
              onChanged: (value) {
                RegistrationController.updatePersonalInfo(
                  ref,
                  lastName: value,
                );
              },
              onTap: () => _markFieldTouched('lastName'),
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address *',
                labelStyle: const TextStyle(
                  color: Color(0xFF424242),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF44336)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFF44336), width: 2),
                ),
                hintText: 'john.doe@example.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF757575),
                ),
                errorMaxLines: 2,
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onChanged: (value) {
                RegistrationController.updatePersonalInfo(
                  ref,
                  email: value,
                );
              },
              onTap: () => _markFieldTouched('email'),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                labelStyle: const TextStyle(
                  color: Color(0xFF424242),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF44336)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFF44336), width: 2),
                ),
                hintText: '+92 300 1234567',
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF757575),
                ),
                errorMaxLines: 2,
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                final phoneRegex = RegExp(r'^[0-9+\-\s]{10,15}$');
                if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              onChanged: (value) {
                RegistrationController.updatePersonalInfo(
                  ref,
                  phoneNumber: value,
                );
              },
              onTap: () => _markFieldTouched('phone'),
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: Color(0xFF212121),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Date of Birth
            InkWell(
              onTap: () {
                _markFieldTouched('dob');
                _selectDateOfBirth(context, ref);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: const TextStyle(
                    color: Color(0xFF424242),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF2196F3), width: 2),
                  ),
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF757575),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model.dateOfBirth != null
                          ? '${model.dateOfBirth!.day}/${model.dateOfBirth!.month}/${model.dateOfBirth!.year}'
                          : 'Select your date of birth',
                      style: TextStyle(
                        color: model.dateOfBirth != null
                            ? const Color(0xFF212121)
                            : const Color(0xFF9E9E9E),
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: Color(0xFF757575),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gender Dropdown
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: const TextStyle(
                  color: Color(0xFF424242),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF757575),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: model.gender.isNotEmpty ? model.gender : null,
                  hint: const Text(
                    'Select gender',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF757575)),
                  style: const TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 16,
                  ),
                  items: genderOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      RegistrationController.updatePersonalInfo(
                        ref,
                        gender: value ?? '',
                      );
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Required fields note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light blue background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF90CAF9), // Light blue border
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF1976D2), // Darker blue
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fields marked with * are required to proceed to the next step',
                      style: TextStyle(
                        color: const Color(0xFF1976D2),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3), // Blue
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121), // Dark text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF2196F3),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      RegistrationController.updatePersonalInfo(
        ref,
        dateOfBirth: picked,
      );
    }
  }
}
