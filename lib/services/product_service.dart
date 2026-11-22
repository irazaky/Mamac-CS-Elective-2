import 'dart:typed_data';
import 'package:cs_elective_2/models/product.dart';
import 'package:cs_elective_2/models/product_filter.dart';
import 'package:cs_elective_2/models/product_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  // constructor that takes a SupabaseClient instance
  final SupabaseClient _client;
  ProductService(this._client);

  // gets ONE page of products. filtering + pagination are done in the supabase query
  Future<ProductPage> fetchProducts({
    String search = '',
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
  }) async {
    var query = _client.from('products').select();

    final term = search.trim();
    if (term.isNotEmpty) {
      query = query.ilike('name', '%$term%');
    }

    if (categoryId != null) query = query.eq('category_id', categoryId);

    // price range
    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);

    // page 1 -> rows 0..7, page 2 -> rows 8..15, etc.
    final from = (page - 1) * productsPerPage;
    final to = from + productsPerPage - 1;

    // count() also gives us the total matching rows (ignores the range),
    // so we can compute how many pages there are
    final response = await query
        .order('created_at', ascending: false)
        .range(from, to)
        .count(CountOption.exact);

    final products = (response.data as List<dynamic>).map((item) {
      return Product(
        id: item['id'],
        name: item['name'],
        description: item['description'],
        price: double.tryParse(item['price']?.toString() ?? '') ?? 0.0,
        stock: item['stock'] ?? 0,
        categoryId: item['category_id'] ?? 0,
        imageUrl: item['image_url'] as String?,
      );
    }).toList();

    return ProductPage(products: products, total: response.count);
  }

  // highest price in the table, used as the max of the price slider
  Future<double> fetchMaxPrice() async {
    final data = await _client
        .from('products')
        .select('price')
        .order('price', ascending: false)
        .limit(1);

    if (data.isEmpty) return 0;
    return double.tryParse(data.first['price'].toString()) ?? 0;
  }

  Future<void> addProduct(Product product) async {
    await _client.from('products').insert({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'stock': product.stock,
      'image_url': (product.imageUrl == null || product.imageUrl!.trim().isEmpty)
          ? null
          : product.imageUrl!.trim(),
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
          'image_url':
              (product.imageUrl == null || product.imageUrl!.trim().isEmpty)
              ? null
              : product.imageUrl!.trim(),
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

  // uploads an image to the product-images bucket and returns its public link
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final lower = fileName.toLowerCase();
    var contentType = 'image/jpeg';
    if (lower.endsWith('.png')) contentType = 'image/png';
    if (lower.endsWith('.webp')) contentType = 'image/webp';
    if (lower.endsWith('.gif')) contentType = 'image/gif';

    final bucket = _client.storage.from('product-images');
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType),
    );
    return bucket.getPublicUrl(path);
  }
}
