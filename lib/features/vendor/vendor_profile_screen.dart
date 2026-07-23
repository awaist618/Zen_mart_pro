import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import './widgets/vendor_bottom_nav.dart';
import '../../core/widgets/password_dialogs.dart';
import '../../models/user_model.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final shopAsync = ref.watch(currentShopProvider);
    final productsAsync = ref.watch(shopProductsProvider);
    final ordersAsync = ref.watch(allShopOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Store Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => context.push('/support'),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          final shop = shopAsync.asData?.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Enhanced Shop Identity Card
                _buildShopCard(context, ref, user, shop),
                const SizedBox(height: 24),

                // Stats Grid
                _buildStatsGrid(productsAsync, ordersAsync, user),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Shop Controls'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.storefront_rounded,
                      title: 'Edit Shop Details',
                      subtitle: 'Name, Category, Description, Banner',
                      onTap: () => context.push('/vendor/edit-shop'),
                    ),
                    _SettingsTile(
                      icon: Icons.account_balance_rounded,
                      title: 'Bank Information',
                      subtitle: 'Payout methods and details',
                      onTap: () => _showBankInfoDialog(context, ref, user),
                    ),
                    _SettingsTile(
                      icon: Icons.insights_rounded,
                      title: 'Sales Analytics',
                      subtitle: 'View detailed performance reports',
                      onTap: () => context.push('/vendor/analytics'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Customer Engagement'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Customer Reviews',
                      subtitle: 'View and reply to store feedback',
                      onTap: () => context.push('/vendor/reviews'),
                    ),
                    _SettingsTile(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Promo Coupons',
                      subtitle: 'Manage discount codes',
                      onTap: () => context.push('/vendor/coupons'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Account Security'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Keep your credentials safe',
                      onTap: () => PasswordDialogs.showChangePasswordDialog(context, ref),
                    ),
                    _SettingsTile(
                      icon: Icons.power_settings_new_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from this device',
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 3),
    );
  }

  Widget _buildShopCard(BuildContext context, WidgetRef ref, UserModel user, ShopModel? shop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          // Banner Area
          GestureDetector(
            onTap: () => _uploadShopImage(context, ref, shop?.id, true),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.vendor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                image: shop?.bannerImage != null ? DecorationImage(image: NetworkImage(shop!.bannerImage!), fit: BoxFit.cover) : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (shop?.bannerImage == null)
                    const Center(child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white, size: 32)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      radius: 14,
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _uploadShopImage(context, ref, shop?.id, false),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.vendor,
                                backgroundImage: shop?.logoUrl != null ? NetworkImage(shop!.logoUrl!) : null,
                                child: shop?.logoUrl == null
                                    ? Text(shop?.name.substring(0, 1).toUpperCase() ?? 'V',
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _uploadShopImage(context, ref, shop?.id, false),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppColors.vendor, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(shop?.name ?? 'Loading Shop...', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.email, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Badge(icon: Icons.star_rounded, label: '${user.rating} Rating', color: Colors.orange),
              const SizedBox(width: 12),
              _Badge(icon: Icons.verified_user_rounded, label: 'Verified Vendor', color: Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AsyncValue<List<ProductModel>> products, AsyncValue<List<OrderModel>> orders, UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Total Revenue',
            value: 'Rs ${NumberFormat.compact().format(user.totalEarnings)}',
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatBox(
            label: 'Products',
            value: (products.value?.length ?? 0).toString(),
            icon: Icons.inventory_2_outlined,
            color: AppColors.vendor,
          ),
        ),
      ],
    );
  }

  void _showBankInfoDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final accountController = TextEditingController();
    final bankNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bankNameController, decoration: const InputDecoration(labelText: 'Bank/Wallet Name')),
            TextField(controller: accountController, decoration: const InputDecoration(labelText: 'Account Number/IBAN')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(vendorServiceProvider).updateBankDetails(user.uid, {
                'bankName': bankNameController.text,
                'accountNumber': accountController.text,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of your Vendor account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              context.go('/welcome');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _uploadProfilePicture(BuildContext context, WidgetRef ref, String uid) async {
    final url = await ref.read(uploadServiceProvider).pickAndUploadImage(
      context: context, 
      folder: 'vendor_profiles',
      source: ImageSource.gallery,
    );
    
    if (url != null) {
      await ref.read(authServiceProvider).updateProfilePicture(uid, url);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }
  }

  void _uploadShopImage(BuildContext context, WidgetRef ref, String? shopId, bool isBanner) async {
    if (shopId == null) return;

    final url = await ref.read(uploadServiceProvider).pickAndUploadImage(
      context: context, 
      folder: isBanner ? 'shop_banners' : 'shop_logos',
      source: ImageSource.gallery,
    );
    
    if (url != null) {
      if (isBanner) {
        await ref.read(vendorServiceProvider).updateShopBanner(shopId, url);
      } else {
        await ref.read(vendorServiceProvider).updateShopLogo(shopId, url);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isBanner ? 'Banner' : 'Logo'} updated successfully!')),
        );
      }
    }
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Row(children: [const SizedBox(width: 8), Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey[400], letterSpacing: 1.5))]);
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(children: children),
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.vendor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.vendor, size: 20)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])), trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20));
}
