import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

/// Test screen to verify Firebase connection
/// This demonstrates that backend (Firebase) and frontend (Flutter) are connected
class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _status = 'Ready to test connection';
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firebase connection...';
    });

    try {
      // Test Firestore connection by fetching categories
      final categoriesSnapshot = await _firestoreService.getCollection('categories');
      _categories = categoriesSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Test Firestore connection by fetching products
      final productsSnapshot = await _firestoreService.getCollection('products');
      _products = productsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      setState(() {
        _isLoading = false;
        _status = 'Connection successful! ✅';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Connection failed: $e';
      });
    }
  }

  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _status = 'Adding sample data...';
    });

    try {
      // Add sample categories
      await _firestoreService.setDocument('categories', 'cat_fruits', {
        'categoryId': 'cat_fruits',
        'name': 'Fruits',
        'imageUrl': 'https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73?w=500',
        'displayOrder': 1,
      });

      await _firestoreService.setDocument('categories', 'cat_vegetables', {
        'categoryId': 'cat_vegetables',
        'name': 'Vegetables',
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
        'displayOrder': 2,
      });

      await _firestoreService.setDocument('categories', 'cat_dairy', {
        'categoryId': 'cat_dairy',
        'name': 'Dairy',
        'imageUrl': 'https://images.unsplash.com/photo-1628840042765-356cda07f4ee?w=500',
        'displayOrder': 3,
      });

      // Add sample products
      await _firestoreService.createDocument('products', {
        'name': 'Red Apple',
        'description': 'Fresh red apples from the farm',
        'price': 2.99,
        'categoryId': 'cat_fruits',
        'imageUrls': ['https://images.unsplash.com/photo-1560806887-1295db8edd8e?w=500'],
        'stock': 50,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });

      await _firestoreService.createDocument('products', {
        'name': 'Banana',
        'description': 'Yellow ripe bananas',
        'price': 1.99,
        'categoryId': 'cat_fruits',
        'imageUrls': ['https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=500'],
        'stock': 75,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });

      await _firestoreService.createDocument('products', {
        'name': 'Broccoli',
        'description': 'Fresh green broccoli',
        'price': 3.49,
        'categoryId': 'cat_vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1584622614875-e51df1bdc82f?w=500'],
        'stock': 30,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });

      await _firestoreService.createDocument('products', {
        'name': 'Milk',
        'description': 'Fresh whole milk',
        'price': 4.99,
        'categoryId': 'cat_dairy',
        'imageUrls': ['https://images.unsplash.com/photo-1550583724-b2692b25a968?w=500'],
        'stock': 100,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _status = 'Sample data added successfully! ✅';
      });

      // Refresh data
      await _testConnection();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Failed to add sample data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase Connection'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        _status.contains('successful') || _status.contains('✅')
                            ? Icons.check_circle
                            : _status.contains('failed')
                                ? Icons.error
                                : Icons.info,
                        size: 48,
                        color: _status.contains('successful') || _status.contains('✅')
                            ? Colors.green
                            : _status.contains('failed')
                                ? Colors.red
                                : Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Auth Status
              Card(
                child: ListTile(
                  leading: Icon(
                    _authService.isAuthenticated ? Icons.check_circle : Icons.cancel,
                    color: _authService.isAuthenticated ? Colors.green : Colors.orange,
                  ),
                  title: const Text('Authentication'),
                  subtitle: Text(
                    _authService.isAuthenticated
                        ? 'Signed in as: ${_authService.currentUser?.email ?? "Unknown"}'
                        : 'Not signed in (Guest mode)',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categories Section
              Text(
                'Categories (${_categories.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_categories.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('No categories found'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _addSampleData,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Sample Data'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._categories.map((category) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(category['name'] ?? 'Unknown'),
                        subtitle: Text('ID: ${category['categoryId']}'),
                        trailing: Text('Order: ${category['displayOrder']}'),
                      ),
                    )),
              const SizedBox(height: 16),

              // Products Section
              Text(
                'Products (${_products.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_products.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No products found'),
                      ],
                    ),
                  ),
                )
              else
                ..._products.map((product) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: Text(product['name'] ?? 'Unknown'),
                        subtitle: Text(product['description'] ?? ''),
                        trailing: Text('\$${product['price']?.toStringAsFixed(2) ?? '0.00'}'),
                      ),
                    )),
              const SizedBox(height: 16),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
              const SizedBox(height: 8),
              if (_categories.isNotEmpty || _products.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
