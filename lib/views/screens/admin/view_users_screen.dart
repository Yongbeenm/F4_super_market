import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/admin_service.dart';

/// View Users Screen - Admin can see all registered users
class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D5C3D),
              ),
            );
          }

          var users = snapshot.data?.docs ?? [];

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            users = users.where((user) {
              final data = user.data() as Map<String, dynamic>;
              final name = (data['name'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery) || email.contains(_searchQuery);
            }).toList();
          }

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? 'No users found' : 'No matching users',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>;
              return _buildUserCard(user.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? 'Unknown';
    final createdAt = data['createdAt'] as Timestamp?;

    return FutureBuilder<bool>(
      future: _adminService.isAdmin(email),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;

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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isAdmin ? Colors.amber.shade100 : const Color(0xFFB8E6D5),
                shape: BoxShape.circle,
                border: isAdmin ? Border.all(color: Colors.amber, width: 2) : null,
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin ? Colors.amber.shade700 : const Color(0xFF0D5C3D),
                size: 28,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                ),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Joined: ${DateFormat('MMM dd, yyyy').format(createdAt.toDate())}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getUserStats(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0D5C3D),
                        ),
                      );
                    }

                    final stats = snapshot.data ?? {};
                    final orderCount = stats['orderCount'] ?? 0;
                    final totalSpent = stats['totalSpent'] ?? 0.0;
                    final cartItems = stats['cartItems'] ?? 0;
                    final wishlistItems = stats['wishlistItems'] ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Statistics:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D5C3D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Orders',
                                orderCount.toString(),
                                Icons.shopping_bag,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                'Total Spent',
                                '\$${totalSpent.toStringAsFixed(2)}',
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Cart Items',
                                cartItems.toString(),
                                Icons.shopping_cart,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                'Wishlist',
                                wishlistItems.toString(),
                                Icons.favorite,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserStats(String userId) async {
    try {
      // Get order count and total spent
      final ordersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();
      
      int orderCount = ordersSnapshot.docs.length;
      double totalSpent = 0.0;
      
      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        totalSpent += (data['total'] ?? 0).toDouble();
      }

      // Get cart items count
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();
      
      int cartItems = cartSnapshot.docs.length;

      // Get wishlist items count
      final wishlistSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();
      
      int wishlistItems = wishlistSnapshot.docs.length;

      return {
        'orderCount': orderCount,
        'totalSpent': totalSpent,
        'cartItems': cartItems,
        'wishlistItems': wishlistItems,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }
}
