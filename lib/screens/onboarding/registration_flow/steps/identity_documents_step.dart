// lib/screens/onboarding/registration_flow/steps/identity_documents_step.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../registration_controller.dart';

class IdentityDocumentsStep extends ConsumerStatefulWidget {
  const IdentityDocumentsStep({Key? key}) : super(key: key);

  @override
  ConsumerState<IdentityDocumentsStep> createState() =>
      _IdentityDocumentsStepState();
}

class _IdentityDocumentsStepState extends ConsumerState<IdentityDocumentsStep> {
  final _documentNumberController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final model = ref.read(registrationProvider);
    _documentNumberController.text = model.documentNumber;
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (isFront) {
          RegistrationController.updateIdentityDocuments(
            ref,
            documentImagePath: pickedFile.path,
          );
        } else {
          RegistrationController.updateIdentityDocuments(
            ref,
            documentBackImagePath: pickedFile.path,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showImageSourceDialog(bool isFront) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1976D2)),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isFront);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF1976D2)),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isFront);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(registrationProvider);
    final documentTypes = ['CNIC', 'Passport'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Identity Documents',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your identification documents',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Document Type Selection
          _buildDropdownField(
            label: 'Document Type',
            value: model.documentType.isNotEmpty ? model.documentType : null,
            items: documentTypes,
            icon: Icons.badge_outlined,
            required: true,
            onChanged: (value) {
              // Clear document images when type changes
              RegistrationController.updateIdentityDocuments(
                ref,
                documentType: value,
                documentImagePath: null,
                documentBackImagePath: null,
              );
              _documentNumberController.clear();
            },
          ),
          const SizedBox(height: 20),

          // Document Number
          if (model.documentType.isNotEmpty) ...[
            _buildTextField(
              controller: _documentNumberController,
              label: model.documentType == 'CNIC'
                  ? 'CNIC Number'
                  : 'Passport Number',
              hint: model.documentType == 'CNIC'
                  ? '12345-1234567-1'
                  : 'AB1234567',
              icon: Icons.numbers,
              required: true,
              onChanged: (value) {
                RegistrationController.updateIdentityDocuments(
                  ref,
                  documentNumber: value,
                );
              },
            ),
            const SizedBox(height: 32),

            // Document Upload Section
            if (model.documentType == 'CNIC') ...[
              // CNIC Front
              _buildImageUploadCard(
                title: 'CNIC Front Side',
                imagePath: model.documentImagePath,
                onTap: () => _showImageSourceDialog(true),
                onRemove: () {
                  RegistrationController.updateIdentityDocuments(
                    ref,
                    documentImagePath: null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // CNIC Back
              _buildImageUploadCard(
                title: 'CNIC Back Side',
                imagePath: model.documentBackImagePath,
                onTap: () => _showImageSourceDialog(false),
                onRemove: () {
                  RegistrationController.updateIdentityDocuments(
                    ref,
                    documentBackImagePath: null,
                  );
                },
              ),
            ] else ...[
              // Passport
              _buildImageUploadCard(
                title: 'Passport Photo Page',
                imagePath: model.documentImagePath,
                onTap: () => _showImageSourceDialog(true),
                onRemove: () {
                  RegistrationController.updateIdentityDocuments(
                    ref,
                    documentImagePath: null,
                  );
                },
              ),
            ],

            const SizedBox(height: 32),

            // Guidelines
            _buildGuidelines(model.documentType),
          ],
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
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
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

  Widget _buildImageUploadCard({
    required String title,
    required String? imagePath,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  hasImage ? Icons.check_circle : Icons.upload_file,
                  color: hasImage
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF1976D2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
                if (hasImage)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
          if (hasImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10)),
              child: Image.file(
                File(imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            InkWell(
              onTap: onTap,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10)),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuidelines(String documentType) {
    final guidelines = documentType == 'CNIC'
        ? [
            'Ensure CNIC is valid and not expired',
            'Both front and back sides are required',
            'Images should be clear and readable',
            'All text and numbers must be visible',
          ]
        : [
            'Passport must be valid for at least 6 months',
            'Photo page with personal details required',
            'Image should be clear and readable',
            'All details must be clearly visible',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 20),
              SizedBox(width: 8),
              Text(
                'Upload Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF57C00),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...guidelines.map((guideline) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: Color(0xFFF57C00))),
                    Expanded(
                      child: Text(
                        guideline,
                        style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
