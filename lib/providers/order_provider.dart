import 'package:cs_elective_2/models/shop_order.dart';
import 'package:cs_elective_2/providers/cart_provider.dart';
import 'package:cs_elective_2/providers/product_provider.dart';
import 'package:cs_elective_2/providers/supabase_provider.dart';
import 'package:cs_elective_2/services/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(supabaseProvider));
});

// order history of the logged in customer, newest first
final myOrdersProvider = FutureProvider.autoDispose<List<ShopOrder>>((ref) {
  return ref.watch(orderServiceProvider).fetchOrders(onlyMine: true);
});

// all orders (admin only, RLS blocks everyone else)
final allOrdersProvider =
    AsyncNotifierProvider.autoDispose<AllOrdersNotifier, List<ShopOrder>>(
      AllOrdersNotifier.new,
    );

class AllOrdersNotifier extends AsyncNotifier<List<ShopOrder>> {
  @override
  Future<List<ShopOrder>> build() {
    return ref.read(orderServiceProvider).fetchOrders();
  }

  Future<void> setStatus(int orderId, String status) async {
    await ref.read(orderServiceProvider).updateStatus(orderId, status);
    ref.invalidateSelf();
    await future;
  }
}

// checkout button
final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, OrderResult?>(
      CheckoutController.new,
    );

class CheckoutController extends AsyncNotifier<OrderResult?> {
  @override
  Future<OrderResult?> build() async {
    return null;
  }

  // returns the saved order, or null if it failed (the error is in state)
  Future<OrderResult?> checkout() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(orderServiceProvider).placeOrder(cart),
    );

    // stock changed (or was out of date), so reload the products either way
    ref.invalidate(productProvider);

    final result = state.value;
    if (result != null) {
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(myOrdersProvider);
    }
    return result;
  }
}
