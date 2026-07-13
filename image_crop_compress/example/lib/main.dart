import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_crop_compress/image_crop_compress.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Processor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final ImagePicker _picker = ImagePicker();
  ProcessedImage? _processedImage;
  File? _originalFile;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _originalFile = File(image.path);
        _processedImage = null; // Reset
      });
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openInteractiveEditor() {
    if (_originalFile == null) return;
    
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageEditor(
        image: _originalFile!,
        onComplete: (result) {
          setState(() {
            _processedImage = result;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Success: ${result.extension.toUpperCase()} - ${result.sizeInBytes / 1024} KB')),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  Future<void> _processImage(void Function(ImageProcessor) applyOperations) async {
    final source = _processedImage?.file ?? _originalFile;
    if (source == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final processor = ImageProcessor(source);
      applyOperations(processor);
      final result = await processor.save();
      
      setState(() {
        _processedImage = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success: ${result.extension.toUpperCase()} - ${result.sizeInBytes / 1024} KB')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayFile = _processedImage?.file ?? _originalFile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Processor'),
        actions: [
          if (_originalFile != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset to original',
              onPressed: () {
                setState(() {
                  _processedImage = null;
                });
              },
            )
        ],
      ),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              Expanded(
                child: Center(
                  child: displayFile == null
                      ? const Text('No image selected.')
                      : InteractiveViewer(
                          child: Image.file(displayFile),
                        ),
                ),
              ),
              if (_processedImage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Size: ${(_processedImage!.sizeInBytes / 1024).toStringAsFixed(2)} KB'),
                      Text('Dimensions: ${_processedImage!.width} x ${_processedImage!.height}'),
                      Text('Format: ${_processedImage!.mimeType}'),
                    ],
                  ),
                ),
            ],
          ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (displayFile != null) ...[
            FloatingActionButton(
              heroTag: 'edit_fab',
              onPressed: _openInteractiveEditor,
              tooltip: 'Edit Image',
              child: const Icon(Icons.edit),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            heroTag: 'pick_fab',
            onPressed: _showImageSourceBottomSheet,
            tooltip: 'Pick Image',
            child: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
    );
  }
}
