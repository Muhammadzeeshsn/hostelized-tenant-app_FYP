// lib/screens/onboarding/tenant_registration_flow.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/tenant_registration_draft.dart';
import '../../services/tenant_registration_storage.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../../api/tenant_api.dart';

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
  TenantRegistrationDraft _draft = const TenantRegistrationDraft.empty();
  int _step = 0;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDraft();
  }

  Future<void> _initializeDraft() async {
    try {
      final loadedDraft = await _storage.load();

      // Prefill email if username provided and draft is empty
      if (widget.username != null && (loadedDraft.email?.isEmpty ?? true)) {
        final prefill = loadedDraft.copyWith(email: widget.username);
        await _storage.save(prefill);
        setState(() => _draft = prefill);
      } else {
        setState(() => _draft = loadedDraft);
      }
    } catch (e) {
      debugPrint('[TenantRegistrationFlow] Init error: $e');
      setState(() => _error = 'Failed to load saved data');
    }
  }

  Future<void> _saveDraft(TenantRegistrationDraft draft) async {
    setState(() => _draft = draft);
    await _storage.save(draft);
  }

  void _nextStep() {
    if (_step < 4) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        setState(() => _step++);
      } else {
        _showValidationError();
      }
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0: // Basic Info
        return (_draft.firstName?.isNotEmpty ?? false) &&
            (_draft.lastName?.isNotEmpty ?? false) &&
            (_draft.email?.isNotEmpty ?? false) &&
            (_draft.gender != null) &&
            (_draft.purposeOfStay != null);

      case 1: // Identity
        return (_draft.address?.isNotEmpty ?? false) &&
            (_draft.documentType != null) &&
            (_draft.documentType == DocumentType.passport
                ? _draft.passportImagePath != null
                : (_draft.cnicNumber?.isNotEmpty ?? false) &&
                    _draft.cnicFrontPath != null &&
                    _draft.cnicBackPath != null);

      case 2: // Guardian
        return (_draft.guardianName?.isNotEmpty ?? false) &&
            (_draft.guardianPhone?.isNotEmpty ?? false) &&
            (_draft.guardianRelationship?.isNotEmpty ?? false);

      case 3: // Purpose Details
        return true; // Optional step

      case 4: // Face & Profile
        return _draft.profilePhotoPath != null && _draft.hasFaceScan;

      default:
        return true;
    }
  }

  void _showValidationError() {
    const messages = {
      0: 'Please fill all basic information fields',
      1: 'Please complete identity verification and upload documents',
      2: 'Please provide emergency contact details',
      4: 'Please upload profile photo and complete face scan',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messages[_step] ?? 'Please complete required fields'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_validateCurrentStep()) {
      _showValidationError();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      debugPrint('[TenantRegistrationFlow] Submitting registration...');
      final api = TenantApi();
      final success = await api.submitTenantRegistration(_draft);

      if (!mounted) return;

      if (success) {
        await _storage.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Registration submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        context.go(AppRoutes.dashboard);
      } else {
        throw Exception('Server rejected the submission');
      }
    } catch (e) {
      debugPrint('[TenantRegistrationFlow] Submission error: $e');
      setState(() => _error = e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _simulateFaceScan() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _FaceScanDialog(),
    );

    if (ok == true) {
      final updated = _draft.copyWith(
        hasFaceScan: true,
        faceScanId: 'local-sim-${DateTime.now().millisecondsSinceEpoch}',
      );
      await _saveDraft(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
        title: const Text('Complete Registration'),
        actions: [
          TextButton(
            onPressed: () async {
              await _storage.clear();
              if (mounted) context.go(AppRoutes.dashboard);
            },
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepHeader(currentStep: _step),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(t),
              ),
            ),
            _buildNavigation(t),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData t) {
    switch (_step) {
      case 0:
        return _BasicInfoStep(
          key: const ValueKey('step-basic'),
          draft: _draft,
          onChanged: _saveDraft,
        );
      case 1:
        return _IdentityStep(
          key: const ValueKey('step-identity'),
          draft: _draft,
          onChanged: _saveDraft,
        );
      case 2:
        return _GuardianStep(
          key: const ValueKey('step-guardian'),
          draft: _draft,
          onChanged: _saveDraft,
        );
      case 3:
        return _PurposeDetailsStep(
          key: const ValueKey('step-purpose'),
          draft: _draft,
          onChanged: _saveDraft,
        );
      case 4:
      default:
        return _FaceStep(
          key: const ValueKey('step-face'),
          draft: _draft,
          onChanged: _saveDraft,
          onSimulateFaceScan: _simulateFaceScan,
        );
    }
  }

  Widget _buildNavigation(ThemeData t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            TextButton.icon(
              onPressed: _prevStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          ElevatedButton(
            onPressed: _saving ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_step < 4 ? 'Next' : 'Submit'),
                      if (_step < 4) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int currentStep;

  const _StepHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const totalSteps = 5;
    final progress = (currentStep + 1) / totalSteps;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(kBrandBlue),
          ),
          const SizedBox(height: 8),
          Text(
            _titleForStep(currentStep),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  static String _titleForStep(int s) {
    switch (s) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Identity & Address';
      case 2:
        return 'Emergency Contact';
      case 3:
        return 'Purpose Details';
      case 4:
        return 'Face & Profile Photo';
      default:
        return 'Complete Registration';
    }
  }
}

// Step 1: Basic Information
class _BasicInfoStep extends StatefulWidget {
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;

  const _BasicInfoStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  Gender? _gender;
  PurposeOfStay? _purpose;

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
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic information', style: t.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    hintText: 'Muhammad',
                  ),
                  onChanged: (_) => _emit(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                    hintText: 'Zeeshan',
                  ),
                  onChanged: (_) => _emit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Gender>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: Gender.values
                .map(
                  (g) =>
                      DropdownMenuItem(value: g, child: Text(_labelGender(g))),
                )
                .toList(),
            onChanged: (g) {
              setState(() => _gender = g);
              _emit();
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PurposeOfStay>(
            value: _purpose,
            decoration: const InputDecoration(labelText: 'Purpose of stay'),
            items: PurposeOfStay.values
                .map(
                  (p) =>
                      DropdownMenuItem(value: p, child: Text(_labelPurpose(p))),
                )
                .toList(),
            onChanged: (p) {
              setState(() => _purpose = p);
              _emit();
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email address'),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Contact number'),
            onChanged: (_) => _emit(),
          ),
        ],
      ),
    );
  }

  static String _labelGender(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static String _labelPurpose(PurposeOfStay p) {
    switch (p) {
      case PurposeOfStay.student:
        return 'Student';
      case PurposeOfStay.jobBusiness:
        return 'Job / Business';
      case PurposeOfStay.other:
        return 'Other';
    }
  }
}

