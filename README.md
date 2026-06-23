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

