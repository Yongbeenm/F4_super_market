import 'package:flutter/material.dart';
import '../../../utils/upload_sample_data_to_firebase.dart';

/// Data Upload Screen
/// Admin screen to upload sample data to Firebase
class DataUploadScreen extends StatefulWidget {
  const DataUploadScreen({super.key});

  @override
  State<DataUploadScreen> createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> {
  bool _isUploading = false;
  String _statusMessage = '';

  Future<void> _uploadData() async {
    setState(() {
      _isUploading = true;
      _statusMessage = 'Uploading data to Firebase...';
    });

    try {
      final uploader = UploadSampleDataToFirebase();
      await uploader.uploadAll();
      
      setState(() {
        _isUploading = false;
        _statusMessage = '✅ Data uploaded successfully!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('Upload Sample Data'),
        backgroundColor: const Color(0xFFB8E6D5),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.cloud_upload,
                size: 80,
                color: Color(0xFF0D5C3D),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Upload Sample Data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5C3D),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'This will upload sample categories and products to your Firebase Firestore database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                '⚠️ Only do this once! Running multiple times will create duplicate data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 32),
              
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Upload Data to Firebase',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'What will be uploaded:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5C3D),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• 8 Categories (Fruits, Vegetables, etc.)'),
                    SizedBox(height: 4),
                    Text('• 30+ Products with images'),
                    SizedBox(height: 4),
                    Text('• Product details (name, price, description)'),
                    SizedBox(height: 4),
                    Text('• Category associations'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
