import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../services/api_service.dart';
import '../widgets/image_placeholder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _sourceImage;
  File? _targetImage;
  Uint8List? _resultImage;
  bool _isSwapping = false;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source, {required bool isSource}) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isSource) {
          _sourceImage = File(pickedFile.path);
        } else {
          _targetImage = File(pickedFile.path);
        }
        _resultImage = null;
      });
    }
  }

  void _swapFaces() async {
    if (_sourceImage != null && _targetImage != null) {
      setState(() {
        _isSwapping = true;
        _resultImage = null;
      });

      try {
        final result = await _apiService.swapFaces(_sourceImage!, _targetImage!);
        setState(() {
          _resultImage = result;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to swap faces: $e')),
        );
      } finally {
        setState(() {
          _isSwapping = false;
        });
      }
    }
  }

  void _clearImages() {
    setState(() {
      _sourceImage = null;
      _targetImage = null;
      _resultImage = null;
    });
  }

  Future<void> _downloadImage() async {
    if (_resultImage == null) return;

    try {
      if (identical(0, 0.0)) { // Check if running on web
        final blob = html.Blob([_resultImage]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "swapped_image.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/swapped_image.png';
        final file = File(filePath);
        await file.writeAsBytes(_resultImage!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $filePath')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ethical Guard-Rails: Non-commercial, educational, artistic filter only. No nude/minor content. Use according to local laws. Author is liability-free.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePicker(
                    title: 'Source Face',
                    image: _sourceImage,
                    onTap: () => _pickImage(ImageSource.gallery, isSource: true),
                  ),
                  _buildImagePicker(
                    title: 'Target Image',
                    image: _targetImage,
                    onTap: () => _pickImage(ImageSource.gallery, isSource: false),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: (_sourceImage != null && _targetImage != null && !_isSwapping) ? _swapFaces : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSwapping ? const SizedBox.shrink() : const Icon(Icons.swap_horiz),
                label: _isSwapping
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Swap Face', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              if (_resultImage != null)
                Column(
                  children: [
                    const Divider(height: 40),
                    const Text('Result', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ImagePlaceholder(
                      child: Image.memory(_resultImage!, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _downloadImage,
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                        const SizedBox(width: 20),
                        TextButton.icon(
                          onPressed: _clearImages,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({required String title, File? image, required VoidCallback onTap}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ImagePlaceholder(
          onTap: onTap,
          child: image != null
              ? Image.file(image, fit: BoxFit.cover)
              : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
        ),
      ],
    );
  }
}
