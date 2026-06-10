import 'package:flutter/material.dart';
import '../../../utils/upload_sample_data.dart';

/// Upload Data Screen
/// Admin screen to upload sample data to Firebase
class UploadDataScreen extends StatefulWidget {
  const UploadDataScreen({super.key});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, int>? _dataStats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await UploadSampleData.getDataStats();
      setState(() {
        _dataStats = stats;
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _uploadAll() async {
    // Check if data already exists
    final hasData = await UploadSampleData.hasExistingData();
    
    if (hasData && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Already Exists'),
          content: const Text(
            'Sample data already exists in the database. Do you want to add more data? This will create duplicates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Uploading sample data...';
    });

    try {
      await UploadSampleData.uploadAll();
      
      setState(() {
        _statusMessage = 'Sample data uploaded successfully!';
        _isLoading = false;
      });

      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample data uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all sample data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all data...';
    });

    try {
      await UploadSampleData.clearAll();
      
      setState(() {
        _statusMessage = 'All data cleared successfully!';
        _isLoading = false;
      });

      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data cleared!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upload Sample Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sample Data Upload',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This will upload sample categories, products, and users to your Firebase Firestore database.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sample data includes:\n'
                      '• 8 product categories\n'
                      '• 30+ products with images\n'
                      '• 2 sample customer accounts',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Database Stats Card
            if (_dataStats != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Database',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        '📦 Categories',
                        _dataStats!['categories']!,
                        theme,
                      ),
                      _buildStatRow(
                        '🛍️  Products',
                        _dataStats!['products']!,
                        theme,
                      ),
                      _buildStatRow(
                        '👥 Users',
                        _dataStats!['users']!,
                        theme,
                      ),
                      _buildStatRow(
                        '📋 Orders',
                        _dataStats!['orders']!,
                        theme,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Upload Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadAll,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isLoading ? 'Uploading...' : 'Upload Sample Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Clear Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearAll,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Clear All Data',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            const SizedBox(height: 12),

            // Refresh Stats Button
            TextButton.icon(
              onPressed: _isLoading ? null : _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Stats'),
            ),
            const SizedBox(height: 20),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('Error')
                    ? Colors.red[50]
                    : Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('Error')
                          ? Colors.red[900]
                          : Colors.green[900],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Warning Card
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange[900],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Important Notes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• This is for development/testing only\n'
                      '• Sample users have password: password123\n'
                      '• Admin users must be created manually\n'
                      '• Images are loaded from Unsplash URLs',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
