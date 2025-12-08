// lib/screens/onboarding/tenant_registration_flow.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../../models/tenant_registration_draft.dart';
import '../../services/tenant_registration_storage.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../../api/tenant_api.dart';

// Import only the draft model, not the enums separately
// Enums are already defined in tenant_registration_draft.dart

class TenantRegistrationFlow extends StatefulWidget {
  final String? username;

  const TenantRegistrationFlow({
    super.key,
    this.username,
  });

  @override
  State<TenantRegistrationFlow> createState() => _TenantRegistrationFlowState();
}

class _TenantRegistrationFlowState extends State<TenantRegistrationFlow> {
  final _storage = TenantRegistrationStorage();
  final PageController _pageController = PageController();
  TenantRegistrationDraft _draft = const TenantRegistrationDraft.empty();
  int _currentStep = 0;
  bool _saving = false;
  String? _error;
  bool _autoSaveEnabled = true;

  // Step validation states
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDraft();
    debugPrint('[Registration] Initializing registration flow');
  }

  Future<void> _initializeDraft() async {
    try {
      final loadedDraft = await _storage.load();
      debugPrint('[Registration] Loaded draft: ${loadedDraft.email}');

      if (widget.username != null && (loadedDraft.email?.isEmpty ?? true)) {
        final prefill = loadedDraft.copyWith(email: widget.username);
        await _storage.save(prefill);
        setState(() => _draft = prefill);
        debugPrint('[Registration] Prefilled email: ${widget.username}');
      } else {
        setState(() => _draft = loadedDraft);
      }
    } catch (e) {
      debugPrint('[Registration] Init error: $e');
      setState(() => _error = 'Failed to load saved data');
    }
  }

  Future<void> _saveDraft(TenantRegistrationDraft draft) async {
    if (!_autoSaveEnabled) return;

    setState(() => _draft = draft);
    try {
      await _storage.save(draft);
      debugPrint('[Registration] Draft saved successfully');
    } catch (e) {
      debugPrint('[Registration] Save error: $e');
    }
  }

  Future<void> _goToStep(int step) async {
    debugPrint('[Registration] Navigating from step $_currentStep to $step');

    if (step < _currentStep) {
      // Going back - just navigate
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = step);
      return;
    }

    // Validate current step before proceeding forward
    if (_currentStep < 4) {
      final isValid = await _validateCurrentStep();
      if (!isValid) {
        debugPrint('[Registration] Step $_currentStep validation failed');
        return;
      }
    }

    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  Future<bool> _validateCurrentStep() async {
    debugPrint('[Registration] Validating step $_currentStep');

    switch (_currentStep) {
      case 0: // Basic Info
        if (!_formKeys[0].currentState!.validate()) {
          _showStepError('Please fill all required fields correctly');
          return false;
        }
        _formKeys[0].currentState!.save();
        break;

      case 1: // Identity
        if (!_formKeys[1].currentState!.validate()) {
          _showStepError('Please complete identity verification');
          return false;
        }
        _formKeys[1].currentState!.save();

        // Additional validation for documents
        if (_draft.documentType == DocumentType.cnic) {
          if (_draft.cnicNumber?.isEmpty ?? true) {
            _showStepError('CNIC number is required');
            return false;
          }
          if (_draft.cnicFrontPath == null || _draft.cnicBackPath == null) {
            _showStepError('Please upload both CNIC front and back photos');
            return false;
          }
        } else if (_draft.documentType == DocumentType.passport) {
          if (_draft.passportImagePath == null) {
            _showStepError('Please upload passport photo');
            return false;
          }
        }
        break;

      case 2: // Guardian
        if (!_formKeys[2].currentState!.validate()) {
          _showStepError('Please provide emergency contact details');
          return false;
        }
        _formKeys[2].currentState!.save();
        break;

      case 3: // Purpose Details
        _formKeys[3].currentState!.save();
        break;

      case 4: // Face & Profile
        if (_draft.profilePhotoPath == null) {
          _showStepError('Please upload profile photo');
          return false;
        }
        if (!_draft.hasFaceScan) {
          _showStepError('Please complete face scan verification');
          return false;
        }
        break;
    }

    return true;
  }

  void _showStepError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitRegistration() async {
    debugPrint('[Registration] Starting submission process');

    if (!await _validateCurrentStep()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _autoSaveEnabled = false; // Disable auto-save during submission
    });

    try {
      debugPrint('[Registration] Submitting to API...');
      final api = TenantApi();
      final success = await api.submitTenantRegistration(_draft);

      if (!mounted) return;

      if (success) {
        debugPrint('[Registration] Submission successful');
        await _storage.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Registration submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to dashboard after success
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go(AppRoutes.dashboard);
        }
      } else {
        throw Exception('Server rejected the submission');
      }
    } catch (e) {
      debugPrint('[Registration] Submission error: $e');
      setState(() => _error = e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _autoSaveEnabled = true;
        });
      }
    }
  }

  // Helper functions for enum display
  String _getGenderDisplay(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  String _getPurposeDisplay(PurposeOfStay purpose) {
    switch (purpose) {
      case PurposeOfStay.student:
        return 'Student';
      case PurposeOfStay.jobBusiness:
        return 'Job / Business';
      case PurposeOfStay.other:
        return 'Other';
    }
  }

  String _getDocumentTypeDisplay(DocumentType type) {
    switch (type) {
      case DocumentType.cnic:
        return 'CNIC';
      case DocumentType.passport:
        return 'Passport';
    }
  }

  Future<void> _simulateFaceScan() async {
    debugPrint('[Registration] Starting face scan simulation');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _FaceScanDialog(),
    );

    if (result == true && mounted) {
      final updated = _draft.copyWith(
        hasFaceScan: true,
        faceScanId: 'face-${DateTime.now().millisecondsSinceEpoch}',
      );
      await _saveDraft(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.verified_user, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Face scan completed successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[Registration] Building step $_currentStep');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _goToStep(_currentStep - 1);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Complete Registration (${_currentStep + 1}/5)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          if (_error != null) _buildErrorBanner(),

          // Main Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _BasicInfoStep(
                  key: const ValueKey('step-basic'),
                  formKey: _formKeys[0],
                  draft: _draft,
                  onChanged: _saveDraft,
                  getGenderDisplay: _getGenderDisplay,
                  getPurposeDisplay: _getPurposeDisplay,
                ),
                _IdentityStep(
                  key: const ValueKey('step-identity'),
                  formKey: _formKeys[1],
                  draft: _draft,
                  onChanged: _saveDraft,
                  getDocumentTypeDisplay: _getDocumentTypeDisplay,
                ),
                _GuardianStep(
                  key: const ValueKey('step-guardian'),
                  formKey: _formKeys[2],
                  draft: _draft,
                  onChanged: _saveDraft,
                ),
                _PurposeDetailsStep(
                  key: const ValueKey('step-purpose'),
                  formKey: _formKeys[3],
                  draft: _draft,
                  onChanged: _saveDraft,
                ),
                _FaceStep(
                  key: const ValueKey('step-face'),
                  draft: _draft,
                  onChanged: _saveDraft,
                  onSimulateFaceScan: _simulateFaceScan,
                ),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(kBrandBlue),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(_currentStep),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kBrandBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[700], size: 18),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () => _goToStep(_currentStep - 1),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: kBrandBlue),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _saving ? null : _getNextAction,
              icon: _getNextIcon(),
              label: Text(_getNextButtonText()),
              style: FilledButton.styleFrom(
                backgroundColor: kBrandBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getNextAction() {
    if (_currentStep < 4) {
      _goToStep(_currentStep + 1);
    } else {
      _submitRegistration();
    }
  }

  Widget _getNextIcon() {
    if (_saving) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    return Icon(
      _currentStep < 4 ? Icons.arrow_forward : Icons.check,
      size: 18,
    );
  }

  String _getNextButtonText() {
    if (_saving) return 'Submitting...';
    return _currentStep < 4 ? 'Continue' : 'Submit Registration';
  }

  String _getStepTitle(int step) {
    final titles = [
      'Basic Information',
      'Identity & Address',
      'Emergency Contact',
      'Purpose Details',
      'Face & Profile Photo',
    ];
    return titles[step];
  }
}

