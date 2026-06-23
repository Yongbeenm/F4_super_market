import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_service.dart';
import '../orders/orders_screen.dart';
import '../address/addresses_screen.dart';
import '../admin/admin_panel_screen.dart';
import '../payment/payment_methods_screen.dart';
import '../settings/settings_screen.dart';
import '../support/help_support_screen.dart';
import 'feedback_screen.dart';

/// Profile Screen with iOS-style animations
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _authService = AuthService();
  final _adminService = AdminService();
  final _firestore = FirebaseFirestore.instance;
  
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final email = userDoc.data()?['email'] ?? '';
          final isAdmin = await _adminService.isAdmin(email);
          setState(() {
            _userName = userDoc.data()?['name'] ?? 'User';
            _userEmail = email;
            _isAdmin = isAdmin;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Header with Animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Profile Picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        // Add golden border for admin users
                        border: _isAdmin
                            ? Border.all(
                                color: Colors.amber,
                                width: 3,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF0D5C3D),
                            ),
                          ),
                          // Admin badge
                          if (_isAdmin)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D5C3D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    // Admin badge
                    if (_isAdmin) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.admin_panel_settings,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Menu Items with Staggered Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Admin Panel (only for admin users)
                      if (_isAdmin)
                        _buildMenuItem(
                          icon: Icons.admin_panel_settings,
                          title: 'Admin Panel',
                          subtitle: 'Manage products and categories',
                          delay: 0.05,
                          isAdmin: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminPanelScreen(),
                              ),
                            );
                          },
                        ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag,
                        title: 'My Orders',
                        subtitle: 'View your order history',
                        delay: 0.1,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrdersScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite,
                        title: 'Wishlist',
                        subtitle: 'Your favorite items',
                        delay: 0.2,
                        onTap: () {
                          Navigator.pushNamed(context, '/wishlist');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on,
                        title: 'Delivery Address',
                        subtitle: 'Manage your addresses',
                        delay: 0.3,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.payment,
                        title: 'Payment Methods',
                        subtitle: 'Manage payment options',
                        delay: 0.4,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentMethodsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Manage notifications',
                        delay: 0.5,
                        onTap: () => _showComingSoon('Notifications'),
                      ),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App preferences',
                        delay: 0.6,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.feedback,
                        title: 'Feedback',
                        subtitle: 'Share your thoughts',
                        delay: 0.65,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedbackScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help,
                        title: 'Help & Support',
                        subtitle: 'Get help',
                        delay: 0.7,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        delay: 0.8,
                        isLogout: true,
                        onTap: _handleLogout,
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double delay,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isAdmin = false,
  }) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay,
          (delay + 0.2).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isAdmin
                ? Border.all(color: Colors.amber, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isLogout
                            ? Colors.red.withOpacity(0.1)
                            : isAdmin
                                ? Colors.amber.withOpacity(0.2)
                                : const Color(0xFFB8E6D5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isLogout
                            ? Colors.red
                            : isAdmin
                                ? Colors.amber.shade700
                                : const Color(0xFF0D5C3D),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLogout
                                  ? Colors.red
                                  : isAdmin
                                      ? Colors.amber.shade700
                                      : const Color(0xFF0D5C3D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8E6D5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF0D5C3D),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Coming Soon'),
              ],
            ),
            content: Text(
              '$feature feature is coming soon!',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.pop(context);
                      // Navigate to root and remove all routes
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/first',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error logging out: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}
