import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/category_model.dart';
import '../../theme/app_colors.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) return const Center(child: Text('No categories added yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.category_rounded, color: AppColors.primary),
                  ),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${cat.shopCount} Shops'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => ref.read(adminServiceProvider).deleteCategory(cat.id),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Category Name (e.g. Grocery)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(adminServiceProvider).addCategory(CategoryModel(
                  id: '',
                  name: nameController.text.trim(),
                  icon: 'category',
                  imageUrl: '',
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
