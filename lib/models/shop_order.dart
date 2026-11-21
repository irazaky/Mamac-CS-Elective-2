class OrderItem {
  final String name;
  final double unitPrice;
  final int quantity;

  OrderItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });
}

class ShopOrder {
  final int id;
  final String status;
  final double total;
  final DateTime createdAt;
  final String customer; // email of the buyer (shown on the admin screen)
  final List<OrderItem> items;

  ShopOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.customer,
    required this.items,
  });
}

// what place_order() gives back after a successful checkout
class OrderResult {
  final int orderId;
  final double total;

  OrderResult({required this.orderId, required this.total});
}
