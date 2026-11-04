import 'package:cs_elective_2/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _client;
  ProductService(this._client);

  Future<List<Product>> fetchProducts() async {
    final data = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

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
}
