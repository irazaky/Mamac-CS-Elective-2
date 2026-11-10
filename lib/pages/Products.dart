import 'package:cs_elective_2/models/product.dart';
import 'package:cs_elective_2/pages/AddProduct.dart';
import 'package:cs_elective_2/providers/category_provider.dart';
import 'package:cs_elective_2/providers/product_filter_provider.dart';
import 'package:cs_elective_2/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  @override
  final _search = TextEditingController();
  Timer? _debounce;

  // todo: add ui for search and category filtera

  @override
  void initState() {
    super.initState();
    _search.text = ref.read(productFilterProvider).search;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // so the clear (x) button appears/disappears
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productFilterProvider.notifier).setSearch(value);
    });
  }

  void _clearFilters() {
    _debounce?.cancel();
    _search.text = '';
    ref.read(productFilterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);

    Future<void> _confirmDelete(Product p) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${p.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (ok != true) return;

      try {
        await ref.read(productProvider.notifier).deleteProduct(p.id);
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product deleted')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }

    void _editProduct(Product p) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddProductPage(product: p)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_bag), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productProvider);
                    await ref.read(productProvider.future);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      return Card(
                        elevation: i % 2 == 0 ? 4 : 2,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  p.imageUrl != null && p.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          p.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                ),
                                              ),
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null)
                                                  return child;
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                          ),
                                        ),

                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white70,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 20,
                                            icon: const Icon(
                                              Icons.edit,
                                              // color: Colors.blue,
                                            ),
                                            onPressed: () => _editProduct(p),
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white70,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 20,
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () => _confirmDelete(p),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('₱${p.price.toStringAsFixed(2)}'),
                                  if (p.stock < 5)
                                    const Text(
                                      'Low stock',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filter = ref.watch(productFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search products',
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        _onSearchChanged('');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          categoriesAsync.maybeWhen(
            data: (categories) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: filter.categoryId == null,
                      onSelected: (_) => ref
                          .read(productFilterProvider.notifier)
                          .setCategoryId(null),
                    ),
                  ),
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: filter.categoryId == c.id,
                        onSelected: (_) => ref
                            .read(productFilterProvider.notifier)
                            .setCategoryId(c.id),
                      ),
                    ),
                ],
              ),
            ),
            orElse: () => const SizedBox(height: 40), // loading or error
          ),
        ],
      ),
    );
  }
}
