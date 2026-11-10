import 'package:cs_elective_2/models/product_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() {
    return const ProductFilter();
  }

  void setSearch(String search) {
    state = ProductFilter(search: search, categoryId: state.categoryId);
  }

  void setCategoryId(int? categoryId) {
    state = ProductFilter(search: state.search, categoryId: categoryId);
  }

  void reset() => state = const ProductFilter();
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
      ProductFilterNotifier.new,
    );
