import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/category_model.dart';
import '../../theme/app_colors.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text('No categories added yet.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.category_rounded, color: colorScheme.primary),
                  ),
                  title: Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  subtitle: Text('${cat.shopCount} Shops', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
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
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), 
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        title: Text('Add New Category', style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: const InputDecoration(hintText: 'Category Name (e.g. Grocery)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('CANCEL', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold))
          ),
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
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}
