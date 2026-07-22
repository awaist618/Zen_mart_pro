import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  const EditShopScreen({super.key});

  @override
  ConsumerState<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends ConsumerState<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _hoursController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final shop = ref.read(currentShopProvider).asData?.value;
    _nameController = TextEditingController(text: shop?.name);
    _descController = TextEditingController(text: shop?.description);
    _phoneController = TextEditingController(text: shop?.phone);
    _addressController = TextEditingController(text: shop?.address);
    _hoursController = TextEditingController(text: shop?.openingHours);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final shop = ref.read(currentShopProvider).asData?.value;
    if (shop == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(vendorServiceProvider).updateShopData(shop.id, {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'openingHours': _hoursController.text.trim(),
      });
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(currentShopProvider).asData?.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Store Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner & Logo Edit
              _buildImagePickers(shop),
              const SizedBox(height: 32),
              
              const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Store Name', Icons.storefront_rounded),
              _buildTextField(_descController, 'Store Description', Icons.description_outlined, maxLines: 3),
              
              const SizedBox(height: 24),
              const Text('Contact & Logistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Public Contact Number', Icons.phone_outlined),
              _buildTextField(_addressController, 'Store Physical Address', Icons.location_on_outlined),
              _buildTextField(_hoursController, 'Opening Hours (e.g. 9 AM - 10 PM)', Icons.access_time_rounded),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vendor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Store Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickers(dynamic shop) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                image: shop?.bannerImage != null ? DecorationImage(image: NetworkImage(shop.bannerImage!), fit: BoxFit.cover) : null,
              ),
              child: shop?.bannerImage == null ? const Center(child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 40)) : null,
            ),
            Positioned(
              bottom: -30,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: shop?.logoUrl != null ? NetworkImage(shop.logoUrl!) : null,
                  child: shop?.logoUrl == null ? const Icon(Icons.store, color: Colors.grey) : null,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                radius: 18,
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) => v!.isEmpty ? 'This field is required' : null,
      ),
    );
  }
}
