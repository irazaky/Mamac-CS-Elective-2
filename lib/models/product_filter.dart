// how many products to show per page
const int productsPerPage = 8;

class ProductFilter {
  final String search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final int page; // starts at 1

  const ProductFilter({
    this.search = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
  });

  bool get isActive =>
      search.trim().isNotEmpty ||
      categoryId != null ||
      minPrice != null ||
      maxPrice != null;
}
