import 'package:flutter/material.dart';

// App Constants
class AppConstants {
  static const String appName = 'SmartMart';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int productsPerPage = 20;
  static const int searchDebounceMs = 500;
  
  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);
  
  // Timeouts
  static const Duration firestoreTimeout = Duration(seconds: 10);
  static const Duration authTimeout = Duration(seconds: 5);
  
  // Image
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;
  
  // Tax Rate
  static const double taxRate = 0.10; // 10%
  
  // Validation
  static const int minPasswordLength = 8;
  static const int minPhoneLength = 10;
}

// App Colors
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
}

// App Text Styles
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

// App Dimensions
class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Margin
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 24.0;
  static const double marginXL = 32.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusCircle = 999.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  
  // Touch Target
  static const double minTouchTarget = 48.0;
  
  // Grid
  static const int gridColumnsSmall = 2;
  static const int gridColumnsLarge = 3;
  static const double gridSpacing = 16.0;
  
  // Breakpoints
  static const double breakpointTablet = 600.0;
  static const double breakpointDesktop = 1200.0;
}

// Asset Paths
class AssetPaths {
  static const String images = 'assets/images/';
  static const String icons = 'assets/icons/';
  
  // Placeholder Images
  static const String placeholderProduct = '${images}placeholder_product.png';
  static const String placeholderProfile = '${images}placeholder_profile.png';
  static const String emptyCart = '${images}empty_cart.png';
  static const String emptyWishlist = '${images}empty_wishlist.png';
  static const String emptyOrders = '${images}empty_orders.png';
  static const String logo = '${images}logo.png';
}

// Firebase Collection Names
class FirebaseCollections {
  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String carts = 'carts';
  static const String orders = 'orders';
  static const String wishlist = 'wishlist';
}

// Shared Preferences Keys
class PrefsKeys {
  static const String theme = 'theme';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String rememberMe = 'remember_me';
}

// Route Names
class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String categoryProducts = '/categories/:categoryId';
  static const String productDetail = '/product/:productId';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation/:orderId';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:orderId';
  static const String adminDashboard = '/admin';
  static const String manageProducts = '/admin/products';
  static const String addProduct = '/admin/products/add';
  static const String editProduct = '/admin/products/edit/:productId';
  static const String manageOrders = '/admin/orders';
}