// Step 2: Identity & Address
class _IdentityStep extends StatefulWidget {
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;

  const _IdentityStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<_IdentityStep> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _provinceCtrl;
  late final TextEditingController _cnicCtrl;

  DocumentType? _docType;
  String? _cnicFront;
  String? _cnicBack;
  String? _passportImg;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _addressCtrl = TextEditingController(text: d.address ?? '');
    _countryCtrl = TextEditingController(text: d.country ?? '');
    _provinceCtrl = TextEditingController(text: d.province ?? '');
    _cnicCtrl = TextEditingController(text: d.cnicNumber ?? '');
    _docType = d.documentType;
    _cnicFront = d.cnicFrontPath;
    _cnicBack = d.cnicBackPath;
    _passportImg = d.passportImagePath;
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

  Future<void> _pickImage(void Function(String path) setter) async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (x == null) return;
      setter(x.path);
      setState(() {});
      _emit();
    } catch (e) {
      debugPrint('[IdentityStep] Image pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity & address',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: 'Home address'),
            maxLines: 2,
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _countryCtrl,
            decoration: const InputDecoration(labelText: 'Country'),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _provinceCtrl,
            decoration: const InputDecoration(labelText: 'Province / State'),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DocumentType>(
            value: _docType,
            decoration: const InputDecoration(labelText: 'Document type'),
            items: const [
              DropdownMenuItem(value: DocumentType.cnic, child: Text('CNIC')),
              DropdownMenuItem(
                  value: DocumentType.passport, child: Text('Passport')),
            ],
            onChanged: (v) {
              setState(() {
                _docType = v;
                _cnicFront = null;
                _cnicBack = null;
                _passportImg = null;
              });
              _emit();
            },
          ),
          const SizedBox(height: 16),
          if (_docType == DocumentType.cnic) ...[
            TextField(
              controller: _cnicCtrl,
              decoration: const InputDecoration(labelText: 'CNIC #'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 12),
            _UploadTile(
              label: 'CNIC Front Photo',
              filePath: _cnicFront,
              onTap: () => _pickImage((p) => _cnicFront = p),
            ),
            const SizedBox(height: 8),
            _UploadTile(
              label: 'CNIC Back Photo',
              filePath: _cnicBack,
              onTap: () => _pickImage((p) => _cnicBack = p),
            ),
          ] else if (_docType == DocumentType.passport) ...[
            _UploadTile(
              label: 'Passport Photo',
              filePath: _passportImg,
              onTap: () => _pickImage((p) => _passportImg = p),
            ),
          ] else ...[
            const Text(
              'Select a document type to upload CNIC or passport.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

// Step 3: Guardian
class _GuardianStep extends StatefulWidget {
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;

  const _GuardianStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_GuardianStep> createState() => _GuardianStepState();
}

class _GuardianStepState extends State<_GuardianStep> {
  late final TextEditingController _relationCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _relationCtrl = TextEditingController(text: d.guardianRelationship ?? '');
    _nameCtrl = TextEditingController(text: d.guardianName ?? '');
    _phoneCtrl = TextEditingController(text: d.guardianPhone ?? '');
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emergency contact',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _relationCtrl,
            decoration: const InputDecoration(
              labelText: 'Relationship with contact',
              hintText: 'Father / Mother / Guardian',
            ),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Emergency contact number',
            ),
            onChanged: (_) => _emit(),
          ),
        ],
      ),
    );
  }
}

