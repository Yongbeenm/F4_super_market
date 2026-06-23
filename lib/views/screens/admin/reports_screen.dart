import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Reports Screen - Admin can view sales reports and analytics
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  
  // Analytics data
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  int _totalProducts = 0;
  int _totalCustomers = 0;
  double _averageOrderValue = 0.0;

  // Helper: format money to 2 decimal places always
  String _fmt(double value) => value.toStringAsFixed(2);
  
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _recentOrders = [];
  Map<String, int> _ordersByStatus = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      _totalCustomers = usersSnapshot.docs.length;

      // Get all products
      final productsSnapshot = await _firestore.collection('products').get();
      _totalProducts = productsSnapshot.docs.length;

      // Get all orders from all users
      List<Map<String, dynamic>> allOrders = [];
      Map<String, int> productSales = {}; // Track product sales count
      Map<String, double> productRevenue = {}; // Track product revenue
      Map<String, String> productNames = {}; // Store product names
      
      _ordersByStatus = {
        'pending': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (var userDoc in usersSnapshot.docs) {
        final ordersSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .get();

        for (var orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data();
          final userData = userDoc.data();
          
          // Add to all orders
          allOrders.add({
            ...orderData,
            'orderId': orderDoc.id,
            'userId': userDoc.id,
            'userName': userData['name'] ?? 'Unknown',
          });

          // Calculate revenue
          final total = (orderData['total'] ?? 0).toDouble();
          _totalRevenue += total;

          // Count orders by status
          final status = orderData['status'] ?? 'pending';
          _ordersByStatus[status] = (_ordersByStatus[status] ?? 0) + 1;

          // Track product sales
          final items = orderData['items'] as List<dynamic>? ?? [];
          for (var item in items) {
            final productId = item['productId'] ?? '';
            final productName = item['productName'] ?? 'Unknown';
            final quantity = (item['quantity'] ?? 0) as int;
            final price = (item['price'] ?? 0).toDouble();
            
            if (productId.isNotEmpty) {
              productSales[productId] = (productSales[productId] ?? 0) + quantity;
              productRevenue[productId] = (productRevenue[productId] ?? 0.0) + (price * quantity);
              productNames[productId] = productName;
            }
          }
        }
      }

      _totalOrders = allOrders.length;
      _averageOrderValue = double.parse(
        (_totalOrders > 0 ? _totalRevenue / _totalOrders : 0.0)
            .toStringAsFixed(2),
      );
      _totalRevenue = double.parse(_totalRevenue.toStringAsFixed(2));

      // Get top 5 products by sales count
      final sortedProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      _topProducts = sortedProducts.take(5).map((entry) {
        return {
          'productId': entry.key,
          'productName': productNames[entry.key] ?? 'Unknown',
          'salesCount': entry.value,
          'revenue': productRevenue[entry.key] ?? 0.0,
        };
      }).toList();

      // Get recent 5 orders
      _recentOrders = allOrders.take(5).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
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
                  // Overview Cards
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          'Total Revenue',
                          '\$${_fmt(_totalRevenue)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewCard(
                          'Total Orders',
                          _totalOrders.toString(),
                          Icons.shopping_bag,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          'Avg Order Value',
                          '\$${_fmt(_averageOrderValue)}',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOverviewCard(
                          'Customers',
                          _totalCustomers.toString(),
                          Icons.people,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Orders by Status
                  const Text(
                    'Orders by Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      children: [
                        _buildStatusRow('Pending', _ordersByStatus['pending'] ?? 0, Colors.orange),
                        const Divider(),
                        _buildStatusRow('Processing', _ordersByStatus['processing'] ?? 0, Colors.blue),
                        const Divider(),
                        _buildStatusRow('Shipped', _ordersByStatus['shipped'] ?? 0, Colors.purple),
                        const Divider(),
                        _buildStatusRow('Delivered', _ordersByStatus['delivered'] ?? 0, Colors.green),
                        const Divider(),
                        _buildStatusRow('Cancelled', _ordersByStatus['cancelled'] ?? 0, Colors.red),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top Products
                  const Text(
                    'Top Selling Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_topProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No sales data yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...(_topProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getRankColor(index),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['productName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D5C3D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product['salesCount']} sold',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${_fmt((product['revenue'] as double))}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()),

                  const SizedBox(height: 24),

                  // Recent Orders
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_recentOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...(_recentOrders.map((order) {
                      final userName = order['userName'] ?? 'Unknown';
                      final total = (order['total'] ?? 0).toDouble();
                      final status = order['status'] ?? 'pending';
                      final createdAt = order['createdAt'] as Timestamp?;

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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D5C3D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    createdAt != null
                                        ? DateFormat('MMM dd, yyyy - hh:mm a')
                                            .format(createdAt.toDate())
                                        : 'Unknown date',
                                    style: TextStyle(
                                      fontSize: 11,
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
                                  '\$${_fmt(total)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList()),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D5C3D),
                ),
              ),
            ],
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return const Color(0xFF0D5C3D);
    }
  }
}
