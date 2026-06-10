/// Sample Data for F4 Supermarket
/// Contains realistic product data with images from Unsplash
class SampleData {
  // Sample Categories with Images
  static final List<Map<String, dynamic>> categories = [
    {
      'categoryId': 'cat_fruits',
      'name': 'Fruits',
      'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500',
      'displayOrder': 1,
    },
    {
      'categoryId': 'cat_vegetables',
      'name': 'Vegetables',
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
      'displayOrder': 2,
    },
    {
      'categoryId': 'cat_dairy',
      'name': 'Dairy',
      'imageUrl': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500',
      'displayOrder': 3,
    },
    {
      'categoryId': 'cat_bakery',
      'name': 'Bakery',
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500',
      'displayOrder': 4,
    },
    {
      'categoryId': 'cat_meat',
      'name': 'Meat & Seafood',
      'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
      'displayOrder': 5,
    },
    {
      'categoryId': 'cat_snacks',
      'name': 'Snacks',
      'imageUrl': 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=500',
      'displayOrder': 6,
    },
    {
      'categoryId': 'cat_beverages',
      'name': 'Beverages',
      'imageUrl': 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?w=500',
      'displayOrder': 7,
    },
    {
      'categoryId': 'cat_frozen',
      'name': 'Frozen Foods',
      'imageUrl': 'https://images.unsplash.com/photo-1476887334197-56adbf254e1a?w=500',
      'displayOrder': 8,
    },
  ];