// Step 4: Purpose Details
class _PurposeDetailsStep extends StatefulWidget {
  final TenantRegistrationDraft draft;
  final ValueChanged<TenantRegistrationDraft> onChanged;

  const _PurposeDetailsStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_PurposeDetailsStep> createState() => _PurposeDetailsStepState();
}

class _PurposeDetailsStepState extends State<_PurposeDetailsStep> {
  late final TextEditingController _collegeCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _regNoCtrl;

  late final TextEditingController _bizDetailsCtrl;
  late final TextEditingController _bizAddressCtrl;
  late final TextEditingController _bizDesignationCtrl;

  late final TextEditingController _otherPurposeCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;

    _collegeCtrl = TextEditingController(text: d.studentCollege ?? '');
    _deptCtrl = TextEditingController(text: d.studentDepartment ?? '');
    _regNoCtrl = TextEditingController(text: d.studentRegNo ?? '');

    _bizDetailsCtrl = TextEditingController(text: d.businessDetails ?? '');
    _bizAddressCtrl = TextEditingController(text: d.businessAddress ?? '');
    _bizDesignationCtrl = TextEditingController(
      text: d.businessDesignation ?? '',
    );

    _otherPurposeCtrl = TextEditingController(text: d.otherPurpose ?? '');
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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final purpose = widget.draft.purposeOfStay;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Purpose details', style: t.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (purpose == PurposeOfStay.student) ...[
            Text('Student details', style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _collegeCtrl,
              decoration: const InputDecoration(
                labelText: 'College / University',
              ),
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deptCtrl,
              decoration: const InputDecoration(
                labelText: 'Course / Department',
              ),
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _regNoCtrl,
              decoration: const InputDecoration(labelText: 'Registration #'),
              onChanged: (_) => _emit(),
            ),
          ] else if (purpose == PurposeOfStay.jobBusiness) ...[
            Text('Job / Business details', style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _bizDetailsCtrl,
              decoration: const InputDecoration(
                labelText: 'Job / Business details',
              ),
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bizAddressCtrl,
              decoration: const InputDecoration(
                labelText: 'Location complete address',
              ),
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bizDesignationCtrl,
              decoration: const InputDecoration(labelText: 'Designation'),
              onChanged: (_) => _emit(),
            ),
          ] else ...[
            Text('Purpose of stay', style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _otherPurposeCtrl,
              decoration: const InputDecoration(
                labelText: 'Explain your purpose of stay',
              ),
              maxLines: 3,
              onChanged: (_) => _emit(),
            ),
          ],
        ],
      ),
    );
  }
}

