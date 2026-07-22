import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _regController;
  late TextEditingController _insuranceController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userModelProvider).asData?.value;
    _typeController = TextEditingController(text: user?.vehicleInfo?.split('(').first.trim() ?? 'Bike');
    _regController = TextEditingController(text: user?.vehicleInfo?.split('(').last.replaceAll(')', '').trim() ?? '');
    _insuranceController = TextEditingController(text: 'Active (Policy #99281)');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _regController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userModelProvider).asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save logic would go here
                }
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, color: AppColors.rider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1558981403-c5f91cbba527?auto=format&fit=crop&q=80&w=400'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: AppColors.rider,
                          radius: 18,
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('General Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildField(
                label: 'Bike Type',
                controller: _typeController,
                icon: Icons.directions_bike_rounded,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Registration Number',
                controller: _regController,
                icon: Icons.numbers_rounded,
                enabled: _isEditing,
              ),
              const SizedBox(height: 32),
              const Text('Legal & Insurance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildField(
                label: 'Insurance Details (Optional)',
                controller: _insuranceController,
                icon: Icons.security_rounded,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'License Number',
                controller: TextEditingController(text: user?.licenseNumber),
                icon: Icons.badge_rounded,
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: enabled ? AppColors.rider.withOpacity(0.3) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              icon: Icon(icon, color: AppColors.rider, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