  // Sample Products with Real Images
  static final List<Map<String, dynamic>> products = [
    // FRUITS
    {
      'name': 'Red Apples',
      'description': 'Fresh, crisp red apples. Perfect for snacking or baking. Rich in fiber and vitamin C.',
      'price': 2.99,
      'categoryId': 'cat_fruits',
      'imageUrls': [
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
        'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?w=500',
      ],
      'stock': 150,
      'isAvailable': true,
    },
    {
      'name': 'Bananas',
      'description': 'Ripe yellow bananas. Great source of potassium and energy. Perfect for smoothies.',
      'price': 1.99,
      'categoryId': 'cat_fruits',
      'imageUrls': [
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
      ],
      'stock': 200,
      'isAvailable': true,
    },
    {
      'name': 'Strawberries',
      'description': 'Sweet, juicy strawberries. Freshly picked. Perfect for desserts and breakfast.',
      'price': 4.99,
      'categoryId': 'cat_fruits',
      'imageUrls': [
        'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500',
      ],
      'stock': 80,
      'isAvailable': true,
    },
    {
      'name': 'Oranges',
      'description': 'Juicy navel oranges. High in vitamin C. Great for fresh juice.',
      'price': 3.49,
      'categoryId': 'cat_fruits',
      'imageUrls': [
        'https://images.unsplash.com/photo-1547514701-42782101795e?w=500',
      ],
      'stock': 120,
      'isAvailable': true,
    },
    {
      'name': 'Blueberries',
      'description': 'Fresh organic blueberries. Packed with antioxidants. Perfect for smoothies.',
      'price': 5.99,
      'categoryId': 'cat_fruits',
      'imageUrls': [
        'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=500',
      ],
      'stock': 60,
      'isAvailable': true,
    },
    {
      'name': 'Watermelon',
      'description': 'Sweet, refreshing watermelon. Perfect for summer. Seedless variety.',
      'price': 6.99,
      'categoryId': 'cat_fruits',
      'imageUrls': [
        'https://images.unsplash.com/photo-1587049352846-4a222e784422?w=500',
      ],
      'stock': 45,
      'isAvailable': true,
    },

    // VEGETABLES
    {
      'name': 'Broccoli',
      'description': 'Fresh green broccoli crowns. Rich in vitamins and minerals. Great for stir-fry.',
      'price': 2.49,
      'categoryId': 'cat_vegetables',
      'imageUrls': [
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=500',
      ],
      'stock': 90,
      'isAvailable': true,
    },
    {
      'name': 'Carrots',
      'description': 'Crunchy orange carrots. High in beta-carotene. Perfect for salads and cooking.',
      'price': 1.99,
      'categoryId': 'cat_vegetables',
      'imageUrls': [
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500',
      ],
      'stock': 150,
      'isAvailable': true,
    },
    {
      'name': 'Tomatoes',
      'description': 'Ripe red tomatoes. Vine-ripened for maximum flavor. Perfect for salads and sauces.',
      'price': 3.29,
      'categoryId': 'cat_vegetables',
      'imageUrls': [
        'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=500',
      ],
      'stock': 110,
      'isAvailable': true,
    },
    {
      'name': 'Lettuce',
      'description': 'Fresh crisp lettuce. Perfect for salads and sandwiches. Organic variety.',
      'price': 2.29,
      'categoryId': 'cat_vegetables',
      'imageUrls': [
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=500',
      ],
      'stock': 75,
      'isAvailable': true,
    },
    {
      'name': 'Bell Peppers',
      'description': 'Colorful bell peppers. Sweet and crunchy. Great for cooking and salads.',
      'price': 3.99,
      'categoryId': 'cat_vegetables',
      'imageUrls': [
        'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500',
      ],
      'stock': 85,
      'isAvailable': true,
    },

    // DAIRY
    {
      'name': 'Whole Milk',
      'description': 'Fresh whole milk. 1 gallon. Rich and creamy. Perfect for drinking and cooking.',
      'price': 4.99,
      'categoryId': 'cat_dairy',
      'imageUrls': [
        'https://images.unsplash.com/photo-1550583724-b2692b25a968?w=500',
      ],
      'stock': 200,
      'isAvailable': true,
    },
    {
      'name': 'Cheddar Cheese',
      'description': 'Sharp cheddar cheese. Aged for rich flavor. Perfect for sandwiches and cooking.',
      'price': 5.99,
      'categoryId': 'cat_dairy',
      'imageUrls': [
        'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=500',
      ],
      'stock': 120,
      'isAvailable': true,
    },
    {
      'name': 'Greek Yogurt',
      'description': 'Creamy Greek yogurt. High in protein. Perfect for breakfast and snacks.',
      'price': 3.99,
      'categoryId': 'cat_dairy',
      'imageUrls': [
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
      ],
      'stock': 150,
      'isAvailable': true,
    },
    {
      'name': 'Butter',
      'description': 'Unsalted butter. Made from fresh cream. Perfect for baking and cooking.',
      'price': 4.49,
      'categoryId': 'cat_dairy',
      'imageUrls': [
        'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500',
      ],
      'stock': 100,
      'isAvailable': true,
    },

    // BAKERY
    {
      'name': 'Whole Wheat Bread',
      'description': 'Fresh baked whole wheat bread. Soft and nutritious. Perfect for sandwiches.',
      'price': 3.49,
      'categoryId': 'cat_bakery',
      'imageUrls': [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500',
      ],
      'stock': 80,
      'isAvailable': true,
    },
    {
      'name': 'Croissants',
      'description': 'Buttery French croissants. Flaky and delicious. Perfect for breakfast.',
      'price': 4.99,
      'categoryId': 'cat_bakery',
      'imageUrls': [
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500',
      ],
      'stock': 60,
      'isAvailable': true,
    },
    {
      'name': 'Bagels',
      'description': 'Fresh plain bagels. Chewy and delicious. Perfect for breakfast sandwiches.',
      'price': 3.99,
      'categoryId': 'cat_bakery',
      'imageUrls': [
        'https://images.unsplash.com/photo-1551106652-a5bcf4b29ab6?w=500',
      ],
      'stock': 90,
      'isAvailable': true,
    },

    // MEAT & SEAFOOD
    {
      'name': 'Chicken Breast',
      'description': 'Fresh boneless chicken breast. Lean protein. Perfect for grilling and baking.',
      'price': 8.99,
      'categoryId': 'cat_meat',
      'imageUrls': [
        'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
      ],
      'stock': 70,
      'isAvailable': true,
    },
    {
      'name': 'Salmon Fillet',
      'description': 'Fresh Atlantic salmon. Rich in omega-3. Perfect for grilling and baking.',
      'price': 12.99,
      'categoryId': 'cat_meat',
      'imageUrls': [
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500',
      ],
      'stock': 50,
      'isAvailable': true,
    },
    {
      'name': 'Ground Beef',
      'description': 'Lean ground beef. 80/20 blend. Perfect for burgers and tacos.',
      'price': 7.99,
      'categoryId': 'cat_meat',
      'imageUrls': [
        'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=500',
      ],
      'stock': 85,
      'isAvailable': true,
    },

    // SNACKS
    {
      'name': 'Potato Chips',
      'description': 'Crispy potato chips. Classic salted flavor. Perfect for snacking.',
      'price': 2.99,
      'categoryId': 'cat_snacks',
      'imageUrls': [
        'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500',
      ],
      'stock': 150,
      'isAvailable': true,
    },
    {
      'name': 'Mixed Nuts',
      'description': 'Premium mixed nuts. Roasted and salted. Great source of protein.',
      'price': 6.99,
      'categoryId': 'cat_snacks',
      'imageUrls': [
        'https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73?w=500',
      ],
      'stock': 100,
      'isAvailable': true,
    },
    {
      'name': 'Chocolate Bar',
      'description': 'Premium dark chocolate. 70% cocoa. Rich and smooth.',
      'price': 3.49,
      'categoryId': 'cat_snacks',
      'imageUrls': [
        'https://images.unsplash.com/photo-1511381939415-e44015466834?w=500',
      ],
      'stock': 120,
      'isAvailable': true,
    },

    // BEVERAGES
    {
      'name': 'Orange Juice',
      'description': 'Fresh squeezed orange juice. No added sugar. 100% pure.',
      'price': 4.99,
      'categoryId': 'cat_beverages',
      'imageUrls': [
        'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=500',
      ],
      'stock': 90,
      'isAvailable': true,
    },
    {
      'name': 'Sparkling Water',
      'description': 'Refreshing sparkling water. Lemon flavored. Zero calories.',
      'price': 3.99,
      'categoryId': 'cat_beverages',
      'imageUrls': [
        'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=500',
      ],
      'stock': 130,
      'isAvailable': true,
    },
    {
      'name': 'Green Tea',
      'description': 'Premium green tea bags. Organic. Rich in antioxidants.',
      'price': 5.49,
      'categoryId': 'cat_beverages',
      'imageUrls': [
        'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=500',
      ],
      'stock': 80,
      'isAvailable': true,
    },

    // FROZEN FOODS
    {
      'name': 'Frozen Pizza',
      'description': 'Delicious frozen pizza. Pepperoni flavor. Ready in 15 minutes.',
      'price': 6.99,
      'categoryId': 'cat_frozen',
      'imageUrls': [
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
      ],
      'stock': 70,
      'isAvailable': true,
    },
    {
      'name': 'Ice Cream',
      'description': 'Premium vanilla ice cream. Creamy and delicious. 1 quart.',
      'price': 5.99,
      'categoryId': 'cat_frozen',
      'imageUrls': [
        'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=500',
      ],
      'stock': 95,
      'isAvailable': true,
    },
    {
      'name': 'Frozen Vegetables',
      'description': 'Mixed frozen vegetables. Broccoli, carrots, and peas. Ready to cook.',
      'price': 3.99,
      'categoryId': 'cat_frozen',
      'imageUrls': [
        'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=500',
      ],
      'stock': 110,
      'isAvailable': true,
    },
  ];

  // Sample Users
  static final List<Map<String, dynamic>> users = [
    {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phoneNumber': '+1234567890',
      'role': 'customer',
    },
    {
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'phoneNumber': '+1234567891',
      'role': 'customer',
    },
    {
      'name': 'Admin User',
      'email': 'admin@f4supermarket.com',
      'phoneNumber': '+1234567892',
      'role': 'admin',
    },
  ];

  // Sample Orders
  static final List<Map<String, dynamic>> orders = [
    {
      'items': [
        {
          'productName': 'Red Apples',
          'price': 2.99,
          'quantity': 3,
        },
        {
          'productName': 'Whole Milk',
          'price': 4.99,
          'quantity': 1,
        },
      ],
      'totalAmount': 13.96,
      'status': 'delivered',
      'paymentMethod': 'card',
      'deliveryAddress': {
        'street': '123 Main St',
        'city': 'New York',
        'state': 'NY',
        'zipCode': '10001',
        'country': 'USA',
      },
    },
  ];
}
