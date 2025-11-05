import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class DocsUploadScreen extends StatefulWidget {
  const DocsUploadScreen({super.key});
  @override
  State<DocsUploadScreen> createState() => _DocsUploadScreenState();
}

class _DocsUploadScreenState extends State<DocsUploadScreen> {
  XFile? photo, cnicFront, cnicBack;
  final emergency = TextEditingController();
  final guardian = TextEditingController();
  final relation = TextEditingController();

  Future<void> _capture(ValueSetter<XFile> set, ImageSource s) async {
    final x = await ImagePicker().pickImage(source: s, imageQuality: 85);
    if (x != null) set(x);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandBlue,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _box(
              title: 'Upload your image',
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1C5575),
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () => _capture(
                  (x) => setState(() => photo = x),
                  ImageSource.gallery,
                ),
                child: const Text('Verify'),
              ),
              child: _thumb(photo),
            ),
            const SizedBox(height: 12),
            _box(
              title: 'Upload CNIC Front',
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1C5575),
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () => _capture(
                  (x) => setState(() => cnicFront = x),
                  ImageSource.camera,
                ),
                child: const Text('Capture'),
              ),
              child: _thumb(cnicFront),
            ),
            const SizedBox(height: 12),
            _box(
              title: 'Upload CNIC Back',
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1C5575),
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () => _capture(
                  (x) => setState(() => cnicBack = x),
                  ImageSource.camera,
                ),
                child: const Text('Capture'),
              ),
              child: _thumb(cnicBack),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emergency,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Emergency Contact',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: guardian,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relation,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Relationship',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 180,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5575),
                  ),
                  onPressed: () =>
                      context.go('/register/verify', extra: photo?.path),
                  child: const Text('Register'),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _thumb(XFile? f) {
    if (f == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(f.path), height: 120, fit: BoxFit.cover),
      ),
    );
  }

  Widget _box({
    required String title,
    required Widget child,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBrandBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing,
            ],
          ),
          child,
        ],
      ),
    );
  }
}
