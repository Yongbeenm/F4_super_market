import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_service.dart';
import 'first_screen.dart';
import '../main/main_screen.dart';
import '../admin/admin_main_screen.dart';

/// Authentication Wrapper
/// Checks if user is already logged in and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  final AdminService _adminService = const AdminService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFB8E6D5),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo or Icon
                  Icon(
                    Icons.shopping_cart,
                    size: 80,
                    color: Color(0xFF0D5C3D),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'F4 Supermarket',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                  SizedBox(height: 32),
                  CircularProgressIndicator(
                    color: Color(0xFF0D5C3D),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Check if user is admin
          return FutureBuilder<bool>(
            future: _adminService.isAdmin(user.email ?? ''),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFB8E6D5),
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0D5C3D),
                    ),
                  ),
                );
              }
              
              final isAdmin = adminSnapshot.data ?? false;
              if (isAdmin) {
                return const AdminMainScreen();
              } else {
                return const MainScreen();
              }
            },
          );
        }

        // User not logged in, show first screen
        return const FirstScreen();
      },
    );
  }
}
