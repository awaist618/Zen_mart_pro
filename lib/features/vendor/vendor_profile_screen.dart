import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import './widgets/vendor_bottom_nav.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final shopAsync = ref.watch(currentShopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Vendor Account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile & Shop Identity
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
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
                              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: const Color(0xFF1E293B),
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B5CF6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shopAsync.value?.name ?? 'Loading Shop...',
                        style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Shop Management'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.storefront_rounded,
                      title: 'Shop Information',
                      subtitle: 'Name, Category, Description',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.photo_size_select_actual_outlined,
                      title: 'Shop Banner',
                      subtitle: 'Update store header image',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.business_center_outlined,
                      title: 'Business Details',
                      subtitle: 'Address, Tax Info, Documents',
                      onTap: () {},
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
                      title: 'Profile Settings',
                      subtitle: 'Contact details and email',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Password & Security',
                      subtitle: 'Change password, 2FA',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.settings_outlined,
                      title: 'App Settings',
                      subtitle: 'Notifications, Language',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authServiceProvider).signOut();
                      context.go('/welcome');
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout Session', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
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
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black.withOpacity(0.4),
            letterSpacing: 1.2,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.4))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
