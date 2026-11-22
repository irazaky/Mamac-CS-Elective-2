import 'package:cs_elective_2/models/category.dart';
import 'package:cs_elective_2/providers/auth_provider.dart';
import 'package:cs_elective_2/providers/category_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// admin: add, rename and delete categories
class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CategoryDialog(),
    );
    if (name == null) return;

    try {
      await ref.read(categoryActionsProvider).add(name);
    } catch (e) {
      if (context.mounted) _showMessage(context, errorMessage(e));
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Category c) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(initialName: c.name),
    );
    if (name == null || name == c.name) return;

    try {
      await ref.read(categoryActionsProvider).rename(c.id, name);
    } catch (e) {
      if (context.mounted) _showMessage(context, errorMessage(e));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Delete the category "${c.name}"? '
          'Its products will be left without a category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(categoryActionsProvider).delete(c.id);
    } catch (e) {
      if (context.mounted) _showMessage(context, errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'You do not have permission to manage categories.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage(e)),
              TextButton(
                onPressed: () => ref.invalidate(categoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }
          return ListView(
            children: [
              for (final c in categories)
                ListTile(
                  title: Text(c.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _rename(context, ref, c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _delete(context, ref, c),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// add / rename dialog. it is a StatefulWidget so the controller gets disposed properly
class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.initialName});

  final String? initialName;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final text = _name.text.trim();
    if (text.isEmpty) return; // name is required
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add category' : 'Edit category'),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
