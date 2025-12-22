// lib/services/face_verification_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceVerificationService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// Detect faces in an image
  Future<List<Face>> detectFaces(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      debugPrint('[FaceVerification] Error detecting faces: $e');
      rethrow;
    }
  }

  /// Validate if image has exactly one face
  Future<FaceValidationResult> validateSingleFace(String imagePath) async {
    try {
      final faces = await detectFaces(imagePath);

      if (faces.isEmpty) {
        return FaceValidationResult(
          isValid: false,
          message: 'No face detected in the image',
        );
      }

      if (faces.length > 1) {
        return FaceValidationResult(
          isValid: false,
          message:
              'Multiple faces detected. Please ensure only one person is in the photo',
        );
      }

      final face = faces.first;

      // Check if face is clear enough (confidence checks)
      if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 30) {
        return FaceValidationResult(
          isValid: false,
          message: 'Please face the camera directly',
        );
      }

      if (face.headEulerAngleZ != null && face.headEulerAngleZ!.abs() > 20) {
        return FaceValidationResult(
          isValid: false,
          message: 'Please keep your head straight',
        );
      }

      // Check if eyes are open (if classification is available)
      if (face.leftEyeOpenProbability != null &&
          face.leftEyeOpenProbability! < 0.5) {
        return FaceValidationResult(
          isValid: false,
          message: 'Please keep your eyes open',
        );
      }

      if (face.rightEyeOpenProbability != null &&
          face.rightEyeOpenProbability! < 0.5) {
        return FaceValidationResult(
          isValid: false,
          message: 'Please keep your eyes open',
        );
      }

      return FaceValidationResult(
        isValid: true,
        message: 'Face detected successfully',
        face: face,
      );
    } catch (e) {
      debugPrint('[FaceVerification] Error validating face: $e');
      return FaceValidationResult(
        isValid: false,
        message: 'Error processing image: ${e.toString()}',
      );
    }
  }

  /// Compare two faces to check if they match
  /// Returns a similarity score (0-100)
  /// Note: This is a basic implementation. For production, use a proper
  /// face recognition library like TensorFlow Lite with FaceNet model
  Future<FaceComparisonResult> compareFaces(
    String imagePath1,
    String imagePath2,
  ) async {
    try {
      final faces1 = await detectFaces(imagePath1);
      final faces2 = await detectFaces(imagePath2);

      if (faces1.isEmpty || faces2.isEmpty) {
        return FaceComparisonResult(
          isMatch: false,
          similarity: 0,
          message: 'Could not detect faces in one or both images',
        );
      }

      final face1 = faces1.first;
      final face2 = faces2.first;

      // Basic comparison using face bounds and landmarks
      // This is a simplified approach - in production, use proper face embeddings
      final similarity = _calculateBasicSimilarity(face1, face2);

      final isMatch = similarity >= 70; // 70% threshold

      return FaceComparisonResult(
        isMatch: isMatch,
        similarity: similarity.round(),
        message: isMatch
            ? 'Faces match successfully!'
            : 'Faces do not match. Please try again with your actual photo.',
      );
    } catch (e) {
      debugPrint('[FaceVerification] Error comparing faces: $e');
      return FaceComparisonResult(
        isMatch: false,
        similarity: 0,
        message: 'Error comparing faces: ${e.toString()}',
      );
    }
  }

  /// Generate face encoding (placeholder)
  /// In production, use a proper face recognition model like FaceNet
  Future<String> generateFaceEncoding(String imagePath) async {
    try {
      final faces = await detectFaces(imagePath);

      if (faces.isEmpty) {
        throw Exception('No face detected');
      }

      final face = faces.first;

      // TODO: Replace with actual face embedding using FaceNet or similar
      // For now, store face landmarks and bounds as a simple encoding
      final encoding = {
        'boundingBox': {
          'left': face.boundingBox.left,
          'top': face.boundingBox.top,
          'width': face.boundingBox.width,
          'height': face.boundingBox.height,
        },
        'headEulerAngleY': face.headEulerAngleY,
        'headEulerAngleZ': face.headEulerAngleZ,
        'leftEyeOpenProbability': face.leftEyeOpenProbability,
        'rightEyeOpenProbability': face.rightEyeOpenProbability,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return encoding.toString();
    } catch (e) {
      debugPrint('[FaceVerification] Error generating encoding: $e');
      rethrow;
    }
  }

  /// Calculate basic similarity between two faces
  /// This is a placeholder - use proper face embeddings in production
  double _calculateBasicSimilarity(Face face1, Face face2) {
    double similarity = 100.0;

    // Compare face sizes (normalized)
    final size1 = face1.boundingBox.width * face1.boundingBox.height;
    final size2 = face2.boundingBox.width * face2.boundingBox.height;
    final sizeDiff = (size1 - size2).abs() / size1;
    similarity -= sizeDiff * 20;

    // Compare head angles
    if (face1.headEulerAngleY != null && face2.headEulerAngleY != null) {
      final angleDiff = (face1.headEulerAngleY! - face2.headEulerAngleY!).abs();
      similarity -= (angleDiff / 30) * 15;
    }

    // Compare eye open probabilities
    if (face1.leftEyeOpenProbability != null &&
        face2.leftEyeOpenProbability != null) {
      final eyeDiff =
          (face1.leftEyeOpenProbability! - face2.leftEyeOpenProbability!).abs();
      similarity -= eyeDiff * 10;
    }

    return similarity.clamp(0, 100);
  }

  void dispose() {
    _faceDetector.close();
  }
}

class FaceValidationResult {
  final bool isValid;
  final String message;
  final Face? face;

  FaceValidationResult({
    required this.isValid,
    required this.message,
    this.face,
  });
}

class FaceComparisonResult {
  final bool isMatch;
  final int similarity;
  final String message;

  FaceComparisonResult({
    required this.isMatch,
    required this.similarity,
    required this.message,
  });
}
