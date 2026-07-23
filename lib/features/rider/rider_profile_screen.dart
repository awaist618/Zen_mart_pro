import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import './widgets/rider_bottom_nav.dart';
import '../../core/widgets/password_dialogs.dart';
import '../../models/user_model.dart';

class RiderProfileScreen extends ConsumerWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Rider Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => context.push('/rider/support'),
            icon: const Icon(Icons.support_agent_rounded),
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
                // Enhanced Rider Identity Card
                _buildRiderCard(context, user),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Earnings',
                        value: 'Rs ${NumberFormat.compact().format(user.totalEarnings)}',
                        icon: Icons.payments_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatBox(
                        label: 'Deliveries',
                        value: user.totalDeliveries.toString(),
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.rider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Work & Performance'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.analytics_outlined,
                      title: 'Performance Stats',
                      subtitle: 'Ratings, reviews and feedback',
                      onTap: () => context.push('/rider/performance'),
                    ),
                    _SettingsTile(
                      icon: Icons.history_rounded,
                      title: 'Delivery History',
                      subtitle: 'List of completed tasks',
                      onTap: () => context.push('/rider/history'),
                    ),
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payout Summary',
                      subtitle: 'Withdrawal and earnings info',
                      onTap: () => context.push('/rider/earnings'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Compliance & Vehicle'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.directions_bike_rounded,
                      title: 'Vehicle Details',
                      subtitle: 'Model, Number Plate, Insurance',
                      onTap: () => context.push('/rider/vehicle'),
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Legal Documents',
                      subtitle: 'License, CNIC, Verification',
                      onTap: () => context.push('/rider/documents'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'Security & App'),
                const SizedBox(height: 12),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Keep your account secure',
                      onTap: () => PasswordDialogs.showChangePasswordDialog(context, ref),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'App Language',
                      subtitle: 'Select preferred language',
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
                    icon: const Icon(Icons.power_settings_new_rounded),
                    label: const Text('Go Offline & Logout', style: TextStyle(fontWeight: FontWeight.bold)),
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
      bottomNavigationBar: const RiderBottomNav(currentIndex: 3),
    );
  }

  Widget _buildRiderCard(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.rider.withOpacity(0.1),
                backgroundImage: user.profilePicture != null ? NetworkImage(user.profilePicture!) : null,
                child: user.profilePicture == null
                    ? Text(user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.rider))
                    : null,
              ),
              if (user.verificationStatus == VerificationStatus.verified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded, color: Colors.blue, size: 24),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Rider ID: ${user.uid.substring(0, 8).toUpperCase()}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Badge(icon: Icons.star_rounded, label: '${user.rating} Rating', color: Colors.orange),
              const SizedBox(width: 12),
              _Badge(
                icon: user.isOnline ? Icons.online_prediction : Icons.offline_bolt_outlined,
                label: user.isOnline ? 'ONLINE' : 'OFFLINE',
                color: user.isOnline ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Offline?'),
        content: const Text('Logging out will set your status to Offline. You will not receive any new delivery requests.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = ref.read(authServiceProvider);
              final riderService = ref.read(riderServiceProvider);
              final uid = ref.read(userModelProvider).value?.uid;
              
              if (uid != null) {
                await riderService.toggleOnlineStatus(uid, false);
              }
              await auth.signOut();
              if (context.mounted) context.go('/welcome');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))]));
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11))]));
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
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
  Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.rider.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.rider, size: 20)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])), trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20));
}
