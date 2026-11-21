// providers/category_provider.dart
import 'package:cs_elective_2/models/category.dart';
import 'package:cs_elective_2/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_provider.dart';

// exposes the service (dependency injection)
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(supabaseProvider));
});

// exposes the state (loading / error / data)
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryServiceProvider).fetchAll();
});

// admin actions. after each change we refetch the list
final categoryActionsProvider = Provider<CategoryActions>((ref) {
  return CategoryActions(ref);
});

class CategoryActions {
  final Ref ref;
  CategoryActions(this.ref);

  Future<void> add(String name) async {
    await ref.read(categoryServiceProvider).add(name);
    ref.invalidate(categoriesProvider);
  }

  Future<void> rename(int id, String name) async {
    await ref.read(categoryServiceProvider).rename(id, name);
    ref.invalidate(categoriesProvider);
  }

  Future<void> delete(int id) async {
    await ref.read(categoryServiceProvider).delete(id);
    ref.invalidate(categoriesProvider);
  }
}
