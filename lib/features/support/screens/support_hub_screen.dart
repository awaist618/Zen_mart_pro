import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../models/user_model.dart';
import '../../../models/support_ticket_model.dart';
import '../../../services/support_service.dart';

class SupportHubScreen extends ConsumerStatefulWidget {
  const SupportHubScreen({super.key});

  @override
  ConsumerState<SupportHubScreen> createState() => _SupportHubScreenState();
}

class _SupportHubScreenState extends ConsumerState<SupportHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    // Help Center Specific Palette
    final bgColor = isLight ? AppColors.lightBackground : AppColors.supportDarkBackground;
    final cardColor = isLight ? AppColors.lightSurface : AppColors.supportDarkSurface;
    final primaryColor = isLight ? AppColors.lightPrimary : AppColors.supportDarkPrimary;
    final textColor = isLight ? AppColors.lightTextPrimary : AppColors.supportDarkTextPrimary;
    final secondaryTextColor = isLight ? AppColors.lightTextSecondary : AppColors.supportDarkTextSecondary;
    final dividerColor = isLight ? AppColors.lightBorder : AppColors.supportDarkDivider;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, user, isLight, primaryColor, textColor, secondaryTextColor, bgColor),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSearchBar(isLight, cardColor, secondaryTextColor, dividerColor),
                  const SizedBox(height: 32),
                  _SectionHeader(
                    title: 'Quick Help', 
                    isLight: isLight, 
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildActionGrid(context, user.role, isLight, cardColor, primaryColor, textColor, secondaryTextColor, dividerColor),
                  
                  const SizedBox(height: 32),
                  _LiveChatCard(
                    user: user,
                    ref: ref,
                    isLight: isLight, 
                    primary: primaryColor, 
                    cardColor: cardColor, 
                    textColor: textColor, 
                    secondaryTextColor: secondaryTextColor, 
                    divider: dividerColor
                  ),
                  
                  const SizedBox(height: 32),
                  _EmergencyCard(
                    isLight: isLight,
                    onTap: () => context.push('/support/emergency'),
                  ),

                  // NEW: Emergency Reports Tracking
                  Consumer(
                    builder: (context, ref, child) {
                      final reportsAsync = ref.watch(customerEmergencyReportsProvider);
                      return reportsAsync.when(
                        data: (reports) {
                          if (reports.isEmpty) return const SizedBox.shrink();
                          final lastReport = reports.first;
                          return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: InkWell(
                              onTap: () => context.push('/support/emergency-details/${lastReport.id}'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.track_changes_rounded, color: Colors.redAccent, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Track Emergency: ${lastReport.category}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: Colors.redAccent, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    }
                  ),
                  
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(
                        title: 'My Tickets', 
                        isLight: isLight, 
                        textColor: textColor,
                      ),
                      TextButton(
                        onPressed: () => context.push('/support/tickets'),
                        child: Text(
                          'View All', 
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 13)
                        ),
                      ),
                    ],
                  ),
                  _buildRecentTickets(ref, user.uid, isLight, cardColor, textColor, secondaryTextColor, dividerColor, primaryColor),
                  
                  const SizedBox(height: 40),
                  _SectionHeader(
                    title: 'Common Questions', 
                    isLight: isLight, 
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildFAQList(isLight, cardColor, textColor, secondaryTextColor, dividerColor),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTicketSheet(context, user.role),
        backgroundColor: primaryColor,
        elevation: 10,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('NEW TICKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserModel user, bool isLight, Color primary, Color textColor, Color secondaryTextColor, Color bgColor) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: bgColor.withOpacity(0.8),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Decorative Glow
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [primary.withOpacity(0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.success.withOpacity(0.1),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LIVE SUPPORT ONLINE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hi, ${user.name.split(' ').first} 👋',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'How can we help you today?',
                          style: TextStyle(
                            fontSize: 15,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.headset_mic_rounded, color: primary, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isLight, Color cardColor, Color secondaryTextColor, Color divider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)] : null,
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: isLight ? Colors.black : Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search FAQs, tickets or articles...',
          hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: secondaryTextColor.withOpacity(0.7)),
          suffixIcon: Icon(Icons.tune_rounded, color: secondaryTextColor.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, UserRole role, bool isLight, Color cardColor, Color primary, Color textColor, Color secondaryTextColor, Color divider) {
    final categories = _getCategoriesForRole(role);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          icon: _getIconForCategory(category),
          isLight: isLight,
          cardColor: cardColor,
          primary: primary,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          divider: divider,
          onTap: () => context.push('/support/create-ticket', extra: category),
        );
      },
    );
  }

  Widget _buildRecentTickets(WidgetRef ref, String userId, bool isLight, Color cardColor, Color textColor, Color secondaryTextColor, Color divider, Color primary) {
    return StreamBuilder<List<SupportTicketModel>>(
      stream: ref.watch(supportServiceProvider).getUserTickets(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: divider),
            ),
            child: Column(
              children: [
                Icon(Icons.confirmation_number_outlined, size: 48, color: secondaryTextColor.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  'No active tickets found.', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600)
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16),
          itemCount: tickets.length > 3 ? 3 : tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _TicketCard(
            ticket: tickets[index],
            isLight: isLight,
            cardColor: cardColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            divider: divider,
            primary: primary,
          ),
        );
      },
    );
  }

  Widget _buildFAQList(bool isLight, Color cardColor, Color textColor, Color secondaryTextColor, Color divider) {
    final faqs = [
      {'q': 'How do refunds work?', 'a': 'Refunds are processed to your original payment method within 5-7 business days after the vendor approves the return.'},
      {'q': 'How can I cancel an order?', 'a': 'You can cancel your order from the My Orders section as long as the vendor hasn\'t started preparing it.'},
      {'q': 'How long does delivery take?', 'a': 'Delivery times vary by vendor and distance, but most local orders arrive within 30-45 minutes.'},
    ];

    return Column(
      children: faqs.map((faq) => _FAQTile(
        question: faq['q']!, 
        answer: faq['a']!,
        isLight: isLight,
        cardColor: cardColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
        divider: divider,
      )).toList(),
    );
  }

  void _showNewTicketSheet(BuildContext context, UserRole role) {
    context.push('/support/create-ticket');
  }

  List<String> _getCategoriesForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return ['Order Issue', 'Payment', 'Refund', 'Delivery', 'Product Quality', 'Technical', 'Other'];
      case UserRole.vendor:
        return ['Shop Verification', 'Product Approval', 'Payment', 'Withdrawal', 'Technical', 'Customer Complaint', 'Other'];
      case UserRole.rider:
        return ['Delivery Problem', 'Wrong Address', 'Customer Not Available', 'Vehicle Issue', 'Earnings', 'Withdrawal', 'Technical'];
      default:
        return ['General Support', 'Technical Issue', 'Other'];
    }
  }

  IconData _getIconForCategory(String category) {
    if (category.contains('Order')) return Icons.shopping_bag_outlined;
    if (category.contains('Payment') || category.contains('Earnings')) return Icons.account_balance_wallet_outlined;
    if (category.contains('Refund')) return Icons.replay_rounded;
    if (category.contains('Delivery')) return Icons.local_shipping_outlined;
    if (category.contains('Quality')) return Icons.verified_user_outlined;
    if (category.contains('Technical')) return Icons.settings_outlined;
    if (category.contains('Withdrawal')) return Icons.payments_outlined;
    return Icons.help_outline_rounded;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isLight;
  final Color textColor;
  const _SectionHeader({required this.title, required this.isLight, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: textColor,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final IconData icon;
  final bool isLight;
  final Color cardColor;
  final Color primary;
  final Color textColor;
  final Color secondaryTextColor;
  final Color divider;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.isLight,
    required this.cardColor,
    required this.primary,
    required this.textColor,
    required this.secondaryTextColor,
    required this.divider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: divider),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: primary, size: 24),
            ),
            const Spacer(),
            Text(
              category,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Get help with your ${category.toLowerCase()}',
              style: TextStyle(fontSize: 11, color: secondaryTextColor, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveChatCard extends StatelessWidget {
  final UserModel user;
  final WidgetRef ref;
  final bool isLight;
  final Color primary;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color divider;

  const _LiveChatCard({
    required this.user,
    required this.ref,
    required this.isLight, 
    required this.primary,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final chatId = await ref.read(supportServiceProvider).getOrCreateChat(
          user.uid, 
          user.name, 
          user.profilePicture
        );
        if (context.mounted) {
          context.push('/support/live-chat/$chatId');
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: divider),
          boxShadow: isLight ? [BoxShadow(color: primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))] : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.chat_bubble_rounded, color: primary, size: 24),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Chat Support',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chat with our support experts now.',
                    style: TextStyle(fontSize: 13, color: secondaryTextColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10)),
              child: const Text('START', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final bool isLight;
  final VoidCallback onTap;
  const _EmergencyCard({required this.isLight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightError.withOpacity(0.05) : AppColors.supportDarkError.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (isLight ? AppColors.lightError : AppColors.supportDarkError).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isLight ? AppColors.lightError : AppColors.supportDarkError).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.report_gmailerrorred_rounded, color: isLight ? AppColors.lightError : AppColors.supportDarkError, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Assistance',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isLight ? AppColors.lightError : AppColors.supportDarkError,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Safety issues or fraud report.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isLight ? AppColors.lightError.withOpacity(0.7) : AppColors.supportDarkError.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isLight ? AppColors.lightError : AppColors.supportDarkError),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  final bool isLight;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color divider;
  final Color primary;

  const _TicketCard({
    required this.ticket,
    required this.isLight,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.divider,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/support/ticket-chat/${ticket.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: divider),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)] : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TICKET #${ticket.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.title,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
                    ),
                  ],
                ),
                _StatusChip(status: ticket.status),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _TicketMeta(
                  icon: Icons.category_outlined,
                  label: ticket.category,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(width: 16),
                _TicketMeta(
                  icon: Icons.access_time_rounded,
                  label: DateFormat('MMM d').format(ticket.createdAt),
                  secondaryTextColor: secondaryTextColor,
                ),
                const Spacer(),
                if (ticket.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${ticket.unreadCount} NEW',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TicketStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TicketStatus.open: color = AppColors.info; break;
      case TicketStatus.assigned: color = Colors.purple; break;
      case TicketStatus.inProgress: color = AppColors.warning; break;
      case TicketStatus.waitingForUser: color = Colors.orange; break;
      case TicketStatus.resolved: color = AppColors.success; break;
      case TicketStatus.closed: color = AppColors.textDisabled; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}

class _TicketMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color secondaryTextColor;
  const _TicketMeta({required this.icon, required this.label, required this.secondaryTextColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: secondaryTextColor.withOpacity(0.5)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: secondaryTextColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLight;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color divider;

  const _FAQTile({
    required this.question, 
    required this.answer,
    required this.isLight,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.divider,
  });

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.divider),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: Text(
                widget.question, 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.textColor)
              ),
              trailing: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isExpanded ? 0.5 : 0,
                child: Icon(Icons.keyboard_arrow_down_rounded, color: widget.secondaryTextColor.withOpacity(0.5)),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                widget.answer, 
                style: TextStyle(color: widget.secondaryTextColor, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500)
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
