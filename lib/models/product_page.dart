import 'package:cs_elective_2/models/product.dart';

// one page of products + the total number of products that match the filters
class ProductPage {
  final List<Product> products;
  final int total;

  const ProductPage({required this.products, required this.total});
}
