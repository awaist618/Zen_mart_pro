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
        title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No addresses saved yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddressDialog(context, ref),
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text('Add New Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => Material(
              color: Colors.transparent,
              child: _AddressTile(address: addresses[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressDialog(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address == null ? 'Add New Address' : 'Edit Address',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (e.g., Home, Work)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Full Address'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Set as Default'),
                value: isDefault,
                activeColor: AppColors.accent,
                onChanged: (v) => setState(() => isDefault = v),
              ),
              const SizedBox(height: 24),
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
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(address == null ? 'Save Address' : 'Update Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: address.isDefault ? Border.all(color: AppColors.accent, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              address.label.toLowerCase() == 'home' ? Icons.home_rounded : 
              address.label.toLowerCase() == 'work' ? Icons.work_rounded : Icons.location_on_rounded,
              color: AppColors.accent, size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('DEFAULT', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(address.fullAddress, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)),
                Text(address.city, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              if (!address.isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
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
