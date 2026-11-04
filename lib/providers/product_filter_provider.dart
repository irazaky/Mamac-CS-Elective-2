import 'package:cs_elective_2/models/product_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() {
    return const ProductFilter();
  }
}
