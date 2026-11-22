import 'package:cs_elective_2/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}
