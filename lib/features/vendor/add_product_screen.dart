import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _stockController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');
  final _categoryController = TextEditingController();
  
  bool _isLoading = false;
  bool _isAvailable = true;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final url = await ref.read(uploadServiceProvider).pickAndUploadImage(
      context: context,
      folder: 'products',
    );
    
    if (url != null) {
      setState(() {
        // We'll store the URL directly since it's already uploaded
        _uploadedImageUrl = url;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick/upload an image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(userModelProvider).value;
      if (user == null) throw Exception('User session expired. Please log in again.');
      if (user.shopId == null) throw Exception('Shop ID missing. Ensure your vendor account is set up.');

      // 2. Save to Firestore (Image is already uploaded now)
      final product = ProductModel(
        id: '', 
        vendorId: user.uid,
        shopId: user.shopId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        discount: double.parse(_discountController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        unit: _unitController.text.trim(),
        imageUrl: _uploadedImageUrl!,
        category: _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
        isAvailable: _isAvailable,
        createdAt: DateTime.now(),
      );

      await ref.read(vendorServiceProvider).addProduct(product);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Product Save Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              _buildSectionTitle('PRODUCT IMAGE'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  image: _uploadedImageUrl != null ? DecorationImage(image: NetworkImage(_uploadedImageUrl!), fit: BoxFit.cover) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: _uploadedImageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.vendor.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text('Tap to upload product photo', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ) 
                    : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('BASIC INFORMATION'),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Product Name', Icons.shopping_bag_outlined),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_categoryController, 'Category (e.g. Dairy, Bakery)', Icons.category_outlined, isRequired: false),
              
              const SizedBox(height: 32),
              _buildSectionTitle('PRICING & INVENTORY'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Price (Rs)', Icons.payments_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_discountController, 'Discount (%)', Icons.percent_rounded, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_stockController, 'Stock Qty', Icons.inventory_2_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_unitController, 'Unit (kg, pcs)', Icons.scale_outlined)),
                ],
              ),
              
              const SizedBox(height: 24),
              // Availability Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Product Available', style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch.adaptive(
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                      activeColor: AppColors.vendor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vendor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Save Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType, bool isRequired = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.vendor, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => (isRequired && (v == null || v.isEmpty)) ? 'Required' : null,
      ),
    );
  }
}
