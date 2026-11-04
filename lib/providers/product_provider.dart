import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'supabase_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(supabaseProvider));
});

final productProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return ref.read(productServiceProvider).fetchProducts();
  }

  Future<void> addProduct(Product product) async {
    await ref.read(productServiceProvider).addProduct(product);
    state = AsyncValue.data(
      await ref.read(productServiceProvider).fetchProducts(),
    );
  }

  Future<void> deleteProduct(int id) async {
    await ref.read(productServiceProvider).deleteProduct(id);
    final currentProducts = state.value ?? [];
    state = AsyncData(currentProducts.where((p) => p.id != id).toList());
  }
}
