import 'package:cs_elective_2/pages/OrderConfirmationPage.dart';
import 'package:cs_elective_2/providers/cart_provider.dart';
import 'package:cs_elective_2/providers/order_provider.dart';
import 'package:cs_elective_2/providers/product_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(checkoutControllerProvider.notifier)
        .checkout();

    if (result == null || !context.mounted) return; // error is shown by listener

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderConfirmationPage(result: result)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final count = ref.watch(cartCountProvider);
    final checkingOut = ref.watch(checkoutControllerProvider).isLoading;
    final latestProducts = ref.watch(productProvider).value?.products ?? const [];

    // show checkout errors (ex. not enough stock)
    ref.listen(checkoutControllerProvider, (prev, next) {
      if (next.hasError) _showMessage(context, errorMessage(next.error!));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (_, i) {
                final item = cart[i];
                final freshProduct =
                    latestProducts
                        .where((prod) => prod.id == item.product.id)
                        .firstOrNull ??
                    item.product;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      width: 48,
                      child:
                          freshProduct.imageUrl != null &&
                              freshProduct.imageUrl!.isNotEmpty
                          ? Image.network(
                              freshProduct.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image_not_supported),
                    ),
                    title: Text(freshProduct.name),
                    subtitle: Text(
                      '₱${freshProduct.price.toStringAsFixed(2)} each'
                      'Subtotal: ₱${(freshProduct.price * item.quantity).toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: checkingOut
                              ? null
                              : () => ref
                                    .read(cartProvider.notifier)
                                    .setQuantity(
                                      freshProduct,
                                      item.quantity - 1,
                                    ),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: checkingOut
                              ? null
                              : () {
                                  final msg = ref
                                      .read(cartProvider.notifier)
                                      .setQuantity(
                                        freshProduct,
                                        item.quantity + 1,
                                      );
                                  if (msg != null) _showMessage(context, msg);
                                },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: checkingOut
                              ? null
                              : () => ref
                                    .read(cartProvider.notifier)
                                    .remove(freshProduct.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$count item${count == 1 ? '' : 's'}'),
                          Text(
                            'Total: ₱${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: checkingOut
                          ? null
                          : () => _checkout(context, ref),
                      child: checkingOut
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
