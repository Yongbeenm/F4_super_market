import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/notification_service.dart';

/// Test Notification Screen
/// Test all notification features
class TestNotificationScreen extends StatefulWidget {
  const TestNotificationScreen({super.key});

  @override
  State<TestNotificationScreen> createState() => _TestNotificationScreenState();
}

class _TestNotificationScreenState extends State<TestNotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  String? _fcmToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    setState(() {
      _isLoading = true;
    });

    final token = await _notificationService.getToken();
    setState(() {
      _fcmToken = token;
      _isLoading = false;
    });
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testOrderNotification(String status) async {
    await _notificationService.showOrderNotification(
      orderId: 'TEST${DateTime.now().millisecondsSinceEpoch}',
      status: status,
      total: 99.99,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$status notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testPromotionNotification() async {
    await _notificationService.showPromotionNotification(
      title: 'Flash Sale!',
      message: '50% off on all products! Limited time only!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promotion notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testCartReminder() async {
    await _notificationService.showCartReminder(itemCount: 5);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart reminder sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D5C3D),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FCM Token Section
                  _buildSectionTitle('FCM Token'),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your FCM Token:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D5C3D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8E6D5).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _fcmToken ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _copyToken,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Token'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D5C3D),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Notifications Section
                  _buildSectionTitle('Order Notifications'),
                  _buildNotificationButton(
                    icon: Icons.shopping_bag,
                    title: 'Order Placed',
                    color: Colors.blue,
                    onTap: () => _testOrderNotification('pending'),
                  ),
                  _buildNotificationButton(
                    icon: Icons.sync,
                    title: 'Order Processing',
                    color: Colors.orange,
                    onTap: () => _testOrderNotification('processing'),
                  ),
                  _buildNotificationButton(
                    icon: Icons.local_shipping,
                    title: 'Order Shipped',
                    color: Colors.purple,
                    onTap: () => _testOrderNotification('shipped'),
                  ),
                  _buildNotificationButton(
                    icon: Icons.check_circle,
                    title: 'Order Delivered',
                    color: Colors.green,
                    onTap: () => _testOrderNotification('delivered'),
                  ),
                  _buildNotificationButton(
                    icon: Icons.cancel,
                    title: 'Order Cancelled',
                    color: Colors.red,
                    onTap: () => _testOrderNotification('cancelled'),
                  ),

                  const SizedBox(height: 24),

                  // Other Notifications Section
                  _buildSectionTitle('Other Notifications'),
                  _buildNotificationButton(
                    icon: Icons.celebration,
                    title: 'Promotion Notification',
                    color: Colors.pink,
                    onTap: _testPromotionNotification,
                  ),
                  _buildNotificationButton(
                    icon: Icons.shopping_cart,
                    title: 'Cart Reminder',
                    color: Colors.teal,
                    onTap: _testCartReminder,
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How to Test',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoStep('1', 'Tap any button above to send a local notification'),
                        _buildInfoStep('2', 'Check the notification bar on your device'),
                        _buildInfoStep('3', 'Copy FCM token to test remote notifications'),
                        _buildInfoStep('4', 'Use Firebase Console or Postman to send push notifications'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D5C3D),
        ),
      ),
    );
  }

  Widget _buildNotificationButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
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
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D5C3D),
          ),
        ),
        trailing: const Icon(
          Icons.notifications_active,
          color: Color(0xFF0D5C3D),
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
