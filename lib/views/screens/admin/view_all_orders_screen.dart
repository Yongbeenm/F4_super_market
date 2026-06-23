import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/order_service.dart';

/// View All Orders Screen - Admin can see all customer orders
class ViewAllOrdersScreen extends StatefulWidget {
  const ViewAllOrdersScreen({super.key});

  @override
  State<ViewAllOrdersScreen> createState() => _ViewAllOrdersScreenState();
}

class _ViewAllOrdersScreenState extends State<ViewAllOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderService _orderService = OrderService();
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('All Orders'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedStatus,
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Orders')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'processing', child: Text('Processing')),
              const PopupMenuItem(value: 'shipped', child: Text('Shipped')),
              const PopupMenuItem(value: 'delivered', child: Text('Delivered')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          if (usersSnapshot.hasError) {
            return Center(child: Text('Error: ${usersSnapshot.error}'));
          }

          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D5C3D)),
            );
          }

          final users = usersSnapshot.data?.docs ?? [];
          
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getAllOrders(users),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D5C3D)),
                );
              }

              if (ordersSnapshot.hasError) {
                return Center(child: Text('Error: ${ordersSnapshot.error}'));
              }

              var orders = ordersSnapshot.data ?? [];
              
              // Filter by status
              if (_selectedStatus != 'all') {
                orders = orders.where((order) => order['status'] == _selectedStatus).toList();
              }

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(order);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getAllOrders(List<QueryDocumentSnapshot> users) async {
    List<Map<String, dynamic>> allOrders = [];
    
    for (var userDoc in users) {
      final ordersSnapshot = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      
      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final userData = userDoc.data() as Map<String, dynamic>;
        
        allOrders.add({
          ...orderData,
          'orderId': orderDoc.id,
          'userId': userDoc.id,
          'userName': userData['name'] ?? 'Unknown',
          'userEmail': userData['email'] ?? 'Unknown',
        });
      }
    }
    
    // Sort by date
    allOrders.sort((a, b) {
      final aTime = a['createdAt'] as Timestamp?;
      final bTime = b['createdAt'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    
    return allOrders;
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['orderId'] ?? '';
    final userId = order['userId'] ?? '';
    final userName = order['userName'] ?? 'Unknown';
    final userEmail = order['userEmail'] ?? '';
    final total = (order['total'] ?? 0).toDouble();
    final status = order['status'] ?? 'pending';
    final createdAt = order['createdAt'] as Timestamp?;
    final items = order['items'] as List<dynamic>? ?? [];

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
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
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
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
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            createdAt != null
                ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt.toDate())
                : 'Unknown date',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D5C3D),
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item['productName']} x${item['quantity']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                const Text(
                  'Delivery Address:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D5C3D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['deliveryAddress'] ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Phone: ${order['phoneNumber'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateOrderStatus(userId, orderId, status),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D5C3D),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Update Status'),
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

  void _updateOrderStatus(String userId, String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        String newStatus = currentStatus;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Update Order Status'),
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
                  title: const Text('Processing'),
                  value: 'processing',
                  groupValue: newStatus,
                  onChanged: (value) => setState(() => newStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Shipped'),
                  value: 'shipped',
                  groupValue: newStatus,
                  onChanged: (value) => setState(() => newStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Delivered'),
                  value: 'delivered',
                  groupValue: newStatus,
                  onChanged: (value) => setState(() => newStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Cancelled'),
                  value: 'cancelled',
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
                    // Use OrderService to update status with notification
                    await _orderService.updateOrderStatus(userId, orderId, newStatus);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order status updated! Customer notified.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      setState(() {}); // Refresh the list
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
}
