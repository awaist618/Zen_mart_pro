import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../core/widgets/password_dialogs.dart';
import '../../models/user_model.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final shopsCount = ref.watch(totalShopsCountProvider).asData?.value ?? 0;
    final ridersCount = ref.watch(totalRidersCountProvider).asData?.value ?? 0;
    final customersCount = ref.watch(totalCustomersCountProvider).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Admin not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Admin Identity Card
                _buildAdminCard(context, user),
                const SizedBox(height: 24),

                _SectionHeader(title: 'System Information'),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => context.push('/admin/system-info'),
                  child: _SystemInfoGrid(
                    shops: shopsCount,
                    riders: ridersCount,
                    customers: customersCount,
                  ),
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Administrative Controls'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Security Settings',
                      subtitle: '2FA, Active Sessions, Login History',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Support Management',
                      subtitle: 'Manage support tickets and replies',
                      onTap: () => context.push('/admin/support'),
                    ),
                    _SettingsTile(
                      icon: Icons.settings_applications_outlined,
                      title: 'System Settings',
                      subtitle: 'App version, server status, maintenance',
                      onTap: () => context.push('/admin/system'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Personal & Security'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your administrative password',
                      onTap: () => PasswordDialogs.showChangePasswordDialog(context, ref),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'App Language',
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
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout Admin Session', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildAdminCard(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user.profilePicture != null ? NetworkImage(user.profilePicture!) : null,
            child: user.profilePicture == null
                ? Text(user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary))
                : null,
          ),
          const SizedBox(height: 20),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text('SUPER ADMIN', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          Text(user.email, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 8),
          Text('Admin ID: ${user.uid.substring(0, 8).toUpperCase()}', style: TextStyle(color: Colors.grey[300], fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to log out from the Super Admin panel?'),
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
}

class _SystemInfoGrid extends StatelessWidget {
  final int shops;
  final int riders;
  final int customers;
  const _SystemInfoGrid({required this.shops, required this.riders, required this.customers});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _InfoBox(label: 'Shops', value: shops.toString(), color: Colors.indigo)),
        const SizedBox(width: 12),
        Expanded(child: _InfoBox(label: 'Riders', value: riders.toString(), color: Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _InfoBox(label: 'Users', value: customers.toString(), color: Colors.green)),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))), child: Column(children: [Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 2), Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10))]));
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
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(children: children));
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 20)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])), trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20));
}
