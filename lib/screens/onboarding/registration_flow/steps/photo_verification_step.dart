// lib/screens/onboarding/registration_flow/steps/photo_verification_step.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../registration_controller.dart';
import '../../../../services/face_verification_service.dart';

class PhotoVerificationStep extends ConsumerStatefulWidget {
  const PhotoVerificationStep({Key? key}) : super(key: key);

  @override
  ConsumerState<PhotoVerificationStep> createState() =>
      _PhotoVerificationStepState();
}

class _PhotoVerificationStepState extends ConsumerState<PhotoVerificationStep> {
  final ImagePicker _picker = ImagePicker();
  final FaceVerificationService _faceService = FaceVerificationService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _faceService.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        await _processCapturedPhoto(photo.path, fromCamera: true);
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processCapturedPhoto(image.path, fromCamera: false);
      }
    } catch (e) {
      _showError('Failed to upload photo: $e');
    }
  }

  Future<void> _processCapturedPhoto(String imagePath,
      {required bool fromCamera}) async {
    setState(() => _isProcessing = true);

    try {
      // Validate that image has exactly one face
      final validation = await _faceService.validateSingleFace(imagePath);

      if (!validation.isValid) {
        setState(() => _isProcessing = false);
        _showError(validation.message);
        return;
      }

      // If uploaded from gallery, we need face verification via live camera
      if (!fromCamera) {
        // Store the uploaded photo temporarily
        RegistrationController.updatePhotoVerification(
          ref,
          profileImagePath: imagePath,
          photoFromCamera: false,
          isFaceVerified: false,
        );

        setState(() => _isProcessing = false);

        // Prompt user to verify with live camera
        _showFaceVerificationDialog(imagePath);
      } else {
        // Photo captured from camera - generate encoding and mark as verified
        final encoding = await _faceService.generateFaceEncoding(imagePath);

        RegistrationController.updatePhotoVerification(
          ref,
          profileImagePath: imagePath,
          faceEncodingData: encoding,
          photoFromCamera: true,
          isFaceVerified: true,
        );

        setState(() => _isProcessing = false);

        _showSuccess('Photo captured and verified successfully!');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Error processing photo: $e');
    }
  }

  Future<void> _showFaceVerificationDialog(String uploadedImagePath) async {
    final shouldVerify = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.face_retouching_natural, color: Color(0xFF1976D2)),
            SizedBox(width: 8),
            Text('Face Verification Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For security purposes, we need to verify that the uploaded photo is actually you.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Please capture a live photo using your camera to verify your identity.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Remove uploaded photo
              RegistrationController.updatePhotoVerification(
                ref,
                profileImagePath: null,
                isFaceVerified: false,
              );
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify Now'),
          ),
        ],
      ),
    );

    if (shouldVerify == true && mounted) {
      await _verifyFaceWithCamera(uploadedImagePath);
    }
  }

  Future<void> _verifyFaceWithCamera(String uploadedImagePath) async {
    try {
      final XFile? livePhoto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (livePhoto == null) return;

      setState(() => _isProcessing = true);

      // Compare uploaded photo with live camera photo
      final comparison = await _faceService.compareFaces(
        uploadedImagePath,
        livePhoto.path,
      );

      setState(() => _isProcessing = false);

      if (!comparison.isMatch) {
        _showError(
          '${comparison.message}\n\nSimilarity: ${comparison.similarity}%\n\nPlease re-upload your correct photo or capture directly from camera.',
        );

        // Clear the uploaded photo
        RegistrationController.updatePhotoVerification(
          ref,
          profileImagePath: null,
          isFaceVerified: false,
        );
        return;
      }

      // Faces match! Generate encoding and mark as verified
      final encoding =
          await _faceService.generateFaceEncoding(uploadedImagePath);

      RegistrationController.updatePhotoVerification(
        ref,
        profileImagePath: uploadedImagePath,
        faceEncodingData: encoding,
        photoFromCamera: false,
        isFaceVerified: true,
      );

      _showSuccess(
        'Face verified successfully!\n\nSimilarity: ${comparison.similarity}%',
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Verification failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(registrationProvider);
    final hasPhoto = model.profileImagePath != null;
    final isVerified = model.isFaceVerified;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Photo & Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Final step - capture your photo and accept terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Photo Preview
          Center(
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVerified
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF1976D2),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.file(
                            File(model.profileImagePath!),
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Photo Action Buttons
          if (_isProcessing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _captureFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploadFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side:
                          const BorderSide(color: Color(0xFF1976D2), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasPhoto && !isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Face verification pending',
                          style: TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 24),

          // Terms & Conditions
          Text(
            'Terms & Conditions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                ),
          ),
          const SizedBox(height: 16),

          // Hostel Policies
          CheckboxListTile(
            title: const Text(
              'I accept the Hostel Policies',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: TextButton(
              onPressed: () {
                // TODO: Show hostel policies dialog
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: const Text('View Hostel Policies'),
            ),
            value: model.hostelPoliciesAccepted,
            onChanged: (value) {
              RegistrationController.updatePhotoVerification(
                ref,
                hostelPoliciesAccepted: value,
              );
            },
            activeColor: const Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),

          // Terms & Conditions
          CheckboxListTile(
            title: const Text(
              'I accept Hostelized & Behostelized Terms & Conditions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: TextButton(
              onPressed: () {
                // TODO: Show terms & conditions dialog
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: const Text('View Terms & Conditions'),
            ),
            value: model.termsConditionsAccepted,
            onChanged: (value) {
              RegistrationController.updatePhotoVerification(
                ref,
                termsConditionsAccepted: value,
              );
            },
            activeColor: const Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 32),

          // Guidelines
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user,
                        color: Color(0xFF388E3C), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Photo Guidelines',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  'Face the camera directly',
                  'Ensure good lighting',
                  'Remove sunglasses and hats',
                  'Keep eyes open and visible',
                  'Only one person in the photo',
                ].map((guideline) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFF388E3C),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              guideline,
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
