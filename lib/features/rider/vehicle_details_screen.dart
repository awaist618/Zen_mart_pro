import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _regController;
  late TextEditingController _colorController;
  late TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userModelProvider).asData?.value;
    _brandController = TextEditingController(text: user?.vehicleBrand ?? 'Honda');
    _modelController = TextEditingController(text: user?.vehicleModel ?? 'CD 70');
    _regController = TextEditingController(text: user?.licenseNumber ?? '');
    _colorController = TextEditingController(text: user?.vehicleColor ?? 'Red');
    _plateController = TextEditingController(text: user?.vehicleInfo ?? 'ABC-1234');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _regController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _saveVehicleInfo() async {
    final user = ref.read(userModelProvider).asData?.value;
    if (user == null) return;

    await ref.read(riderServiceProvider).updateProfile(user.uid, {
      'vehicleBrand': _brandController.text.trim(),
      'vehicleModel': _modelController.text.trim(),
      'vehicleColor': _colorController.text.trim(),
      'vehicleInfo': _plateController.text.trim(), // Using vehicleInfo for number plate
    });

    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle Information Updated')),
      );
    }
  }

  void _updateVehiclePhoto() async {
    final user = ref.read(userModelProvider).asData?.value;
    if (user == null) return;

    final url = await ref.read(uploadServiceProvider).pickAndUploadImage(
      context: context,
      folder: 'rider_vehicles',
    );

    if (url != null) {
      await ref.read(riderServiceProvider).updateProfile(user.uid, {'vehicleImage': url});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle photo updated')),
        );
      }
    }
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
              if (_isEditing) {
                _saveVehicleInfo();
              } else {
                setState(() => _isEditing = true);
              }
            },
            icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_rounded, color: AppColors.rider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehiclePhoto(user),
            const SizedBox(height: 32),
            const Text('BASIC INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  _VehicleInfoRow(label: 'Vehicle Type', value: 'Motorcycle (Bike)', icon: Icons.directions_bike_rounded),
                  _VehicleInfoRow(
                    label: 'Brand', 
                    value: _brandController.text, 
                    isEditable: _isEditing, 
                    controller: _brandController,
                    icon: Icons.branding_watermark_outlined,
                  ),
                  _VehicleInfoRow(
                    label: 'Model / Year', 
                    value: _modelController.text, 
                    isEditable: _isEditing, 
                    controller: _modelController,
                    icon: Icons.calendar_today_outlined,
                  ),
                  _VehicleInfoRow(
                    label: 'Color', 
                    value: _colorController.text, 
                    isEditable: _isEditing, 
                    controller: _colorController,
                    icon: Icons.color_lens_outlined,
                  ),
                  _VehicleInfoRow(
                    label: 'Number Plate', 
                    value: _plateController.text, 
                    isEditable: _isEditing, 
                    controller: _plateController,
                    icon: Icons.pin_outlined,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('DOCUMENTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _DocumentTile(title: 'Registration Document', status: 'Approved', icon: Icons.description_outlined),
            _DocumentTile(title: 'Insurance Policy', status: 'Optional', icon: Icons.security_outlined, isOptional: true),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclePhoto(UserModel? user) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(user?.vehicleImage ?? 'https://images.unsplash.com/photo-1444491741275-3747c53c99b4?auto=format&fit=crop&q=80&w=400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                onPressed: _updateVehiclePhoto,
                backgroundColor: AppColors.rider,
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEditable;
  final TextEditingController? controller;
  final bool isLast;

  const _VehicleInfoRow({required this.label, required this.value, required this.icon, this.isEditable = false, this.controller, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.rider.withOpacity(0.5), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
                if (isEditable && controller != null)
                  TextField(
                    controller: controller,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  )
                else
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final bool isOptional;

  const _DocumentTile({required this.title, required this.status, required this.icon, this.isOptional = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.rider),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Text(status, style: TextStyle(color: isOptional ? Colors.grey : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
