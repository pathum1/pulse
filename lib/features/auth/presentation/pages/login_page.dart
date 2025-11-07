import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../shared/widgets/loading_screen.dart';

/// Login Page
/// Handles user authentication with Google Sign-In and email/password
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseService.instance.signInWithGoogle();
      
      if (userCredential != null) {
        // Successfully signed in
        context.go('/checkin');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        // Create new account
        await FirebaseService.instance.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Sign in existing user
        await FirebaseService.instance.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      
      // Successfully authenticated
      context.go('/checkin');
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorCode = error.toString();
    
    if (errorCode.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (errorCode.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorCode.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    } else if (errorCode.contains('weak-password')) {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (errorCode.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (errorCode.contains('network-request-failed')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorCode.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (_isSignUp && value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return LoadingScreen(
        message: _isSignUp ? 'Creating account...' : 'Signing in...',
      );
    }
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.darkBackground 
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // App logo and title
              _buildHeader(isDark),
              
              const SizedBox(height: 48),
              
              // Error message
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 24),
              ],
              
              // Google Sign-In button
              _buildGoogleSignInButton(),
              
              const SizedBox(height: 24),
              
              // Divider
              _buildDivider(isDark),
              
              const SizedBox(height: 24),
              
              // Email/Password form
              _buildEmailForm(),
              
              const SizedBox(height: 24),
              
              // Sign in/Sign up button
              _buildSubmitButton(),
              
              const SizedBox(height: 16),
              
              // Toggle sign in/sign up
              _buildToggleButton(isDark),
              
              const SizedBox(height: 32),
              
              // Help text
              _buildHelpText(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // App logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surgicalTeal,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.surgicalTeal.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services,
            size: 40,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App title
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark 
                ? AppColors.darkPrimaryText 
                : AppColors.lightPrimaryText,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          _isSignUp ? 'Create your account' : 'Sign in to continue',
          style: TextStyle(
            fontSize: 16,
            color: isDark 
                ? AppColors.darkSecondaryText 
                : AppColors.lightSecondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightError.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.lightError,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.lightError,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _signInWithGoogle,
        icon: Image.asset(
          'assets/images/google_logo.png', // You'll need to add this asset
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.login, size: 24);
          },
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark 
                ? AppColors.darkDivider 
                : AppColors.lightDivider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              color: isDark 
                  ? AppColors.darkSecondaryText 
                  : AppColors.lightSecondaryText,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark 
                ? AppColors.darkDivider 
                : AppColors.lightDivider,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your hospital email',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            onFieldSubmitted: (_) => _signInWithEmail(),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: _isSignUp ? 'Create a strong password' : 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _signInWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surgicalTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isSignUp ? 'Create Account' : 'Sign In',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool isDark) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isSignUp = !_isSignUp;
          _errorMessage = null;
        });
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: isDark 
                ? AppColors.darkSecondaryText 
                : AppColors.lightSecondaryText,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: _isSignUp 
                  ? 'Already have an account? ' 
                  : 'Don\'t have an account? ',
            ),
            TextSpan(
              text: _isSignUp ? 'Sign In' : 'Sign Up',
              style: const TextStyle(
                color: AppColors.surgicalTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText(bool isDark) {
    return Text(
      'For hospital staff only. Contact your IT administrator if you need access.',
      style: TextStyle(
        fontSize: 12,
        color: isDark 
            ? AppColors.darkSecondaryText 
            : AppColors.lightSecondaryText,
      ),
      textAlign: TextAlign.center,
    );
  }
}