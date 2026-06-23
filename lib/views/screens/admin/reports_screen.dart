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
  
  // Date filter options
  String _selectedFilter = 'all'; // 'all', 'today', 'month', 'year'
  DateTime _selectedDate = DateTime.now();
  
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

  /// Check if order date matches the selected filter
  bool _matchesDateFilter(DateTime orderDate) {
    final now = _selectedDate;
    
    switch (_selectedFilter) {
      case 'today':
        return orderDate.year == now.year &&
               orderDate.month == now.month &&
               orderDate.day == now.day;
      
      case 'month':
        return orderDate.year == now.year &&
               orderDate.month == now.month;
      
      case 'year':
        return orderDate.year == now.year;
      
      case 'all':
      default:
        return true;
    }
  }

  /// Get filter label for display
  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'today':
        return 'Today (${DateFormat('MMM dd, yyyy').format(_selectedDate)})';
      case 'month':
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case 'year':
        return DateFormat('yyyy').format(_selectedDate);
      case 'all':
      default:
        return 'All Time';
    }
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
      List<Map<String, dynamic>> filteredOrders = [];
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
      
      // Reset totals
      _totalRevenue = 0.0;

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
          final createdAt = orderData['createdAt'] as Timestamp?;
          
          if (createdAt == null) continue;
          
          final orderDate = createdAt.toDate();
          
          // Add to all orders
          final orderInfo = {
            ...orderData,
            'orderId': orderDoc.id,
            'userId': userDoc.id,
            'userName': userData['name'] ?? 'Unknown',
          };
          
          allOrders.add(orderInfo);
          
          // Check if order matches date filter
          if (!_matchesDateFilter(orderDate)) continue;
          
          filteredOrders.add(orderInfo);

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

      _totalOrders = filteredOrders.length;
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

      // Get recent 5 orders from filtered results
      _recentOrders = filteredOrders.take(5).toList();

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

  /// Show date filter options
  Future<void> _showFilterOptions() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Filter Revenue Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5C3D),
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('All Time', 'all'),
              _buildFilterOption('Today', 'today'),
              _buildFilterOption('This Month', 'month'),
              _buildFilterOption('This Year', 'year'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (result != null && result != _selectedFilter) {
      setState(() {
        _selectedFilter = result;
        _selectedDate = DateTime.now(); // Reset to current date
      });
      await _loadAnalytics();
    }
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D5C3D).withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF0D5C3D) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0D5C3D) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to previous time period
  Future<void> _navigatePrevious() async {
    setState(() {
      switch (_selectedFilter) {
        case 'today':
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case 'month':
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
          break;
        case 'year':
          _selectedDate = DateTime(_selectedDate.year - 1);
          break;
      }
    });
    await _loadAnalytics();
  }

  /// Navigate to next time period
  Future<void> _navigateNext() async {
    final now = DateTime.now();
    setState(() {
      switch (_selectedFilter) {
        case 'today':
          final nextDay = _selectedDate.add(const Duration(days: 1));
          if (nextDay.isBefore(now) || nextDay.day == now.day) {
            _selectedDate = nextDay;
          }
          break;
        case 'month':
          final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
          if (nextMonth.isBefore(now) || 
              (nextMonth.year == now.year && nextMonth.month == now.month)) {
            _selectedDate = nextMonth;
          }
          break;
        case 'year':
          final nextYear = DateTime(_selectedDate.year + 1);
          if (nextYear.year <= now.year) {
            _selectedDate = nextYear;
          }
          break;
      }
    });
    await _loadAnalytics();
  }

  bool _canNavigateNext() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'today':
        return _selectedDate.year < now.year ||
               _selectedDate.month < now.month ||
               _selectedDate.day < now.day;
      case 'month':
        return _selectedDate.year < now.year ||
               (_selectedDate.year == now.year && _selectedDate.month < now.month);
      case 'year':
        return _selectedDate.year < now.year;
      default:
        return false;
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
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter by Date',
          ),
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
                  // Date Filter Display with Navigation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D5C3D), Color(0xFF1A8B5A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D5C3D).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Showing Revenue For:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: _showFilterOptions,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Change Filter',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous button
                            if (_selectedFilter != 'all')
                              IconButton(
                                onPressed: _navigatePrevious,
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                tooltip: 'Previous',
                              )
                            else
                              const SizedBox(width: 48),
                            
                            // Date display
                            Expanded(
                              child: Text(
                                _getFilterLabel(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            // Next button
                            if (_selectedFilter != 'all')
                              IconButton(
                                onPressed: _canNavigateNext() ? _navigateNext : null,
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: _canNavigateNext() ? Colors.white : Colors.white30,
                                ),
                                tooltip: 'Next',
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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
