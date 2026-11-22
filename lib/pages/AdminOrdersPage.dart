import 'package:cs_elective_2/components/order_tile.dart';
import 'package:cs_elective_2/providers/auth_provider.dart';
import 'package:cs_elective_2/providers/order_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// admin: all orders, and the status can be changed
class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  static const statuses = ['pending', 'done', 'cancelled'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'You do not have permission to view all orders.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage(e)),
              TextButton(
                onPressed: () => ref.invalidate(allOrdersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allOrdersProvider);
              await ref.read(allOrdersProvider.future);
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                final options = statuses.contains(order.status)
                    ? statuses
                    : [order.status, ...statuses];
                return OrderTile(
                  order: order,
                  showCustomer: true,
                  footer: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        const Text('Status: '),
                        DropdownButton<String>(
                          value: order.status,
                          items: [
                            for (final s in options)
                              DropdownMenuItem(value: s, child: Text(s)),
                          ],
                          onChanged: (value) async {
                            if (value == null || value == order.status) return;
                            try {
                              await ref
                                  .read(allOrdersProvider.notifier)
                                  .setStatus(order.id, value);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage(e))),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
