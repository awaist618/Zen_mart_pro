import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/providers.dart';
import '../../models/address_model.dart';
import '../../theme/app_colors.dart';

class AddressManagementScreen extends ConsumerWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(customerAddressesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer/profile');
            }
          },
        ),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                      child: Icon(Icons.location_off_rounded, size: 64, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 24),
                    const Text('No addresses saved', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    Text(
                      'Add your delivery addresses to make checkout faster and easier.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _showAddressDialog(context, ref),
                      icon: const Icon(Icons.add_location_alt_rounded, size: 20),
                      label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _AddressTile(address: addresses[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressDialog(context, ref),
        backgroundColor: AppColors.accent,
        elevation: 8,
        label: const Text('New Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
      ),
    );
  }

  void _showAddressDialog(BuildContext context, WidgetRef ref, {AddressModel? address}) {
    final labelController = TextEditingController(text: address?.label);
    final addressController = TextEditingController(text: address?.fullAddress);
    final cityController = TextEditingController(text: address?.city);
    bool isDefault = address?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: EdgeInsets.fromLTRB(28, 20, 28, MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 32),
              Text(
                address == null ? 'New Location' : 'Update Address',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter details for your delivery point',
                style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              _buildField(labelController, 'Label (e.g. Home, Office, Gym)', Icons.bookmark_rounded),
              const SizedBox(height: 16),
              _buildField(addressController, 'Full Street Address', Icons.location_on_rounded),
              const SizedBox(height: 16),
              _buildField(cityController, 'City', Icons.location_city_rounded),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.05)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Primary Delivery Address', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
                  subtitle: const Text('Use this as default for all orders', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  value: isDefault,
                  activeColor: AppColors.accent,
                  onChanged: (v) => setState(() => isDefault = v),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final user = ref.read(userModelProvider).asData?.value;
                    if (user == null) return;
                    final newAddress = AddressModel(
                      id: address?.id ?? '',
                      label: labelController.text.trim(),
                      fullAddress: addressController.text.trim(),
                      city: cityController.text.trim(),
                      isDefault: isDefault,
                    );
                    if (address == null) {
                      ref.read(customerServiceProvider).addAddress(user.uid, newAddress);
                    } else {
                      ref.read(customerServiceProvider).updateAddress(user.uid, newAddress);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: Text(address == null ? 'Save Location' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.withOpacity(0.1))
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint, 
          border: InputBorder.none, 
          prefixIcon: Icon(icon, size: 20, color: AppColors.accent), 
          hintStyle: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.w600)
        ),
      ),
    );
  }
}

class _AddressTile extends ConsumerWidget {
  final AddressModel address;
  const _AddressTile({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHome = address.label.toLowerCase().contains('home');
    final bool isOffice = address.label.toLowerCase().contains('office') || address.label.toLowerCase().contains('work');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: address.isDefault 
          ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5) 
          : Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: address.isDefault 
                  ? [AppColors.accent.withOpacity(0.15), AppColors.accent.withOpacity(0.05)]
                  : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isHome ? Icons.home_rounded : isOffice ? Icons.business_center_rounded : Icons.location_on_rounded,
              color: address.isDefault ? AppColors.accent : Colors.grey[400], 
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.label, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A), letterSpacing: -0.2)
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.fullAddress, 
                  style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  address.city, 
                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w700)
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
            elevation: 8,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: _PopupItem(label: 'Edit', icon: Icons.edit_rounded)),
              const PopupMenuItem(value: 'delete', child: _PopupItem(label: 'Delete', icon: Icons.delete_rounded, color: Colors.redAccent)),
              if (!address.isDefault) const PopupMenuItem(value: 'default', child: _PopupItem(label: 'Set Default', icon: Icons.check_circle_rounded)),
            ],
            onSelected: (val) {
              final user = ref.read(userModelProvider).asData?.value;
              if (user == null) return;
              if (val == 'edit') {
                const AddressManagementScreen()._showAddressDialog(context, ref, address: address);
              } else if (val == 'delete') {
                ref.read(customerServiceProvider).deleteAddress(user.uid, address.id);
              } else if (val == 'default') {
                ref.read(customerServiceProvider).setDefaultAddress(user.uid, address.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PopupItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const _PopupItem({required this.label, required this.icon, this.color});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 18, color: color ?? Colors.black87), const SizedBox(width: 12), Text(label, style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w600))]);
}
