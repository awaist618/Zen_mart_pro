import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../core/providers.dart';
import '../../core/secrets.dart';
import '../../theme/app_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _generatedOtp;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    // Validate email before sending OTP
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email format')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // 1. Generate a random 6-digit OTP
    final random = Random();
    _generatedOtp = (100000 + random.nextInt(900000)).toString();

    // 2. Configure Gmail SMTP
    final smtpServer = gmail(AppSecrets.smtpEmail, AppSecrets.smtpPassword);

    // 3. Create the Premium HTML Email
    final message = Message()
      ..from = const Address(AppSecrets.smtpEmail, 'Zen Mart Pro')
      ..recipients.add(_emailController.text.trim())
      ..subject = 'Verify Your Account - Zen Mart Pro'
      ..html = '''
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #0F172A; padding: 40px; color: #FFFFFF; text-align: center;">
          <div style="max-width: 500px; margin: auto; background: #1E293B; border-radius: 24px; border: 1px solid rgba(255,255,255,0.1); overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
            <div style="padding: 40px;">
              <h1 style="margin: 0; font-size: 28px; color: #06B6D4; letter-spacing: 1px;">Zen Mart Pro</h1>
              <div style="height: 1px; background: rgba(255,255,255,0.1); margin: 24px 0;"></div>
              <p style="color: rgba(255,255,255,0.7); font-size: 18px; margin-bottom: 8px;">Verify Your Identity</p>
              <p style="color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 32px;">Please use the following code to complete your registration.</p>
              
              <div style="background: rgba(255,255,255,0.05); padding: 24px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.1); display: inline-block; min-width: 200px;">
                <span style="font-size: 42px; font-weight: 800; letter-spacing: 8px; color: #FFFFFF; font-family: monospace;">$_generatedOtp</span>
              </div>
              
              <p style="color: rgba(255,255,255,0.4); font-size: 13px; margin-top: 32px; line-height: 1.5;">
                This code is valid for 10 minutes.<br>
                If you did not request this code, please ignore this email.
              </p>
            </div>
            <div style="background: rgba(0,0,0,0.2); padding: 20px;">
              <p style="margin: 0; font-size: 11px; color: rgba(255,255,255,0.3); letter-spacing: 2px; text-transform: uppercase;">
                Powered by Zenvyro Labs X Awais
              </p>
            </div>
          </div>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _verifyAndSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Check if OTP matches
    if (_otpController.text.trim() != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please check and try again.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Proceed with Signup
    try {
      await ref.read(authServiceProvider).signUpCustomer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // GoRouter redirect logic handles navigation
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (Same as Welcome Screen)
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
                    const SizedBox(height: 24),
                    Text(
                      'Join Zen Mart Pro',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to start your premium shopping journey.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                    ),
                    const SizedBox(height: 32),

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
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter your name';
                                  if (v.length < 3) return 'Name too short';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !_isOtpSent,
                                validator: (v) {
                                  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (v == null || v.isEmpty) return 'Enter email';
                                  if (!regex.hasMatch(v)) return 'Invalid email format';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter phone number';
                                  if (v.length < 10) return 'Invalid phone number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter password';
                                  if (v.length < 8) return 'Password must be 8+ characters';
                                  if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add at least one uppercase letter';
                                  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add at least one number';
                                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Add one special character';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                icon: Icons.lock_reset,
                                isPassword: true,
                                validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                              ),
                              
                              if (_isOtpSent) ...[
                                const SizedBox(height: 24),
                                const Divider(color: Colors.white12),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _otpController,
                                  label: 'Enter 6-Digit OTP',
                                  icon: Icons.verified_user_outlined,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 14, color: Colors.white.withOpacity(0.5)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "Didn't see it? Please check your Spam or Junk folder.",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 32),
                              
                              // Action Button
                              ElevatedButton(
                                onPressed: _isLoading 
                                    ? null 
                                    : (_isOtpSent ? _verifyAndSignup : _sendOtp),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text(
                                        _isOtpSent ? 'Verify & Create Account' : 'Send OTP to Email',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/login'),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Login',
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
    int? maxLength,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        counterText: "",
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
