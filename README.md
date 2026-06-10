# SmartMart E-Commerce Flutter Application

A comprehensive Flutter-based e-commerce mobile application for supermarket shopping with Firebase backend.

## Project Overview

SmartMart is a production-ready Flutter application implementing MVVM architecture with the following features:
- User authentication (email/password)
- Product catalog with categories
- Shopping cart with offline support
- Wishlist management
- Order processing and history
- Admin panel for product and order management
- Light/Dark theme support
- Responsive UI design

## Project Structure

```
lib/
├── models/              # Data models
│   ├── enums.dart
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── category_model.dart
│   ├── cart_item_model.dart
│   ├── order_model.dart
│   └── wishlist_model.dart
├── views/               # UI Layer
│   ├── screens/         # Full-page screens
│   └── widgets/         # Reusable widgets
├── viewmodels/          # Business logic & state management
├── repositories/        # Data access layer
├── services/            # Firebase & external services
└── utils/               # Constants, helpers, validators
    └── constants.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart 3.10.0 or higher
- Firebase account
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone and navigate to the project:**
   ```bash
   cd Super_Market_Ass
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable the following services:
      - Authentication (Email/Password)
      - Cloud Firestore
      - Firebase Storage
   
   c. Add Android app:
      - Package name: `com.smartmart.smartmart_app`
      - Download `google-services.json`
      - Place in `android/app/`
   
   d. Add iOS app:
      - Bundle ID: `com.smartmart.smartmartApp`
      - Download `GoogleService-Info.plist`
      - Place in `ios/Runner/`
   
   e. Install FlutterFire CLI:
      ```bash
      dart pub global activate flutterfire_cli
      ```
   
   f. Configure Firebase:
      ```bash
      flutterfire configure
      ```

