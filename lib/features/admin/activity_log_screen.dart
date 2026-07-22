import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/activity_model.dart';
import '../../theme/app_colors.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String _filter = 'Today';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  DateTime? _getFilterDate() {
    final now = DateTime.now();
    switch (_filter) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'Month':
        return DateTime(now.year, now.month, 1);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterDate = _getFilterDate();
    final activitiesAsync = ref.watch(activityLogsProvider(filterDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Activity Log', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting activity log...')),
              );
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                          decoration: const InputDecoration(
                            hintText: 'Search logs...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Today', 'Week', 'Month', 'All'].map((f) {
                    final isSelected = _filter == f;
                    return ChoiceChip(
                      label: Text(f),
                      selected: isSelected,
                      onSelected: (s) => setState(() => _filter = f),
                      selectedColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Log List
          Expanded(
            child: activitiesAsync.when(
              data: (activities) {
                final filtered = activities.where((a) =>
                  a.title.toLowerCase().contains(_searchQuery) ||
                  a.subtitle.toLowerCase().contains(_searchQuery)
                ).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching activities found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _LogTile(activity: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final ActivityModel activity;
  const _LogTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, color: activity.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  activity.subtitle,
                  style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm a').format(activity.timestamp),
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
              ),
              Text(
                DateFormat('MMM dd').format(activity.timestamp),
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
