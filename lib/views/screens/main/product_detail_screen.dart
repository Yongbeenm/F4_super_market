import 'package:flutter/material.dart';
import '../../../services/cart_service.dart';
import '../../../services/wishlist_service.dart';

/// Product Detail Screen
/// Shows detailed information about a product with iOS-style animations
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();
  
  int _quantity = 1;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isLoadingWishlist = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final isInWishlist = await _wishlistService.isInWishlist(widget.product['id']);
    if (mounted) {
      setState(() {
        _isFavorite = isInWishlist;
        _isLoadingWishlist = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrls = widget.product['imageUrls'] as List<dynamic>? ?? [];
    final price = widget.product['price'] ?? 0.0;
    final stock = widget.product['stock'] ?? 0;
    final isAvailable = widget.product['isAvailable'] ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Images
                        _buildImageCarousel(imageUrls),

                        // Product Info
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name and Price
                              _buildNameAndPrice(theme, price),
                              const SizedBox(height: 12),

                              // Stock Status
                              _buildStockStatus(isAvailable, stock),
                              const SizedBox(height: 20),

                              // Description
                              _buildDescription(theme),
                              const SizedBox(height: 24),

                              // Quantity Selector
                              _buildQuantitySelector(theme),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Action Bar
      bottomSheet: _buildBottomActionBar(context, theme, price, isAvailable),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
          ),
          const Spacer(),
          // Favorite Button
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _isLoadingWishlist
                  ? null
                  : () async {
                      try {
                        final imageUrls = widget.product['imageUrls'] as List<dynamic>? ?? [];
                        final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
                        final price = (widget.product['price'] ?? 0.0) as num;
                        
                        final added = await _wishlistService.toggleWishlist(
                          productId: widget.product['id'],
                          productName: widget.product['name'],
                          price: price.toDouble(),
                          imageUrl: imageUrl,
                        );
                        
                        if (mounted) {
                          setState(() {
                            _isFavorite = added;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                added
                                    ? 'Added to wishlist'
                                    : 'Removed from wishlist',
                              ),
                              duration: const Duration(seconds: 1),
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: _isLoadingWishlist
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isFavorite ? Colors.red : Colors.black,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 80, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_${widget.product['name']}_$index',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 80),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (imageUrls.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imageUrls.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameAndPrice(ThemeData theme, double price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.product['name'] ?? 'Product',
            style: theme.textTheme.displaySmall,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatus(bool isAvailable, int stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isAvailable ? '$stock in stock' : 'Out of stock',
            style: TextStyle(
              color: isAvailable ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          widget.product['description'] ?? 'No description available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.remove, size: 24),
                  ),
                ),
              ),
              // Quantity Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_quantity',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              // Increase Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final stock = widget.product['stock'] ?? 0;
                    if (_quantity < stock) {
                      setState(() {
                        _quantity++;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.add, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    ThemeData theme,
    double price,
    bool isAvailable,
  ) {
    final totalPrice = price * _quantity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isAvailable
                    ? () async {
                        try {
                          final imageUrls = widget.product['imageUrls'] as List<dynamic>? ?? [];
                          final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
                          
                          await _cartService.addToCart(
                            productId: widget.product['id'],
                            productName: widget.product['name'],
                            price: price,
                            imageUrl: imageUrl,
                            quantity: _quantity,
                          );
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added $_quantity ${widget.product['name']} to cart',
                                ),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'VIEW CART',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Navigate to cart tab
                                    if (mounted) {
                                      final controller = DefaultTabController.of(context);
                                      controller.animateTo(2);
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
