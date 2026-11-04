class ProductFilter {
  final String search;
  final int? categoryId;

  const ProductFilter({this.search = '', this.categoryId});

  bool get isActive => search.trim().isNotEmpty || categoryId != null;
}
