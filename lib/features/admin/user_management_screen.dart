import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Vendors'),
            Tab(text: 'Customers'),
            Tab(text: 'Riders'),
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
