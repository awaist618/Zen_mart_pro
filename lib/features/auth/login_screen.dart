import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      // GoRouter redirect logic handles navigation
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Forgot Password?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we will send you a link to reset your password.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;
              try {
                await ref.read(authServiceProvider).sendPasswordResetEmail(emailController.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset link sent! Check your email.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Base
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logo & Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/images/image.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue your journey',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Glassmorphic Form Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: AppColors.accent.withOpacity(0.8)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer Link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                            children: [
                              const TextSpan(text: 'New here? '),
                              TextSpan(
                                text: 'Create Customer Account',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
