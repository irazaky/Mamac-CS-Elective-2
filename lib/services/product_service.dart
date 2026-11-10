import 'package:cs_elective_2/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  // constructor that takes a SupabaseClient instance
  final SupabaseClient _client;
  ProductService(this._client);

  Future<List<Product>> fetchProducts({
    String search = '',
    int? categoryId,
  }) async {
    var query = _client.from('products').select();

    final term = search.trim();
    if (term.isNotEmpty) {
      query = query.ilike('name', '%$term%');
    }

    if (categoryId != null) query = query.eq('category_id', categoryId);

    final data = await query.order('created_at', ascending: false);

    return (data as List<dynamic>).map((item) {
      return Product(
        id: item['id'],
        name: item['name'],
        description: item['description'] ?? "N/A",
        price: double.tryParse(item['price']?.toString() ?? '') ?? 0.0,
        stock: item['stock'],
        categoryId: item['category_id'] ?? 0,
        imageUrl: item['image_url'] ?? "insert fallback url img",
      );
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    await _client.from('products').insert({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'image_url': product.imageUrl,
      'category_id': product.categoryId,
    });
  }

  Future<void> deleteProduct(int id) async {
    final deleted = await _client
        .from('products')
        .delete()
        .eq('id', id)
        .select();

    if (deleted.isEmpty) {
      throw Exception('Product with id $id not found');
    }
  }

  Future<void> updateProduct(Product product) async {
    final updatedProds = await _client
        .from('products')
        .update({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'stock': product.stock,
          'image_url': product.imageUrl,
          'category_id': product.categoryId,
        })
        .eq('id', product.id)
        .select();

    if (updatedProds.isEmpty) {
      throw Exception(
        'Product with id ${product.id} not found or check table RLS.',
      );
    }
  }
}
