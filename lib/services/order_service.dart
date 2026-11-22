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
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return [];

    var query = _client
        .from('orders')
        .select('*, order_items(*, products(name))');

    if (onlyMine) {
      query = query.eq('user_id', currentUser.id);
    }

    final data = await query.order('created_at', ascending: false);
    final orderRows = data as List<dynamic>;

    // Resolve customer emails for admin view without relying on a direct
    // orders -> profiles FK (orders.user_id references auth.users.id).
    final emailByUserId = <String, String>{};
    if (!onlyMine && orderRows.isNotEmpty) {
      final userIds = orderRows
          .map((o) => o['user_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();
      if (userIds.isNotEmpty) {
        final profilesData = await _client
            .from('profiles')
            .select('id, email')
            .inFilter('id', userIds);
        for (final p in (profilesData as List<dynamic>)) {
          final id = p['id']?.toString();
          final email = p['email']?.toString();
          if (id != null && email != null) {
            emailByUserId[id] = email;
          }
        }
      }
    }

    return orderRows.map((o) {
      final items = (o['order_items'] as List<dynamic>).map((i) {
        final snapshotName = i['product_name'] as String?;
        final joinedName = i['products']?['name'] as String?;
        return OrderItem(
          name: (snapshotName != null && snapshotName.trim().isNotEmpty)
              ? snapshotName
              : (joinedName ?? 'Deleted product'),
          unitPrice: (i['unit_price'] as num).toDouble(),
          quantity: (i['quantity'] as num).toInt(),
        );
      }).toList();

      final userId = o['user_id']?.toString() ?? '';
      return ShopOrder(
        id: (o['id'] as num).toInt(),
        status: o['status']?.toString() ?? 'done',
        total: (o['total'] as num).toDouble(),
        createdAt: DateTime.parse(o['created_at']).toLocal(),
        customer: emailByUserId[userId] ?? userId,
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
