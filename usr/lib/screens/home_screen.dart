import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _sourceImage;
  File? _targetImage;
  bool _isSwapping = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, {required bool isSource}) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isSource) {
          _sourceImage = File(pickedFile.path);
        } else {
          _targetImage = File(pickedFile.path);
        }
      });
    }
  }

  void _swapFaces() {
    if (_sourceImage != null && _targetImage != null) {
      setState(() {
        _isSwapping = true;
      });

      // Simulate face swap operation
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSwapping = false;
          // Here you would typically display the result
          // For now, we'll just show a confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Face swap complete! (simulation)')),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realistic Face Swipe'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ethical Guard-Rails: Non-commercial, educational, artistic filter only. No nude/minor content. Use according to local laws. Author is liability-free.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildImagePicker(
                    title: 'Source Face',
                    image: _sourceImage,
                    onTap: () => _pickImage(ImageSource.gallery, isSource: true),
                  ),
                  _buildImagePicker(
                    title: 'Target Image',
                    image: _targetImage,
                    onTap: () =>
                        _pickImage(ImageSource.gallery, isSource: false),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: (_sourceImage != null && _targetImage != null && !_isSwapping)
                    ? _swapFaces
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSwapping
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Swap Face'),
              ),
              const SizedBox(height: 20),
              if (_isSwapping)
                const Center(child: Text('Processing...')),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Result',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _buildResultImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(
      {required String title, File? image, required VoidCallback onTap}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildResultImage() {
    if (_isSwapping) {
      return const SizedBox(
        width: 250,
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_targetImage != null && !_isSwapping) {
      return Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(_targetImage!, fit: BoxFit.cover),
              ),
              if (_sourceImage != null)
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      image: DecorationImage(
                        image: FileImage(_sourceImage!),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Result will be shown here',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
  }
}