// Step 5: Face & Profile
class _FaceStep extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bgColor = kBrandBlue.withAlpha((255 * 0.1).round());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Face & profile', style: t.textTheme.titleLarge),
          const SizedBox(height: 16),
          Text(
            'For security purposes, we require a profile photo and biometric face scan.',
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: bgColor,
              backgroundImage: draft.profilePhotoPath != null
                  ? FileImage(File(draft.profilePhotoPath!))
                  : null,
              child: draft.profilePhotoPath == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: const Text('Profile photo'),
            subtitle: Text(
              draft.profilePhotoPath == null
                  ? 'Upload or capture a clear face photo.'
                  : 'Photo selected.',
            ),
            trailing: TextButton(
              onPressed: () async {
                final picker = ImagePicker();
                final x = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (x == null) return;
                onChanged(draft.copyWith(profilePhotoPath: x.path));
              },
              child: const Text('Capture'),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              draft.hasFaceScan
                  ? Icons.check_circle
                  : Icons.face_retouching_natural,
              color: draft.hasFaceScan ? Colors.green : t.colorScheme.primary,
            ),
            title: Text(
              draft.hasFaceScan ? 'Face scan completed' : 'Biometric face scan',
            ),
            subtitle: Text(
              draft.hasFaceScan
                  ? 'Face data stored securely.'
                  : 'Required for identity verification.',
            ),
            trailing: TextButton(
              onPressed: draft.hasFaceScan ? null : onSimulateFaceScan,
              child: Text(draft.hasFaceScan ? 'Done' : 'Start Scan'),
            ),
          ),
        ],
      ),
    );
  }
}

// Upload Tile Widget
class _UploadTile extends StatelessWidget {
  final String label;
  final String? filePath;
  final VoidCallback onTap;

  const _UploadTile({
    required this.label,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
          color: filePath != null ? Colors.green[50] : Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filePath == null ? label : '✓ $label uploaded',
                style: TextStyle(
                  color: filePath != null ? Colors.green[700] : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Face Scan Simulation Dialog
class _FaceScanDialog extends StatefulWidget {
  const _FaceScanDialog();

  @override
  State<_FaceScanDialog> createState() => _FaceScanDialogState();
}

class _FaceScanDialogState extends State<_FaceScanDialog> {
  int _phase = 0;

  @override
  void initState() {
    super.initState();
    _runPhases();
  }

  Future<void> _runPhases() async {
    for (var i = 0; i < 3; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _phase = i + 1);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = switch (_phase) {
      0 => 'Position your face in the frame',
      1 => 'Turn your head slightly left...',
      2 => 'Turn your head slightly right...',
      3 => 'Processing biometric data...',
      _ => 'Processing...',
    };

    return AlertDialog(
      title: const Text('Biometric Scan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kBrandBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
