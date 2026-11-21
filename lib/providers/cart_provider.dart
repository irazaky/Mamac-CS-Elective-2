import 'package:cs_elective_2/models/cart_item.dart';
import 'package:cs_elective_2/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// the cart lives in app state, so it survives screen changes
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  // each method returns an error message, or null if everything is ok

  String? add(Product product) {
    if (product.stock <= 0) return '${product.name} is out of stock';

    final index = state.indexWhere((c) => c.product.id == product.id);

    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: 1)];
      return null;
    }

    final current = state[index];
    if (current.quantity >= product.stock) {
      return 'Only ${product.stock} in stock';
    }

    return setQuantity(product, current.quantity + 1);
  }

  String? setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      remove(product.id);
      return null;
    }
    if (quantity > product.stock) return 'Only ${product.stock} in stock';

    state = [
      for (final c in state)
        if (c.product.id == product.id)
          CartItem(product: product, quantity: quantity)
        else
          c,
    ];
    return null;
  }

  void remove(int productId) {
    state = state.where((c) => c.product.id != productId).toList();
  }

  void clear() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

// total number of items (ex. 2 of A + 1 of B = 3)
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, c) => sum + c.quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, c) => sum + c.subtotal);
});
