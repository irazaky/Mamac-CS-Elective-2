import 'package:cs_elective_2/models/product_page.dart';
import 'package:cs_elective_2/providers/product_filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'supabase_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(supabaseProvider));
});

// highest product price, for the slider
final maxPriceProvider = FutureProvider<double>((ref) {
  return ref.watch(productServiceProvider).fetchMaxPrice();
});

final productProvider = AsyncNotifierProvider<ProductNotifier, ProductPage>(
  ProductNotifier.new,
);

class ProductNotifier extends AsyncNotifier<ProductPage> {
  // runs again every time the filter (search, category, price, page) changes
  @override
  Future<ProductPage> build() {
    final filter = ref.watch(productFilterProvider);
    return ref
        .read(productServiceProvider)
        .fetchProducts(
          search: filter.search,
          categoryId: filter.categoryId,
          minPrice: filter.minPrice,
          maxPrice: filter.maxPrice,
          page: filter.page,
        );
  }

  // after add / update / delete we just fetch the current page again
  // so the page contents and the total count stay correct
  Future<void> _reload() async {
    ref.invalidateSelf();
    ref.invalidate(maxPriceProvider);
    await future;
  }

  Future<void> addProduct(Product product) async {
    await ref.read(productServiceProvider).addProduct(product);
    await _reload();
  }

  Future<void> deleteProduct(int id) async {
    await ref.read(productServiceProvider).deleteProduct(id);

    // if we deleted the only item on the last page, go back one page
    final page = ref.read(productFilterProvider).page;
    final itemsOnPage = state.value?.products.length ?? 0;
    if (itemsOnPage == 1 && page > 1) {
      ref.read(productFilterProvider.notifier).setPage(page - 1);
      await future;
    } else {
      await _reload();
    }
  }

  Future<void> updateProduct(Product product) async {
    await ref.read(productServiceProvider).updateProduct(product);
    await _reload();
  }
}
