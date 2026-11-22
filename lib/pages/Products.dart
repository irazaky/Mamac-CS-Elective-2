import 'dart:async';
import 'package:cs_elective_2/components/CartIcon.dart';
import 'package:cs_elective_2/models/category.dart';
import 'package:cs_elective_2/models/product.dart';
import 'package:cs_elective_2/models/product_filter.dart';
import 'package:cs_elective_2/models/product_page.dart';
import 'package:cs_elective_2/pages/AddProduct.dart';
import 'package:cs_elective_2/pages/AdminCategoriesPage.dart';
import 'package:cs_elective_2/pages/AdminOrdersPage.dart';
import 'package:cs_elective_2/pages/OrderHistoryPage.dart';
import 'package:cs_elective_2/providers/auth_provider.dart';
import 'package:cs_elective_2/providers/cart_provider.dart';
import 'package:cs_elective_2/providers/category_provider.dart';
import 'package:cs_elective_2/providers/product_filter_provider.dart';
import 'package:cs_elective_2/providers/product_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  RangeValues? _priceRange; // slider value while dragging, null = full range

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
    _search.clear();
    setState(() => _priceRange = null);
    ref.read(productFilterProvider.notifier).reset();
  }

  void _addToCart(Product p) {
    final message = ref.read(cartProvider.notifier).add(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? '${p.name} added to cart')),
    );
  }

  void _showProductDetails(Product p, bool isAdmin) {
    final categories = ref.read(categoriesProvider).value ?? const <Category>[];
    final categoryName = categories
        .where((c) => c.id == p.categoryId)
        .map((c) => c.name)
        .firstOrNull;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    child: Image.network(
                      p.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₱${p.price.toStringAsFixed(2)}',
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (categoryName != null)
                    Chip(
                      avatar: const Icon(Icons.category, size: 16),
                      label: Text(categoryName),
                      visualDensity: VisualDensity.compact,
                    ),
                  Chip(
                    avatar: const Icon(Icons.inventory_2, size: 16),
                    label: Text(
                      p.stock > 0 ? '${p.stock} in stock' : 'Out of stock',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                (p.description != null && p.description!.trim().isNotEmpty)
                    ? p.description!
                    : 'No description available.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              if (!isAdmin) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: p.stock > 0
                      ? () {
                          Navigator.pop(sheetContext);
                          _addToCart(p);
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(p.stock > 0 ? 'Add to cart' : 'Out of stock'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    final isAdmin = ref.watch(isAdminProvider); // admin sees management buttons

    Future<void> confirmDelete(Product p) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${errorMessage(e)}')),
        );
      }
    }

    void editProduct(Product p) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddProductPage(product: p)),
      );
    }

    final logoutButton = IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Log out',
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Products (Admin)' : 'Comics Shop'),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.category),
                  tooltip: 'Categories',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminCategoriesPage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long),
                  tooltip: 'Orders',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
                  ),
                ),
                logoutButton,
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'My orders',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                  ),
                ),
                const CartIcon(),
                logoutButton,
              ],
      ),
      // only admins can add products
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage(e)),
                    TextButton(
                      onPressed: () => ref.invalidate(productProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (productPage) {
                final products = productPage.products;
                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productProvider);
                    ref.invalidate(maxPriceProvider);
                    await ref.read(productProvider.future);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      return Card(
                        elevation: i % 2 == 0 ? 4 : 2,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showProductDetails(p, isAdmin),
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
                                                  if (progress == null) {
                                                    return child;
                                                  }
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

                                    if (isAdmin)
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
                                                icon: const Icon(Icons.edit),
                                                onPressed: () => editProduct(p),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
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
                                                onPressed: () =>
                                                    confirmDelete(p),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('₱${p.price.toStringAsFixed(2)}'),
                                    if (isAdmin) Text('Stock: ${p.stock}'),
                                    if (p.stock <= 0)
                                      const Text(
                                        'Out of stock',
                                        style: TextStyle(color: Colors.red),
                                      )
                                    else if (p.stock < 5)
                                      const Text(
                                        'Low stock',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    // customers get "add to cart" instead of edit/delete
                                    if (!isAdmin) ...[
                                      const SizedBox(height: 4),
                                      ElevatedButton.icon(
                                        onPressed: p.stock > 0
                                            ? () => _addToCart(p)
                                            : null,
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 18,
                                        ),
                                        label: const Text('Add to cart'),
                                      ),
                                    ],
                                  ],
                                ),
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
          ),
          _buildPaginationBar(productsAsync),
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
          categoriesAsync.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categories unavailable: ${errorMessage(e)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(categoriesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
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
          ),
          _buildPriceSlider(filter.isActive),
        ],
      ),
    );
  }

  Widget _buildPriceSlider(bool hasActiveFilters) {
    final maxPriceAsync = ref.watch(maxPriceProvider);
    final maxPrice = maxPriceAsync.value ?? 0;

    if (maxPriceAsync.hasError) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => ref.invalidate(maxPriceProvider),
          child: const Text('Retry price filter'),
        ),
      );
    }

    if (maxPrice <= 0) {
      if (!hasActiveFilters) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.filter_alt_off, size: 18),
          label: const Text('Reset filters'),
        ),
      );
    }

    final max = maxPrice.ceilToDouble();
    // clamp in case the max price dropped (ex. after deleting the priciest product)
    final saved = _priceRange ?? RangeValues(0, max);
    final range = RangeValues(
      saved.start.clamp(0, max).toDouble(),
      saved.end.clamp(0, max).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price: ₱${range.start.round()} - ₱${range.end.round()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (hasActiveFilters)
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        RangeSlider(
          values: range,
          min: 0,
          max: max,
          labels: RangeLabels(
            '₱${range.start.round()}',
            '₱${range.end.round()}',
          ),
          // while dragging: only update the slider itself
          onChanged: (values) => setState(() => _priceRange = values),
          // when the user lets go: update the filter (this triggers the query)
          onChangeEnd: (values) {
            // if the slider is back to full range, remove the price filter
            final isFull = values.start <= 0 && values.end >= max;
            ref
                .read(productFilterProvider.notifier)
                .setPriceRange(
                  isFull ? null : values.start.roundToDouble(),
                  isFull ? null : values.end.roundToDouble(),
                );
          },
        ),
      ],
    );
  }

  Widget _buildPaginationBar(AsyncValue<ProductPage> productsAsync) {
    final page = ref.watch(productFilterProvider).page;
    final total = productsAsync.value?.total ?? 0;
    final totalPages = total == 0 ? 1 : (total / productsPerPage).ceil();
    final loading = productsAsync.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (page > 1 && !loading)
                ? () =>
                      ref.read(productFilterProvider.notifier).setPage(page - 1)
                : null,
          ),
          Text('Page $page of $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: (page < totalPages && !loading)
                ? () =>
                      ref.read(productFilterProvider.notifier).setPage(page + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
