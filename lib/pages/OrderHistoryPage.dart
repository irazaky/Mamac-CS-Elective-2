import 'package:cs_elective_2/components/order_tile.dart';
import 'package:cs_elective_2/providers/order_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// customer: my past orders, newest first
class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage(e)),
              TextButton(
                onPressed: () => ref.invalidate(myOrdersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('You have no orders yet'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myOrdersProvider);
              await ref.read(myOrdersProvider.future);
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) => OrderTile(order: orders[i]),
            ),
          );
        },
      ),
    );
  }
}
