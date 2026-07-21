import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class AddVendorScreen extends ConsumerStatefulWidget {
  const AddVendorScreen({super.key});

  @override
  ConsumerState<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends ConsumerState<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Vendor Details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Shop Details
  final _shopNameController = TextEditingController();
  final _shopCategoryController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    _shopCategoryController.dispose();
    super.dispose();
  }

  Future<void> _createVendor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).createSubUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'vendor',
        shopName: _shopNameController.text.trim(),
        shopCategory: _shopCategoryController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor and Shop created successfully!')),
        );
        context.pop();
      }
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
          Container(decoration: const BoxDecoration(color: Color(0xFF0F172A))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Register New Vendor',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a vendor account and assign them a new shop.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    
                    _SectionTitle(title: 'Vendor Information'),
                    const SizedBox(height: 16),
                    _buildGlassContainer(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Initial Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    _SectionTitle(title: 'Shop Information'),
                    const SizedBox(height: 16),
                    _buildGlassContainer(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _shopNameController,
                            label: 'Shop Name',
                            icon: Icons.storefront_rounded,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _shopCategoryController,
                            label: 'Category (e.g. Grocery, Food)',
                            icon: Icons.category_outlined,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createVendor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Vendor & Shop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
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
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
    );
  }
}
