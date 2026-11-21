import 'package:cs_elective_2/models/cart_item.dart';
import 'package:cs_elective_2/models/shop_order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient _client;
  OrderService(this._client);

  // we only send product ids and quantities.
  // the database function looks up the real names, prices and stock.
  Future<OrderResult> placeOrder(List<CartItem> cart) async {
    final items = [
      for (final c in cart) {'product_id': c.product.id, 'quantity': c.quantity},
    ];

    final data = await _client.rpc('place_order', params: {'items': items});

    final row = (data as List).first;
    return OrderResult(
      orderId: row['new_order_id'],
      total: (row['order_total'] as num).toDouble(),
    );
  }

  // RLS decides what comes back: customers only get their own orders,
  // admins get everything. onlyMine just makes it explicit.
  Future<List<ShopOrder>> fetchOrders({bool onlyMine = false}) async {
    var query = _client
        .from('orders')
        .select('*, order_items(*), profiles(email)');

    if (onlyMine) {
      query = query.eq('user_id', _client.auth.currentUser!.id);
    }

    final data = await query.order('created_at', ascending: false);

    return data.map((o) {
      final items = (o['order_items'] as List<dynamic>).map((i) {
        return OrderItem(
          name: i['product_name'],
          unitPrice: (i['unit_price'] as num).toDouble(),
          quantity: i['quantity'],
        );
      }).toList();

      return ShopOrder(
        id: o['id'],
        status: o['status'],
        total: (o['total'] as num).toDouble(),
        createdAt: DateTime.parse(o['created_at']).toLocal(),
        customer: o['profiles']?['email'] ?? '',
        items: items,
      );
    }).toList();
  }

  Future<void> updateStatus(int id, String status) async {
    final rows = await _client
        .from('orders')
        .update({'status': status})
        .eq('id', id)
        .select();

    if (rows.isEmpty) {
      throw Exception('Could not update the order (admin only).');
    }
  }
}
