import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Firebase Authentication Service
/// Handles user authentication operations with offline support and Google Sign-In
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ==================== Getters ====================

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== Offline Support ====================

  /// Save credentials for offline login
  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    await prefs.setString('cached_email', email);
    await prefs.setString('cached_password', hashedPassword);
    await prefs.setBool('has_logged_in', true);
  }

  /// Check if credentials match cached ones (for offline login)
  Future<bool> _verifyOfflineCredentials(
      String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedEmail = prefs.getString('cached_email');
    final cachedPassword = prefs.getString('cached_password');
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    return cachedEmail == email && cachedPassword == hashedPassword;
  }

  /// Check if user has logged in before
  Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_logged_in') ?? false;
  }

  /// Get cached user ID
  Future<String?> getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cached_user_id');
  }

  /// Save user ID for offline access
  Future<void> _saveCachedUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_id', userId);
  }

  // ==================== Authentication Methods ====================

  /// Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save credentials for offline login
      await _saveCredentials(email, password);
      await _saveCachedUserId(credential.user!.uid);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Sign in with email and password (with offline support)
  /// Supports multiple devices - Firebase Auth allows concurrent sessions by default
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // Try online login first
      // Note: Firebase Auth allows the same account to be logged in on multiple devices
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save credentials for offline login on THIS device
      await _saveCredentials(email, password);
      await _saveCachedUserId(credential.user!.uid);
      
      return {
        'success': true,
        'userId': credential.user!.uid,
        'isOffline': false,
      };
    } on FirebaseAuthException catch (e) {
      // Don't try offline login for authentication errors (wrong password, invalid credentials, etc.)
      // These errors mean the credentials are actually wrong, not a network issue
      final authErrors = [
        'wrong-password',
        'user-not-found',
        'invalid-credential',
        'invalid-email',
        'user-disabled',
        'too-many-requests',
      ];
      
      if (authErrors.contains(e.code)) {
        // These are real authentication errors - don't fall back to offline mode
        throw _handleAuthException(e);
      }
      
      // Only try offline login for network-related errors
      if (e.code == 'network-request-failed') {
        final hasLoggedIn = await hasLoggedInBefore();
        if (hasLoggedIn) {
          final isValid = await _verifyOfflineCredentials(email, password);
          if (isValid) {
            final userId = await getCachedUserId();
            return {
              'success': true,
              'userId': userId,
              'isOffline': true,
            };
          }
        }
      }
      
      // For other errors, throw the Firebase error
      throw _handleAuthException(e);
    } catch (e) {
      // Only try offline login if this is truly a network/connectivity issue
      // and the user has logged in on this device before
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        final hasLoggedIn = await hasLoggedInBefore();
        if (hasLoggedIn) {
          final isValid = await _verifyOfflineCredentials(email, password);
          if (isValid) {
            final userId = await getCachedUserId();
            return {
              'success': true,
              'userId': userId,
              'isOffline': true,
            };
          }
        }
      }
      
      // Re-throw the original error if offline login is not applicable
      throw 'Login failed: $e';
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign-in was cancelled';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Save user ID for offline access
      if (userCredential.user != null) {
        await _saveCachedUserId(userCredential.user!.uid);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email: $e';
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Failed to send verification email: $e';
    }
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Failed to reload user: $e';
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to update email: $e';
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to update password: $e';
    }
  }

  /// Re-authenticate user with credentials
  Future<void> reauthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to re-authenticate: $e';
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account: $e';
    }
  }

  // ==================== Error Handling ====================

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'weak-password':
        return 'Password should be at least 8 characters long.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please verify your login information.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}
