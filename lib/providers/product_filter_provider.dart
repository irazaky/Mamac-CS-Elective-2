import 'package:cs_elective_2/models/product_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() {
    return const ProductFilter();
  }

  // changing any filter sends the user back to page 1

  void setSearch(String search) {
    state = ProductFilter(
      search: search,
      categoryId: state.categoryId,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
    );
  }

  void setCategoryId(int? categoryId) {
    state = ProductFilter(
      search: state.search,
      categoryId: categoryId,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
    );
  }

  void setPriceRange(double? minPrice, double? maxPrice) {
    state = ProductFilter(
      search: state.search,
      categoryId: state.categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  // only the page changes, filters stay the same
  void setPage(int page) {
    state = ProductFilter(
      search: state.search,
      categoryId: state.categoryId,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      page: page,
    );
  }

  void reset() => state = const ProductFilter();
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
      ProductFilterNotifier.new,
    );