// ====================================================================
// Step 1: Basic Information
// ====================================================================
class _BasicInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;
  final String Function(Gender) getGenderDisplay;
  final String Function(PurposeOfStay) getPurposeDisplay;

  const _BasicInfoStep({
    super.key,
    required this.formKey,
    required this.draft,
    required this.onChanged,
    required this.getGenderDisplay,
    required this.getPurposeDisplay,
  });

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  Gender? _gender;
  PurposeOfStay? _purpose;

  final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _firstNameCtrl = TextEditingController(text: d.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: d.lastName ?? '');
    _emailCtrl = TextEditingController(text: d.email ?? '');
    _phoneCtrl = TextEditingController(text: d.phone ?? '');
    _gender = d.gender;
    _purpose = d.purposeOfStay;
    debugPrint('[BasicInfoStep] Initialized with email: ${d.email}');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final updated = widget.draft.copyWith(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      purposeOfStay: _purpose,
    );
    widget.onChanged(updated);
    debugPrint('[BasicInfoStep] Draft updated: ${_emailCtrl.text}');
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (10-15 digits)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: kBrandBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in your basic details. All fields are required.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Name Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Muhammad',
                      prefixIcon: Icon(Icons.person_outline, color: kBrandBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        _validateRequired(value, 'First name'),
                    onChanged: (_) => _emit(),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Zeeshan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => _validateRequired(value, 'Last name'),
                    onChanged: (_) => _emit(),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Gender
            DropdownButtonFormField<Gender>(
              value: _gender,
              decoration: InputDecoration(
                labelText: 'Gender *',
                prefixIcon: Icon(Icons.transgender, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: Gender.values
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(widget.getGenderDisplay(g)),
                    ),
                  )
                  .toList(),
              validator: (value) => value == null ? 'Gender is required' : null,
              onChanged: (g) {
                setState(() => _gender = g);
                _emit();
              },
              isExpanded: true,
            ),
            const SizedBox(height: 20),

            // Purpose of Stay
            DropdownButtonFormField<PurposeOfStay>(
              value: _purpose,
              decoration: InputDecoration(
                labelText: 'Purpose of Stay *',
                prefixIcon:
                    Icon(Icons.business_center_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: PurposeOfStay.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(widget.getPurposeDisplay(p)),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Purpose of stay is required' : null,
              onChanged: (p) {
                setState(() => _purpose = p);
                _emit();
              },
              isExpanded: true,
            ),
            const SizedBox(height: 20),

            // Email
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address *',
                hintText: 'john@example.com',
                prefixIcon: Icon(Icons.email_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: _validateEmail,
              onChanged: (_) => _emit(),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number *',
                hintText: '+92 300 1234567',
                prefixIcon: Icon(Icons.phone_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: _validatePhone,
              onChanged: (_) => _emit(),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Step 2: Identity & Address
// ====================================================================
class _IdentityStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;
  final String Function(DocumentType) getDocumentTypeDisplay;

  const _IdentityStep({
    super.key,
    required this.formKey,
    required this.draft,
    required this.onChanged,
    required this.getDocumentTypeDisplay,
  });

  @override
  State<_IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<_IdentityStep> {
  late TextEditingController _addressCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _provinceCtrl;
  late TextEditingController _cnicCtrl;

  DocumentType? _docType;
  String? _cnicFront;
  String? _cnicBack;
  String? _passportImg;

  final _picker = ImagePicker();
  final _cnicRegex = RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]{1}$');

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _addressCtrl = TextEditingController(text: d.address ?? '');
    _countryCtrl = TextEditingController(text: d.country ?? 'Pakistan');
    _provinceCtrl = TextEditingController(text: d.province ?? '');
    _cnicCtrl = TextEditingController(text: d.cnicNumber ?? '');
    _docType = d.documentType;
    _cnicFront = d.cnicFrontPath;
    _cnicBack = d.cnicBackPath;
    _passportImg = d.passportImagePath;
    debugPrint('[IdentityStep] Initialized with docType: $_docType');
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _countryCtrl.dispose();
    _provinceCtrl.dispose();
    _cnicCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final updated = widget.draft.copyWith(
      address: _addressCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      province: _provinceCtrl.text.trim(),
      cnicNumber: _cnicCtrl.text.trim(),
      documentType: _docType,
      cnicFrontPath: _cnicFront,
      cnicBackPath: _cnicBack,
      passportImagePath: _passportImg,
    );
    widget.onChanged(updated);
  }

  Future<void> _pickImage(ImageSource source, Function(String) setter) async {
    try {
      debugPrint(
          '[IdentityStep] Picking image from ${source == ImageSource.camera ? 'camera' : 'gallery'}');
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (x != null) {
        setter(x.path);
        _emit();
        if (mounted) setState(() {});
        debugPrint('[IdentityStep] Image picked: ${x.path}');
      }
    } catch (e) {
      debugPrint('[IdentityStep] Image pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateCNIC(String? value) {
    if (_docType != DocumentType.cnic) return null;
    if (value == null || value.trim().isEmpty) {
      return 'CNIC number is required';
    }
    if (!_cnicRegex.hasMatch(value.trim())) {
      return 'Enter CNIC in format: 12345-1234567-1';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identity & Address',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: kBrandBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Verify your identity and provide current address.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Address
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: 'Complete Address *',
                hintText: 'House #, Street, City',
                prefixIcon: Icon(Icons.home_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Address is required'
                  : null,
              onChanged: (_) => _emit(),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryCtrl,
                    decoration: InputDecoration(
                      labelText: 'Country *',
                      prefixIcon: Icon(Icons.flag_outlined, color: kBrandBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Country is required'
                        : null,
                    onChanged: (_) => _emit(),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _provinceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Province/State *',
                      hintText: 'Punjab',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Province is required'
                        : null,
                    onChanged: (_) => _emit(),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Document Type
            DropdownButtonFormField<DocumentType>(
              value: _docType,
              decoration: InputDecoration(
                labelText: 'Document Type *',
                prefixIcon: Icon(Icons.badge_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: DocumentType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(widget.getDocumentTypeDisplay(t)),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Document type is required' : null,
              onChanged: (v) {
                setState(() {
                  _docType = v;
                  // Clear previous images when changing document type
                  _cnicFront = null;
                  _cnicBack = null;
                  _passportImg = null;
                  if (v == DocumentType.cnic) {
                    _cnicCtrl.clear();
                  }
                });
                _emit();
              },
              isExpanded: true,
            ),
            const SizedBox(height: 20),

            // Document-specific fields
            if (_docType == DocumentType.cnic) ...[
              TextFormField(
                controller: _cnicCtrl,
                decoration: InputDecoration(
                  labelText: 'CNIC Number *',
                  hintText: '12345-1234567-1',
                  prefixIcon: Icon(Icons.numbers, color: kBrandBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _validateCNIC,
                onChanged: (_) => _emit(),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload CNIC Photos (Both sides required)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ImageUploadCard(
                      label: 'CNIC Front',
                      imagePath: _cnicFront,
                      onCamera: () =>
                          _pickImage(ImageSource.camera, (p) => _cnicFront = p),
                      onGallery: () => _pickImage(
                          ImageSource.gallery, (p) => _cnicFront = p),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ImageUploadCard(
                      label: 'CNIC Back',
                      imagePath: _cnicBack,
                      onCamera: () =>
                          _pickImage(ImageSource.camera, (p) => _cnicBack = p),
                      onGallery: () =>
                          _pickImage(ImageSource.gallery, (p) => _cnicBack = p),
                    ),
                  ),
                ],
              ),
              if ((_cnicFront == null || _cnicBack == null) &&
                  _docType == DocumentType.cnic)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Both CNIC photos are required',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
            ] else if (_docType == DocumentType.passport) ...[
              const SizedBox(height: 16),
              const Text(
                'Upload Passport Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _ImageUploadCard(
                label: 'Passport',
                imagePath: _passportImg,
                onCamera: () =>
                    _pickImage(ImageSource.camera, (p) => _passportImg = p),
                onGallery: () =>
                    _pickImage(ImageSource.gallery, (p) => _passportImg = p),
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Image Upload Card Widget
// ====================================================================
class _ImageUploadCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ImageUploadCard({
    required this.label,
    required this.imagePath,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: imagePath != null ? Colors.green : Colors.grey[300]!,
          width: imagePath != null ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  imagePath != null ? Icons.check_circle : Icons.photo,
                  color: imagePath != null ? Colors.green : kBrandBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: imagePath != null ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (imagePath != null)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_size_select_actual,
                        size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No image selected',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGallery,
                    icon: const Icon(Icons.photo_library, size: 16),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Step 3: Guardian Information
// ====================================================================
class _GuardianStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;

  const _GuardianStep({
    super.key,
    required this.formKey,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_GuardianStep> createState() => _GuardianStepState();
}

class _GuardianStepState extends State<_GuardianStep> {
  late TextEditingController _relationCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  final _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _relationCtrl = TextEditingController(text: d.guardianRelationship ?? '');
    _nameCtrl = TextEditingController(text: d.guardianName ?? '');
    _phoneCtrl = TextEditingController(text: d.guardianPhone ?? '');
    debugPrint('[GuardianStep] Initialized');
  }

  @override
  void dispose() {
    _relationCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final updated = widget.draft.copyWith(
      guardianRelationship: _relationCtrl.text.trim(),
      guardianName: _nameCtrl.text.trim(),
      guardianPhone: _phoneCtrl.text.trim(),
    );
    widget.onChanged(updated);
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Emergency contact number is required';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (10-15 digits)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contact',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: kBrandBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Provide details of someone we can contact in case of emergency.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Relationship
            TextFormField(
              controller: _relationCtrl,
              decoration: InputDecoration(
                labelText: 'Relationship *',
                hintText: 'Father / Mother / Guardian',
                prefixIcon:
                    Icon(Icons.family_restroom_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Relationship is required'
                  : null,
              onChanged: (_) => _emit(),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'John Doe',
                prefixIcon: Icon(Icons.person_outline, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Name is required'
                  : null,
              onChanged: (_) => _emit(),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Emergency Contact Number *',
                hintText: '+92 300 1234567',
                prefixIcon: Icon(Icons.emergency_outlined, color: kBrandBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: _validatePhone,
              onChanged: (_) => _emit(),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),

            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This contact will be used only for emergency situations and important notifications.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Step 4: Purpose Details
// ====================================================================
class _PurposeDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;

  const _PurposeDetailsStep({
    super.key,
    required this.formKey,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_PurposeDetailsStep> createState() => _PurposeDetailsStepState();
}

class _PurposeDetailsStepState extends State<_PurposeDetailsStep> {
  late TextEditingController _collegeCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _regNoCtrl;
  late TextEditingController _bizDetailsCtrl;
  late TextEditingController _bizAddressCtrl;
  late TextEditingController _bizDesignationCtrl;
  late TextEditingController _otherPurposeCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _collegeCtrl = TextEditingController(text: d.studentCollege ?? '');
    _deptCtrl = TextEditingController(text: d.studentDepartment ?? '');
    _regNoCtrl = TextEditingController(text: d.studentRegNo ?? '');
    _bizDetailsCtrl = TextEditingController(text: d.businessDetails ?? '');
    _bizAddressCtrl = TextEditingController(text: d.businessAddress ?? '');
    _bizDesignationCtrl =
        TextEditingController(text: d.businessDesignation ?? '');
    _otherPurposeCtrl = TextEditingController(text: d.otherPurpose ?? '');
    debugPrint(
        '[PurposeDetailsStep] Initialized with purpose: ${d.purposeOfStay}');
  }

  @override
  void dispose() {
    _collegeCtrl.dispose();
    _deptCtrl.dispose();
    _regNoCtrl.dispose();
    _bizDetailsCtrl.dispose();
    _bizAddressCtrl.dispose();
    _bizDesignationCtrl.dispose();
    _otherPurposeCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final updated = widget.draft.copyWith(
      studentCollege: _collegeCtrl.text.trim(),
      studentDepartment: _deptCtrl.text.trim(),
      studentRegNo: _regNoCtrl.text.trim(),
      businessDetails: _bizDetailsCtrl.text.trim(),
      businessAddress: _bizAddressCtrl.text.trim(),
      businessDesignation: _bizDesignationCtrl.text.trim(),
      otherPurpose: _otherPurposeCtrl.text.trim(),
    );
    widget.onChanged(updated);
  }

  Widget _buildStudentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _collegeCtrl,
          decoration: InputDecoration(
            labelText: 'College / University',
            hintText: 'University of Engineering and Technology',
            prefixIcon: Icon(Icons.school_outlined, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _deptCtrl,
          decoration: InputDecoration(
            labelText: 'Course / Department',
            hintText: 'Computer Science',
            prefixIcon: Icon(Icons.menu_book_outlined, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _regNoCtrl,
          decoration: InputDecoration(
            labelText: 'Registration Number',
            hintText: '2021-CS-123',
            prefixIcon:
                Icon(Icons.confirmation_number_outlined, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildBusinessFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job / Business Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bizDetailsCtrl,
          decoration: InputDecoration(
            labelText: 'Company / Business Name',
            hintText: 'Tech Solutions Ltd.',
            prefixIcon: Icon(Icons.business_outlined, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bizAddressCtrl,
          decoration: InputDecoration(
            labelText: 'Office Address',
            hintText: 'Main Boulevard, DHA Phase 5',
            prefixIcon: Icon(Icons.location_on_outlined, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bizDesignationCtrl,
          decoration: InputDecoration(
            labelText: 'Designation / Role',
            hintText: 'Software Engineer',
            prefixIcon: Icon(Icons.work_outline, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildOtherPurposeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Purpose Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _otherPurposeCtrl,
          decoration: InputDecoration(
            labelText: 'Explain your purpose of stay',
            hintText: 'Please provide details...',
            prefixIcon: Icon(Icons.description_outlined, color: kBrandBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 4,
          onChanged: (_) => _emit(),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final purpose = widget.draft.purposeOfStay;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purpose Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: kBrandBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Provide additional details about your purpose of stay.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Purpose-specific fields
            if (purpose == PurposeOfStay.student)
              _buildStudentFields()
            else if (purpose == PurposeOfStay.jobBusiness)
              _buildBusinessFields()
            else
              _buildOtherPurposeFields(),

            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This information helps us provide better services and facilities.',
                        style:
                            TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Note: These fields are optional but recommended for better service.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Step 5: Face & Profile Photo
// ====================================================================
class _FaceStep extends StatefulWidget {
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;
  final Future<void> Function() onSimulateFaceScan;

  const _FaceStep({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onSimulateFaceScan,
  });

  @override
  State<_FaceStep> createState() => _FaceStepState();
}

class _FaceStepState extends State<_FaceStep> {
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickProfilePhoto(ImageSource source) async {
    setState(() => _uploading = true);
    try {
      debugPrint(
          '[FaceStep] Picking profile photo from ${source == ImageSource.camera ? 'camera' : 'gallery'}');
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (x != null) {
        final updated = widget.draft.copyWith(profilePhotoPath: x.path);
        widget.onChanged(updated);
        debugPrint('[FaceStep] Profile photo selected: ${x.path}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo uploaded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[FaceStep] Photo pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Face & Profile Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: kBrandBlue,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete biometric verification for security purposes.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Profile Photo Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: widget.draft.profilePhotoPath != null
                    ? Colors.green
                    : Colors.grey[300]!,
                width: widget.draft.profilePhotoPath != null ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: kBrandBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Profile Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: kBrandBlue,
                          ),
                        ),
                      ),
                      if (widget.draft.profilePhotoPath != null)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Profile Photo Preview
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: widget.draft.profilePhotoPath != null
                        ? ClipOval(
                            child: Image.file(
                              File(widget.draft.profilePhotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.person,
                                      size: 60, color: Colors.grey),
                                );
                              },
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.person,
                                size: 60, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Upload Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _uploading
                              ? null
                              : () => _pickProfilePhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Take Photo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _uploading
                              ? null
                              : () => _pickProfilePhoto(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Choose from Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_uploading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          const Text('Uploading...'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Face Scan Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: widget.draft.hasFaceScan
                    ? Colors.green
                    : Colors.orange[300]!,
                width: widget.draft.hasFaceScan ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.face_retouching_natural,
                        color: widget.draft.hasFaceScan
                            ? Colors.green
                            : Colors.orange[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Biometric Face Scan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: widget.draft.hasFaceScan
                                ? Colors.green
                                : Colors.orange[700],
                          ),
                        ),
                      ),
                      if (widget.draft.hasFaceScan)
                        Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.draft.hasFaceScan
                        ? 'Face scan completed successfully. Your biometric data is securely stored.'
                        : 'Required for identity verification and secure access to facilities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.security, size: 40, color: kBrandBlue),
                        const SizedBox(height: 12),
                        const Text(
                          'Security Notice',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your facial data will be encrypted and used only for verification purposes.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: widget.draft.hasFaceScan || _uploading
                        ? null
                        : widget.onSimulateFaceScan,
                    icon: Icon(
                      widget.draft.hasFaceScan
                          ? Icons.check
                          : Icons.fingerprint,
                      size: 20,
                    ),
                    label: Text(
                      widget.draft.hasFaceScan
                          ? 'Face Scan Completed'
                          : 'Start Face Scan',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          widget.draft.hasFaceScan ? Colors.green : kBrandBlue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Card(
            elevation: 0,
            color: Colors.purple[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.purple[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your biometric data is encrypted and stored securely. It will be used only for identity verification.',
                      style: TextStyle(color: Colors.purple[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// Face Scan Dialog
// ====================================================================
class _FaceScanDialog extends StatefulWidget {
  const _FaceScanDialog();

  @override
  State<_FaceScanDialog> createState() => __FaceScanDialogState();
}

class __FaceScanDialogState extends State<_FaceScanDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _phase = 0;
  bool _completed = false;

  final List<String> _phaseMessages = [
    'Initializing face detection...',
    'Position your face in the frame',
    'Please look straight at the camera',
    'Scanning facial features...',
    'Verifying identity...',
    'Processing biometric data...',
    'Securing your data...',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('[FaceScanDialog] Starting face scan simulation');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        final progress = _controller.value;
        final newPhase = (progress * (_phaseMessages.length - 1)).floor();
        if (newPhase != _phase) {
          setState(() => _phase = newPhase);
          debugPrint(
              '[FaceScanDialog] Phase $newPhase: ${_phaseMessages[newPhase]}');
        }
      });

    _startScan();
  }

  Future<void> _startScan() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _controller.forward().then((_) async {
      setState(() => _completed = true);
      debugPrint('[FaceScanDialog] Face scan completed');

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _completed ? Icons.verified : Icons.face_retouching_natural,
              size: 60,
              color: _completed ? Colors.green : kBrandBlue,
            ),
            const SizedBox(height: 20),
            Text(
              _completed ? 'Face Scan Complete!' : 'Biometric Face Scan',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (!_completed) ...[
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kBrandBlue.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                    ),

                    // Scanning animation
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.14159,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kBrandBlue.withOpacity(0.6),
                                width: 2,
                              ),
                              gradient: SweepGradient(
                                colors: [
                                  kBrandBlue.withOpacity(0.1),
                                  kBrandBlue.withOpacity(0.8),
                                  kBrandBlue.withOpacity(0.1),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                startAngle: 0,
                                endAngle: 3.14159 * 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Face icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child:
                          const Icon(Icons.face, size: 60, color: kBrandBlue),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Progress bar
              SizedBox(
                height: 4,
                width: 200,
                child: LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(kBrandBlue),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 16),

              // Status message
              Text(
                _phaseMessages[_phase],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${(_controller.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ] else ...[
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: const Icon(Icons.check, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                'Face scan completed successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your biometric data has been securely stored.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!_completed)
              OutlinedButton(
                onPressed: () {
                  _controller.stop();
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel Scan'),
              ),
          ],
        ),
      ),
    );
  }
}
