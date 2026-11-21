import 'package:cs_elective_2/models/shop_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// one order in a list. tap to see the items.
// used by the customer order history and the admin order list
class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    this.showCustomer = false,
    this.footer,
  });

  final ShopOrder order;
  final bool showCustomer;
  final Widget? footer; // ex. the status dropdown for admins

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, y h:mm a').format(order.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          'Order #${order.id}  •  ₱${order.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${order.status.toUpperCase()}  •  $date'
          '${showCustomer ? '\n${order.customer}' : ''}',
        ),
        children: [
          for (final item in order.items)
            ListTile(
              dense: true,
              title: Text(item.name),
              subtitle: Text(
                '${item.quantity} x ₱${item.unitPrice.toStringAsFixed(2)}',
              ),
              trailing: Text(
                '₱${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
              ),
            ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
