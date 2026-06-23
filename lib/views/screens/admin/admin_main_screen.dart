import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_service.dart';
import '../../../utils/app_theme.dart';
import 'manage_products_screen.dart';
import 'manage_categories_screen.dart';
import 'view_all_orders_screen.dart';
import 'view_users_screen.dart';
import 'reports_screen.dart';

/// Admin Main Screen - Separate interface for admin users
/// Admins are sellers, not buyers - they manage the store
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final _authService = AuthService();
  final _adminService = AdminService();
  final _firestore = FirebaseFirestore.instance;
  
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  
  int _totalProducts = 0;
  int _totalCategories = 0;
  int _totalOrders = 0;
  int _totalUsers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'] ?? 'Admin';
            _userEmail = userDoc.data()?['email'] ?? '';
          });
        }
      }
      
      // Load statistics
      await _loadStatistics();
    } catch (e) {
      print('Error loading admin data: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      // Count products
      final productsSnapshot = await _firestore.collection('products').get();
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final usersSnapshot = await _firestore.collection('users').get();
      
      // Count all orders from all users
      int totalOrders = 0;
      for (var userDoc in usersSnapshot.docs) {
        final ordersSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('orders')
            .get();
        totalOrders += ordersSnapshot.docs.length;
      }
      
      setState(() {
        _totalProducts = productsSnapshot.docs.length;
        _totalCategories = categoriesSnapshot.docs.length;
        _totalUsers = usersSnapshot.docs.length;
        _totalOrders = totalOrders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryGreen,
                          AppTheme.primaryGreenLight,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceLarge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppTheme.primaryGreen,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spaceMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userEmail,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadStatistics();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: _handleLogout,
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Section
                      Text(
                        'Store Overview',
                        style: AppTheme.heading2.copyWith(
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMedium),
                      
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        )
                      else
                        GlassContainer(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernStatCard(
                                      'Products',
                                      _totalProducts.toString(),
                                      Icons.inventory_2_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceMedium),
                                  Expanded(
                                    child: _buildModernStatCard(
                                      'Categories',
                                      _totalCategories.toString(),
                                      Icons.category_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMedium),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernStatCard(
                                      'Orders',
                                      _totalOrders.toString(),
                                      Icons.shopping_bag_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceMedium),
                                  Expanded(
                                    child: _buildModernStatCard(
                                      'Users',
                                      _totalUsers.toString(),
                                      Icons.people_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: AppTheme.spaceLarge),
                      
                      // Management Section
                      Text(
                        'Management',
                        style: AppTheme.heading2.copyWith(
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMedium),
                      
                      _buildModernActionCard(
                        'Manage Products',
                        'Add, edit, or remove products',
                        Icons.inventory_2_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageProductsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSmall),
                      _buildModernActionCard(
                        'Manage Categories',
                        'Add, edit, or remove categories',
                        Icons.category_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCategoriesScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSmall),
                      _buildModernActionCard(
                        'View All Orders',
                        'See and manage customer orders',
                        Icons.receipt_long_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewAllOrdersScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSmall),
                      _buildModernActionCard(
                        'View Users',
                        'See all registered users',
                        Icons.people_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewUsersScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSmall),
                      _buildModernActionCard(
                        'Reports & Analytics',
                        'View sales reports and analytics',
                        Icons.analytics_rounded,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 32,
          ),
          const SizedBox(height: AppTheme.spaceSmall),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textMedium,
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  Navigator.pushReplacementNamed(context, '/login');
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
  }
}
