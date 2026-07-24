import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './vendor_management_screen.dart';
import './customer_management_screen.dart';
import './rider_management_screen.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const UserManagementScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.4),
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'VENDORS'),
            Tab(text: 'CUSTOMERS'),
            Tab(text: 'RIDERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VendorManagementScreen(),
          CustomerManagementScreen(),
          RiderManagementScreen(),
        ],
      ),
    );
  }
}
