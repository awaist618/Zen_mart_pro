import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Support Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help you?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Search our help center or contact our team directly.', style: TextStyle(color: Colors.black.withOpacity(0.5))),
            const SizedBox(height: 24),
            
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for articles...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Popular Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _SupportItem(title: 'How to increase my ratings?', icon: Icons.star_outline_rounded, onTap: () {}),
            _SupportItem(title: 'Issues with payment withdrawal', icon: Icons.account_balance_wallet_outlined, onTap: () {}),
            _SupportItem(title: 'What to do if customer is not responding?', icon: Icons.person_off_outlined, onTap: () {}),
            
            const SizedBox(height: 32),
            const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                _ContactCard(
                  label: 'Support Hub',
                  icon: Icons.support_agent_rounded,
                  color: Colors.blue,
                  onTap: () => context.push('/support'),
                ),
                const SizedBox(width: 16),
                _ContactCard(
                  label: 'Contact Admin',
                  icon: Icons.headset_mic_outlined,
                  color: AppColors.rider,
                  onTap: () => launchUrl(Uri.parse('tel:+923001234567')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SupportItem(title: 'Report a problem', icon: Icons.report_problem_outlined, color: Colors.redAccent, onTap: () {}),
            _SupportItem(title: 'Frequently Asked Questions', icon: Icons.help_outline_rounded, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _SupportItem({required this.title, required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: color ?? AppColors.rider),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
