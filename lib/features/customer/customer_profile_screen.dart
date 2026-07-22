import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import './widgets/customer_bottom_nav.dart';
import '../../core/widgets/password_dialogs.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final ordersAsync = ref.watch(customerOrdersProvider);
    final wishlistAsync = ref.watch(customerWishlistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Enhanced Profile Card
                _buildProfileCard(context, user),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Total Orders',
                        value: (ordersAsync.value?.length ?? 0).toString(),
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatBox(
                        label: 'Wishlist',
                        value: (wishlistAsync.value?.length ?? 0).toString(),
                        icon: Icons.favorite_border_rounded,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Account Settings'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal details',
                      onTap: () => _showEditProfileDialog(context, ref, user),
                    ),
                    _SettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: 'Manage delivery locations',
                      onTap: () => context.push('/customer/addresses'),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Keep your account secure',
                      onTap: () => PasswordDialogs.showChangePasswordDialog(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'My Activity'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.receipt_long_rounded,
                      title: 'Order History',
                      subtitle: 'View and track your orders',
                      onTap: () => context.push('/customer/orders'),
                    ),
                    _SettingsTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Wishlist Items',
                      subtitle: 'Your saved products',
                      onTap: () {}, // TODO: Wishlist Screen
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Offers and updates',
                      onTap: () {}, // TODO: Notifications Screen
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Preferences'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Toggle app theme',
                      trailing: Switch(value: false, onChanged: (v) {}),
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon: const Icon(Icons.power_settings_new_rounded, size: 20),
                    label: const Text('Sign Out Account', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.1), width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'App Version 1.0.2 (Build 124)',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 2),
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: user.profilePicture != null ? NetworkImage(user.profilePicture!) : null,
                  child: user.profilePicture == null
                      ? Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.accent)
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user.name, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)
          ),
          const SizedBox(height: 6),
          Text(
            user.email, 
            style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w600)
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  'Member since ${DateFormat('MMM yyyy').format(user.createdAt)}',
                  style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).updateUserProfile(
                uid: user.uid,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out of Zen Mart Pro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              context.go('/welcome');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey[400],
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }
}
