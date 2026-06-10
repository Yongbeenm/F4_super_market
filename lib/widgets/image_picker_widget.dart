import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

/// Enhanced Image Picker Widget
/// Supports: Gallery, Camera, URL input with preview
class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String imageUrl) onImageSelected;
  final String uploadFolder;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.uploadFolder = 'products',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final TextEditingController _urlController = TextEditingController();
  
  String? _imageUrl;
  File? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _hasNewImage = false; // Track if user selected a new image

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
    _urlController.text = widget.initialImageUrl ?? '';
    // If there's an initial image, notify parent immediately
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      widget.onImageSelected(_imageUrl!);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _hasNewImage = true; // Mark as new image
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _hasNewImage = true; // Mark as new image
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final downloadUrl = await _storageService.uploadImage(
        _imageFile!,
        widget.uploadFolder,
        fileName: fileName,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _imageUrl = downloadUrl;
        _urlController.text = downloadUrl;
        _isUploading = false;
        _imageFile = null;
      });

      widget.onImageSelected(downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showError('Failed to upload image: $e');
    }
  }

  void _useUrlImage() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter an image URL');
      return;
    }

    if (!_isValidUrl(url)) {
      _showError('Please enter a valid URL');
      return;
    }

    setState(() {
      _imageUrl = url;
      _hasNewImage = true; // Mark as new image
    });

    widget.onImageSelected(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image URL set successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0D5C3D)),
              title: const Text('Gallery'),
              subtitle: const Text('Pick from your photos'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D5C3D)),
              title: const Text('Camera'),
              subtitle: const Text('Take a new photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Color(0xFF0D5C3D)),
              title: const Text('URL'),
              subtitle: const Text('Enter image URL'),
              onTap: () {
                Navigator.pop(context);
                _showUrlInputDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Enter Image URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tip: You can paste URLs from Unsplash, Imgur, or any image hosting service',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _useUrlImage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Use URL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Preview
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFB8E6D5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _isUploading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      color: const Color(0xFF0D5C3D),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Uploading... ${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFF0D5C3D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _imageUrl != null && _imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF0D5C3D),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
        ),
        
        const SizedBox(height: 12),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _showImageSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Choose Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D5C3D),
                  side: const BorderSide(color: Color(0xFF0D5C3D)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _imageUrl = null;
                    _urlController.clear();
                    _hasNewImage = true; // Mark as changed (removed)
                  });
                  widget.onImageSelected('');
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remove image',
              ),
            ],
          ],
        ),
      ],
    );
  }
}
