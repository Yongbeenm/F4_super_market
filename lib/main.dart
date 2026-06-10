import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'views/screens/auth/auth_wrapper.dart';
import 'views/screens/auth/first_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/register_screen.dart';
import 'views/screens/main/main_screen.dart';
import 'views/screens/main/wishlist_screen.dart';
import 'views/screens/admin/data_upload_screen.dart';
import 'views/screens/admin/admin_main_screen.dart';
import 'views/screens/test_connection_screen.dart';
import 'services/notification_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📬 Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();
  
  runApp(const F4SupermarketApp());
}

class F4SupermarketApp extends StatelessWidget {
  const F4SupermarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F4 Supermarket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryGreen,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // Use AuthWrapper to check login state
      routes: {
        '/first': (context) => const FirstScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/admin': (context) => const AdminMainScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/data-upload': (context) => const DataUploadScreen(),
        '/test': (context) => const TestConnectionScreen(),
      },
    );
  }
}
