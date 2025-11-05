import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});
  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  XFile? _photo;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Upload your profile image'),
            const SizedBox(height: 12),
            if (_photo != null)
              CircleAvatar(
                radius: 56,
                backgroundImage: FileImage(File(_photo!.path)),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  onPressed: () async {
                    final p = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (p != null) setState(() => _photo = p);
                  },
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                  onPressed: () async {
                    final p = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (p != null) setState(() => _photo = p);
                  },
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: _photo == null || _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      // In a real app, upload to server. For now, pass the file path.
                      if (!mounted) return;
                      context.go('/register/verify', extra: _photo!.path);
                      setState(() => _busy = false);
                    },
              child: _busy
                  ? const CircularProgressIndicator()
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
