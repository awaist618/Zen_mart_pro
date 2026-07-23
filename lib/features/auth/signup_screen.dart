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
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email'), backgroundColor: AppColors.error));
      return;
    }
    
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email format'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);
    final random = Random();
    _generatedOtp = (100000 + random.nextInt(900000)).toString();

    final smtpServer = gmail(AppSecrets.smtpEmail, AppSecrets.smtpPassword);
    final message = Message()
      ..from = const Address(AppSecrets.smtpEmail, 'Zen Mart Pro')
      ..recipients.add(email)
      ..subject = 'Verify Your Account - Zen Mart Pro'
      ..html = '''
        <div style="font-family: sans-serif; background-color: #232733; padding: 40px; color: #FFFFFF; text-align: center;">
          <div style="max-width: 500px; margin: auto; background: #31384B; border-radius: 24px; padding: 40px; border: 1px solid rgba(255,255,255,0.05);">
            <h1 style="margin: 0; font-size: 24px; color: #C9A27E;">Zen Mart Pro</h1>
            <p style="color: #C5CBD8; font-size: 16px; margin: 20px 0;">Use the code below to verify your account</p>
            <div style="background: #232733; padding: 20px; border-radius: 12px; display: inline-block;">
              <span style="font-size: 32px; font-weight: 800; letter-spacing: 5px; color: #FFFFFF;">$_generatedOtp</span>
            </div>
            <p style="color: #6B7280; font-size: 12px; margin-top: 30px;">Valid for 10 minutes.</p>
          </div>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      setState(() { _isLoading = false; _isOtpSent = true; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to email'), backgroundColor: AppColors.success));
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _verifyAndSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error));
      return;
    }
    if (_otpController.text.trim() != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signUpCustomer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [colorScheme.primary.withValues(alpha: isLight ? 0.08 : 0.05), Colors.transparent]),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        side: isLight ? BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)) : null,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Join Zen Mart Pro',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your premium shopping journey today',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 48),

                    _buildField(_nameController, 'Full Name', Icons.person_rounded),
                    const SizedBox(height: 16),
                    _buildField(_emailController, 'Email Address', Icons.email_rounded, enabled: !_isOtpSent, type: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildField(_phoneController, 'Phone Number', Icons.phone_rounded, type: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildField(_passwordController, 'Password', Icons.lock_rounded, isPassword: true),
                    const SizedBox(height: 16),
                    _buildField(_confirmPasswordController, 'Confirm Password', Icons.lock_reset_rounded, isPassword: true),
                    
                    if (_isOtpSent) ...[
                      const SizedBox(height: 32),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 24),
                      _buildField(_otpController, 'Enter 6-Digit OTP', Icons.verified_rounded, type: TextInputType.number),
                      const SizedBox(height: 12),
                      const Text(
                        "Check your email (and Spam) for the verification code.",
                        style: TextStyle(color: AppColors.textHint, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                    
                    const SizedBox(height: 48),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : (_isOtpSent ? _verifyAndSignup : _sendOtp),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 3))
                          : Text(_isOtpSent ? 'VERIFY & REGISTER' : 'CONTINUE'),
                    ),
                    
                    const SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/login'),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(text: 'Login', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800)),
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

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false, TextInputType? type, bool enabled = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      keyboardType: type,
      enabled: enabled,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: colorScheme.primary),
      ),
      validator: (v) => v!.isEmpty ? 'Field required' : null,
    );
  }
}