4. **Set up Firestore Security Rules:**
   
   Go to Firebase Console > Firestore Database > Rules and add:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth.uid == userId;
       }
       
       // Products collection
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Categories collection
       match /categories/{categoryId} {
         allow read: if true;
         allow write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Carts collection
       match /carts/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
       
       // Orders collection
       match /orders/{orderId} {
         allow read: if request.auth != null && 
                       (resource.data.userId == request.auth.uid || 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
         allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
         allow update: if request.auth != null && 
                         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Wishlist collection
       match /wishlist/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
     }
   }
   ```

5. **Set up Firebase Storage Rules:**
   
   Go to Firebase Console > Storage > Rules and add:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // Profile images
       match /profile_images/{userId}/{allPaths=**} {
         allow read: if true;
         allow write: if request.auth.uid == userId;
       }
       
       // Product images
       match /product_images/{allPaths=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

6. **Create Firestore Indexes:**
   
   Go to Firebase Console > Firestore Database > Indexes and create:
   - Collection: `products`, Fields: `categoryId` (Ascending), `createdAt` (Descending)
   - Collection: `products`, Fields: `isAvailable` (Ascending), `createdAt` (Descending)
   - Collection: `orders`, Fields: `userId` (Ascending), `createdAt` (Descending)
   - Collection: `orders`, Fields: `status` (Ascending), `createdAt` (Descending)

7. **Run the app:**
   ```bash
   flutter run
   ```

## Implementation Status

### ✅ Completed
- Project setup and configuration
- Folder structure (MVVM architecture)
- Dependencies installation
- Data models (User, Product, Category, Cart, Order, Wishlist)
- Constants and utilities
- Enums (UserRole, OrderStatus, PaymentMethod, LoadingState)

### 🚧 To Be Implemented

The following components need to be implemented based on the design document:

1. **Services Layer** (`lib/services/`)
   - `auth_service.dart` - Firebase Authentication
   - `firestore_service.dart` - Firestore operations
   - `storage_service.dart` - Firebase Storage
   - `database_helper.dart` - SQLite local database

2. **Repositories Layer** (`lib/repositories/`)
   - `user_repository.dart`
   - `product_repository.dart`
   - `category_repository.dart`
   - `cart_repository.dart`
   - `order_repository.dart`
   - `wishlist_repository.dart`

3. **ViewModels/Providers** (`lib/viewmodels/`)
   - `auth_provider.dart`
   - `product_provider.dart`
   - `category_provider.dart`
   - `cart_provider.dart`
   - `wishlist_provider.dart`
   - `order_provider.dart`
   - `theme_provider.dart`
   - `admin_provider.dart`

4. **Screens** (`lib/views/screens/`)
   - Authentication: `splash_screen.dart`, `login_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`
   - Main: `home_screen.dart`, `category_list_screen.dart`, `category_products_screen.dart`
   - Product: `product_detail_screen.dart`
   - Cart & Checkout: `cart_screen.dart`, `checkout_screen.dart`, `order_confirmation_screen.dart`
   - Orders: `order_history_screen.dart`, `order_detail_screen.dart`
   - Profile: `profile_screen.dart`, `edit_profile_screen.dart`
   - Wishlist: `wishlist_screen.dart`
   - Admin: `admin_dashboard_screen.dart`, `manage_products_screen.dart`, `add_edit_product_screen.dart`, `manage_orders_screen.dart`

5. **Widgets** (`lib/views/widgets/`)
   - `custom_button.dart`
   - `custom_text_field.dart`
   - `product_card.dart`
   - `cart_item_card.dart`
   - `order_card.dart`
   - `loading_indicator.dart`
   - `empty_state.dart`
   - `error_display.dart`
   - `quantity_selector.dart`
   - `status_badge.dart`

6. **Utilities** (`lib/utils/`)
   - `validators.dart` - Form validation
   - `helpers.dart` - Helper functions
   - `image_helper.dart` - Image compression and handling
   - `connectivity_service.dart` - Network monitoring

7. **Navigation** (`lib/utils/`)
   - `router.dart` - GoRouter configuration

8. **Theme** (`lib/utils/`)
   - `theme.dart` - Material 3 theme configuration

9. **Main App** (`lib/`)
   - Update `main.dart` with Provider setup and app initialization

## Key Features to Implement

### Authentication
- Email/password registration and login
- Password reset functionality
- Session persistence
- Role-based access (customer/admin)

### Product Management
- Browse products by category
- Search products
- View product details
- Admin: Add/Edit/Delete products

### Shopping Cart
- Add/remove items
- Update quantities
- Offline support with SQLite
- Sync with Firestore when online

### Wishlist
- Add/remove products
- Move items to cart

### Orders
- Checkout process
- Order history
- Order status tracking
- Admin: Manage orders

### Theme
- Light/Dark mode toggle
- Material 3 design system
- Persistent theme preference

## Testing

Run tests with:
```bash
flutter test
```

## Build for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Architecture Details

### MVVM Pattern
- **Models**: Data structures and business entities
- **Views**: UI components (Screens and Widgets)
- **ViewModels**: Business logic and state management using Provider

### Data Flow
1. View triggers action → ViewModel
2. ViewModel calls Repository
3. Repository interacts with Service (Firebase/SQLite)
4. Service returns data → Repository → ViewModel
5. ViewModel updates state → View rebuilds

### State Management
- Provider for dependency injection and state management
- ChangeNotifier for reactive state updates
- Separate providers for each domain (Auth, Products, Cart, etc.)

## Performance Considerations

- Pagination: 20 items per page
- Image caching with `cached_network_image`
- Search debouncing: 500ms
- Firestore query caching: 5 minutes
- Lazy loading for images
- Proper disposal of controllers and listeners

## Responsive Design

- 2-column grid on phones (< 600dp)
- 3-column grid on tablets (≥ 600dp)
- Minimum touch target: 48dp
- Flexible spacing and padding

## Security

- Firestore security rules enforce data access
- Storage rules protect file uploads
- Input validation on all forms
- Secure password requirements (min 8 characters)

## Contributing

1. Follow the existing code structure
2. Use meaningful variable and function names
3. Add comments for complex logic
4. Write tests for new features
5. Follow Flutter/Dart style guide

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)

## License

This project is for educational purposes.

## Support

For issues and questions, refer to the spec files in `.kiro/specs/smartmart-ecommerce-app/`:
- `requirements.md` - Detailed requirements
- `design.md` - Architecture and design decisions
- `tasks.md` - Implementation tasks breakdown
