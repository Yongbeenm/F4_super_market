import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notification_service.dart';

/// Feedback Screen - Users can submit feedback
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedType = 'general';
  int _rating = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _feedbackTypes = [
    {'value': 'general', 'label': 'General Feedback', 'icon': Icons.feedback},
    {'value': 'complaint', 'label': 'Complaint', 'icon': Icons.warning},
    {'value': 'suggestion', 'label': 'Suggestion', 'icon': Icons.lightbulb},
    {'value': 'bug', 'label': 'Bug Report', 'icon': Icons.bug_report},
    {'value': 'compliment', 'label': 'Compliment', 'icon': Icons.thumb_up},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Create feedback document
      final feedbackData = {
        'userId': user.uid,
        'userEmail': user.email ?? 'Unknown',
        'userName': userData['name'] ?? 'Unknown User',
        'type': _selectedType,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'rating': _rating,
        'status': 'pending', // pending, reviewed, resolved
        'createdAt': FieldValue.serverTimestamp(),
        'resolvedAt': null,
        'adminResponse': null,
      };

      // Save to Firestore
      await _firestore.collection('feedback').add(feedbackData);

      // Send notification to admin (local notification for now)
      await NotificationService().showFeedbackNotification(
        userName: userData['name'] ?? 'Unknown User',
        feedbackType: _selectedType,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        // Clear form
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _rating = 0;
          _selectedType = 'general';
          _isSubmitting = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback has been submitted.'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
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
        title: const Text('Send Feedback'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D5C3D), Color(0xFF1A8B5A)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.feedback, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'We Value Your Feedback!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Help us improve by sharing your thoughts, suggestions, or reporting issues.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Feedback Type
            const Text(
              'Feedback Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedbackTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = type['value'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D5C3D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0D5C3D) : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF0D5C3D),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          type['label'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : const Color(0xFF0D5C3D),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Rating (optional)
            const Text(
              'Rate Your Experience (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Subject
            const Text(
              'Subject (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'Brief summary of your feedback',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Message
            const Text(
              'Your Feedback *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Please share your thoughts, suggestions, or issues in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Center(
              child: Text(
                'We typically respond within 24-48 hours',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
