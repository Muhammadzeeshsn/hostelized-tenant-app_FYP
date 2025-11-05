// lib/screens/register/verify_identity_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Verify Identity
/// - Gracefully proceeds when camera is unavailable (simulator/permissions).
/// - On success: go('/register/success') → that screen auto-navigates to /dashboard.
class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key, this.uploadedPath});

  /// Optional path of the image picked on the previous screen.
  final String? uploadedPath;

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  String? _uploadedPath;
  XFile? _liveShot;

  String _status = 'Tap "Verify it\'s you" to start face scan.';
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_uploadedPath == null) {
      final s = GoRouterState.of(context);
      _uploadedPath =
          widget.uploadedPath ??
          (s.extra as String?) ??
          s.uri.queryParameters['uploaded'];
    }
  }

  Future<void> _captureAndCompare() async {
    final uploaded = _uploadedPath;
    if (uploaded == null || uploaded.isEmpty) {
      setState(() {
        _status = 'No uploaded image found. Please go back and upload.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Opening camera...';
    });

    XFile? shot;
    try {
      shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
    } catch (e) {
      // camera plugin threw (simulator / permissions etc.)
      debugPrint('Camera error: $e');
    }

    if (shot == null) {
      if (!mounted) return;
      // Offer to proceed anyway
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Camera not available'),
          content: const Text(
            'We could not open the camera. Do you want to proceed anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Retake'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (proceed == true) {
        setState(() {
          _busy = false;
          _status = 'Proceeding without live capture...';
        });
        context.go('/register/success');
      } else {
        setState(() {
          _busy = false;
          _status = 'Tap "Verify it\'s you" to try again.';
        });
      }
      return;
    }

    setState(() {
      _liveShot = shot;
      _status = 'Verifying...';
    });

    // ---- Placeholder "matching" by file-size similarity (<=10%) ----
    try {
      final a = await File(uploaded).length();
      final b = await File(shot.path).length();
      final diffRatio = (a - b).abs() / (a == 0 ? 1 : a);
      final match = diffRatio <= 0.10;

      if (!mounted) return;
      if (match) {
        context.go('/register/success');
      } else {
        setState(() {
          _busy = false;
          _status =
              'Faces do not appear to match.\nPlease retake a clear photo and try again.';
        });
      }
    } catch (e) {
      debugPrint('Comparison error: $e');
      if (!mounted) return;
      // If comparison fails, still allow proceeding.
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Could not compare images'),
          content: const Text(
            'An error occurred while comparing photos. Proceed anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (proceed == true) {
        context.go('/register/success');
      } else {
        setState(() {
          _busy = false;
          _status = 'Tap "Verify it\'s you" to try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadedFile = (_uploadedPath != null && _uploadedPath!.isNotEmpty)
        ? File(_uploadedPath!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify it's you"),
        automaticallyImplyLeading: true, // back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (uploadedFile != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _PhotoCard(title: 'Uploaded', file: uploadedFile),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PhotoCard(
                      title: 'Live',
                      file: _liveShot != null ? File(_liveShot!.path) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(_status, textAlign: TextAlign.center),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text("Verify it's you"),
                onPressed: _busy ? null : _captureAndCompare,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String title;
  final File? file;
  const _PhotoCard({required this.title, required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file != null
                  ? Image.file(file!, fit: BoxFit.cover)
                  : const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x11000000)),
                      child: Center(child: Text('—')),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
