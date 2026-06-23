import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// View Feedback Screen - Admin can see and respond to user feedback
class ViewFeedbackScreen extends StatefulWidget {
  const ViewFeedbackScreen({super.key});

  @override
  State<ViewFeedbackScreen> createState() => _ViewFeedbackScreenState();
}

class _ViewFeedbackScreenState extends State<ViewFeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all'; // all, pending, reviewed, resolved
  String _selectedType = 'all'; // all, general, complaint, suggestion, bug, compliment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('User Feedback'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedFilter,
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Status')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'reviewed', child: Text('Reviewed')),
              const PopupMenuItem(value: 'resolved', child: Text('Resolved')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Type Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All Types', Icons.all_inclusive),
                  _buildFilterChip('general', 'General', Icons.feedback),
                  _buildFilterChip('complaint', 'Complaints', Icons.warning),
                  _buildFilterChip('suggestion', 'Suggestions', Icons.lightbulb),
                  _buildFilterChip('bug', 'Bugs', Icons.bug_report),
                  _buildFilterChip('compliment', 'Compliments', Icons.thumb_up),
                ],
              ),
            ),
          ),

          // Feedback List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('feedback')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D5C3D)),
                  );
                }

                var feedbacks = snapshot.data?.docs ?? [];

                // Apply filters
                if (_selectedFilter != 'all') {
                  feedbacks = feedbacks
                      .where((doc) => doc['status'] == _selectedFilter)
                      .toList();
                }

                if (_selectedType != 'all') {
                  feedbacks = feedbacks
                      .where((doc) => doc['type'] == _selectedType)
                      .toList();
                }

                if (feedbacks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feedback_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback found',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    final data = feedback.data() as Map<String, dynamic>;
                    return _buildFeedbackCard(feedback.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF0D5C3D)),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = value;
          });
        },
        selectedColor: const Color(0xFF0D5C3D),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF0D5C3D),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(String feedbackId, Map<String, dynamic> data) {
    final type = data['type'] ?? 'general';
    final status = data['status'] ?? 'pending';
    final userName = data['userName'] ?? 'Unknown';
    final userEmail = data['userEmail'] ?? '';
    final subject = data['subject'] ?? 'No subject';
    final message = data['message'] ?? '';
    final rating = data['rating'] ?? 0;
    final createdAt = data['createdAt'] as Timestamp?;

    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case 'complaint':
        typeColor = Colors.red;
        typeIcon = Icons.warning;
        break;
      case 'suggestion':
        typeColor = Colors.blue;
        typeIcon = Icons.lightbulb;
        break;
      case 'bug':
        typeColor = Colors.orange;
        typeIcon = Icons.bug_report;
        break;
      case 'compliment':
        typeColor = Colors.green;
        typeIcon = Icons.thumb_up;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.feedback;
    }

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'reviewed':
        statusColor = Colors.blue;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(typeIcon, color: typeColor, size: 24),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subject,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rating > 0)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              const SizedBox(height: 4),
              Text(
                createdAt != null
                    ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt.toDate())
                    : 'Unknown date',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                const Text(
                  'Contact:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D5C3D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Message
                const Text(
                  'Message:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D5C3D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Admin Response
                if (data['adminResponse'] != null) ...[
                  const Text(
                    'Admin Response:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      data['adminResponse'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(feedbackId, status),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Update Status'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D5C3D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _addResponse(feedbackId, data),
                        icon: const Icon(Icons.reply),
                        label: const Text('Respond'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D5C3D),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String feedbackId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String newStatus = currentStatus;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Update Feedback Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Pending'),
                  value: 'pending',
                  groupValue: newStatus,
                  onChanged: (value) => setState(() => newStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Reviewed'),
                  value: 'reviewed',
                  groupValue: newStatus,
                  onChanged: (value) => setState(() => newStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Resolved'),
                  value: 'resolved',
                  groupValue: newStatus,
                  onChanged: (value) => setState(() => newStatus = value!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _firestore.collection('feedback').doc(feedbackId).update({
                      'status': newStatus,
                      if (newStatus == 'resolved')
                        'resolvedAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addResponse(String feedbackId, Map<String, dynamic> data) {
    final responseController = TextEditingController(
      text: data['adminResponse'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Admin Response'),
        content: TextField(
          controller: responseController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Type your response here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a response'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await _firestore.collection('feedback').doc(feedbackId).update({
                  'adminResponse': responseController.text.trim(),
                  'status': 'reviewed',
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
