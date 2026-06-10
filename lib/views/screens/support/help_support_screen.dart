import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Help & Support Screen
/// Provides help resources and contact support
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D5C3D),
                    Color(0xFF1A8A5C),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is here to help you',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactButton(
                        context,
                        'Email',
                        Icons.email,
                        () => _showContactInfo(context, 'Email', 'support@f4supermarket.com'),
                      ),
                      _buildContactButton(
                        context,
                        'Phone',
                        Icons.phone,
                        () => _showContactInfo(context, 'Phone', '+1 (555) 123-4567'),
                      ),
                      _buildContactButton(
                        context,
                        'Chat',
                        Icons.chat,
                        () => _showComingSoon(context, 'Live Chat'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFAQItem(
              context,
              'How do I place an order?',
              'Browse products, add items to your cart, and proceed to checkout. Enter your delivery address and payment method to complete your order.',
            ),
            _buildFAQItem(
              context,
              'What payment methods do you accept?',
              'We accept Cash on Delivery, Credit/Debit Cards (Visa, Mastercard, American Express), and Mobile Payments (Apple Pay, Google Pay).',
            ),
            _buildFAQItem(
              context,
              'How can I track my order?',
              'Go to Profile → My Orders to view all your orders and their current status. You\'ll receive notifications when your order status changes.',
            ),
            _buildFAQItem(
              context,
              'What is your return policy?',
              'We offer a 7-day return policy for most items. Products must be in original condition. Contact support to initiate a return.',
            ),
            _buildFAQItem(
              context,
              'How do I cancel an order?',
              'You can cancel an order from the Order Details screen if it hasn\'t been shipped yet. Once shipped, please contact support.',
            ),
            _buildFAQItem(
              context,
              'Do you offer delivery?',
              'Yes! We deliver to your doorstep. Delivery fees and times vary by location. You can see delivery options at checkout.',
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              'Report a Problem',
              Icons.report_problem,
              Colors.orange,
              () => _showReportDialog(context),
            ),
            _buildActionCard(
              context,
              'Give Feedback',
              Icons.feedback,
              Colors.blue,
              () => _showFeedbackDialog(context),
            ),
            _buildActionCard(
              context,
              'Terms & Conditions',
              Icons.description,
              Colors.purple,
              () => _showTerms(context),
            ),
            _buildActionCard(
              context,
              'Privacy Policy',
              Icons.privacy_tip,
              Colors.green,
              () => _showPrivacyPolicy(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF0D5C3D), size: 28),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D5C3D),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D5C3D),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showContactInfo(BuildContext context, String type, String info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Contact via $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              info,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C3D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to copy',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: info));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  backgroundColor: Color(0xFF0D5C3D),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available soon!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Report a Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you\'re experiencing:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the problem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted. We\'ll get back to you soon!'),
                  backgroundColor: Color(0xFF0D5C3D),
                ),
              );
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

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Give Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We\'d love to hear your thoughts!'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Your feedback...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Color(0xFF0D5C3D),
                ),
              );
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

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms & Conditions\n\n'
            '1. Acceptance of Terms\n'
            'By using F4 Supermarket app, you agree to these terms.\n\n'
            '2. User Account\n'
            'You are responsible for maintaining account security.\n\n'
            '3. Orders & Payment\n'
            'All orders are subject to availability and confirmation.\n\n'
            '4. Delivery\n'
            'Delivery times are estimates and may vary.\n\n'
            '5. Returns\n'
            '7-day return policy for most items in original condition.\n\n'
            '6. Privacy\n'
            'We protect your personal information. See Privacy Policy.\n\n'
            'Last updated: May 26, 2026',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            '1. Information We Collect\n'
            'We collect information you provide when creating an account and placing orders.\n\n'
            '2. How We Use Your Information\n'
            '- Process your orders\n'
            '- Improve our services\n'
            '- Send order updates\n'
            '- Provide customer support\n\n'
            '3. Information Sharing\n'
            'We do not sell your personal information to third parties.\n\n'
            '4. Data Security\n'
            'We use industry-standard security measures to protect your data.\n\n'
            '5. Your Rights\n'
            'You can access, update, or delete your personal information.\n\n'
            '6. Contact Us\n'
            'For privacy concerns, contact: privacy@f4supermarket.com\n\n'
            'Last updated: May 26, 2026',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
