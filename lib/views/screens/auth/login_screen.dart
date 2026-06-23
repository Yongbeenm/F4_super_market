import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/admin_service.dart';
import '../../../utils/app_theme.dart';

/// Modern Login Screen with Gradient Background and Animations
/// Features: Animated logo, glassmorphism cards, gradient buttons
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _adminService = AdminService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Logo animation
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Form animation
    _formAnimationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationSlow,
    );
    
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animations
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Sign in with Firebase Auth (supports offline)
        final result = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        setState(() => _isLoading = false);
        
        if (mounted) {
          // Check if user is admin
          final email = _emailController.text.trim();
          final isAdmin = await _adminService.isAdmin(email);
          
          // Show success message with offline indicator
          final message = result['isOffline'] == true
              ? 'Login successful! (Offline mode)'
              : 'Login successful!';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: result['isOffline'] == true 
                  ? Colors.orange 
                  : Colors.green,
            ),
          );
          
          // Navigate to appropriate screen based on user role
          if (isAdmin) {
            // Admin goes to admin dashboard
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            // Regular user goes to main screen
            Navigator.pushReplacementNamed(context, '/main');
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      // Sign in with Google
      final userCredential = await _authService.signInWithGoogle();
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        // Check if user is admin
        final email = userCredential.user?.email ?? '';
        final isAdmin = await _adminService.isAdmin(email);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in with Google successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to appropriate screen based on user role
        if (isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value,
                          child: Hero(
                            tag: 'f4_logo',
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                boxShadow: AppTheme.buttonShadow,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated Form
                  FadeTransition(
                    opacity: _formFadeAnimation,
                    child: SlideTransition(
                      position: _formSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          ShaderMask(
                            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                            child: const Text(
                              'Welcome Back! 👋',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Sign in to continue',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textMedium,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Email Field
                          ModernTextField(
                            controller: _emailController,
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppTheme.spaceMedium),
                          
                          // Password Field
                          ModernTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_rounded,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: AppTheme.primaryGreen,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Login Button
                          ModernButton(
                            text: 'Login',
                            onPressed: _handleLogin,
                            isLoading: _isLoading,
                            icon: Icons.login_rounded,
                          ),
                          
                          const SizedBox(height: AppTheme.spaceLarge),
                          
                          // OR Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppTheme.textMedium),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textMedium,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppTheme.textMedium),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppTheme.spaceLarge),
                          
                          // Google Sign-In Button
                          SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryGreen,
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: AppTheme.primaryGreen,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                              ),
                              icon: Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                height: 24,
                                width: 24,
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppTheme.spaceLarge),
                          
                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, '/register');
                                },
                                child: ShaderMask(
                                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
