import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ShopBrowserApp());
}

// ============================================
// DATA MODEL - PRODUCTS
// ============================================

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
  });
}

// Product catalog - combined from both files
const List<Product> products = [
  Product(
    id: 1,
    name: 'Absolute Wonder Woman #15',
    category: 'DC Comic Book',
    price: 799,
    description: 'The first meeting of two Absolute heroes has arrived at last! The Mark of Hecate at a crime scene in Gotham draws Wonder Woman into Batman\'s orbit in dramatic fashion.',
    imageUrl: 'https://s3.amazonaws.com/comicgeeks/comics/covers/large-7164499.jpg?1778551074',
  ),
  Product(
    id: 2,
    name: 'Far Sector: The Deluxe Edition',
    category: 'DC Comic Book',
    price: 2999,
    description: 'Far Sector follows rookie Green Lantern Sojourner "Jo" Mullein as she investigates the first murder in 500 years within a massive alien metropolis where all biological and artificial citizens have had their emotions genetically suppressed to maintain peace.',
    imageUrl: 'https://m.media-amazon.com/images/I/918CT0cE05L._AC_UF1000,1000_QL80_.jpg',
  ),
  Product(
    id: 3,
    name: 'All Star Superman: The Deluxe Edition',
    category: 'DC Comic Book',
    price: 2399,
    description: 'After receiving a terminal overdose of solar radiation orchestrated by Lex Luthor, a dying Superman spends his final year completing mythic labors to secure Earth\'s future before sacrificing himself to save the sun.',
    imageUrl: 'https://www.gothamcentralcomics.com/cdn/shop/files/9781799506959.jpg?v=1744399425',
  ),
  Product(
    id: 4,
    name: 'Marvels: The Deluxe Edition',
    category: 'Marvel Comic Book',
    price: 2499,
    description: 'Marvels is a landmark 1994 comic book series written by Kurt Busiek and painted by Alex Ross that retells the early history of the Marvel Universe from the perspective of Phil Sheldon, an ordinary New York photojournalist witnessing the rise of superheroes.',
    imageUrl: 'https://static.wikia.nocookie.net/marveldatabase/images/7/7d/Marvels_Vol_1_2.jpg/revision/latest?cb=20191201213846',
  ),
  Product(
    id: 5,
    name: 'Kingdom Come: The Deluxe Edition',
    category: 'DC Comic Book',
    price: 2499,
    description: 'In a dystopian future, a retired Superman and the classic Justice League return to clash with a reckless, violent new generation of heroes while an apocalyptic war looms.',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5XPCxsvxOuM6CrI4fRaDbwt1E43_eT0Jou_eqRljeFlrFiVTsaw5h8gkP&s=10',
  ),
  Product(
    id: 6,
    name: 'Supergirl: Woman of Tomorrow The Deluxe Edition',
    category: 'DC Comic Book',
    price: 2499,
    description: 'Supergirl: Woman of Tomorrow follows Kara Zor-El and a young alien girl named Ruthye as they journey across the galaxy on a cosmic quest for revenge against the brutal mercenary who murdered Ruthye\'s father.',
    imageUrl: 'https://m.media-amazon.com/images/I/81WCblz7GnL._AC_UF1000,1000_QL80_.jpg',
  ),
  Product(
    id: 7,
    name: 'Thor: God of Thunder (2013) Vol. 1: Gorr the God Butcher',
    category: 'Marvel Comic Book',
    price: 1299,
    description: 'The narrative spans three versions of Thor as they confront the tragic and ruthless alien Gorr, who wields All-Black the Necrosword to slaughter deities across the cosmos.',
    imageUrl: 'https://m.media-amazon.com/images/I/61Wy0eFiDRL._AC_UF1000,1000_QL80_.jpg',
  ),
  Product(
    id: 8,
    name: 'Astonishing X-Men Modern Era Collection (2024)',
    category: 'Marvel Comic Book',
    price: 4199,
    description: 'Cyclops and Emma Frost lead a newly assembled team of X-Men to publicly champion mutant heroism while fighting a dangerous "mutant cure," a sentient Danger Room, and an alien conspiracy tied to the destruction of Earth',
    imageUrl: 'https://m.media-amazon.com/images/I/51ZN+MwVVPL._UF1000,1000_QL80_.jpg',
  ),
];

// ============================================
// CART STATE
// ============================================

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get total {
    double sum = 0;
    for (var item in _items) {
      sum += item.subtotal;
    }
    return sum;
  }

  void add(Product product) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == product.id) {
        _items[i].quantity++;
        notifyListeners();
        return;
      }
    }
    _items.add(CartItem(product: product));
    notifyListeners();
  }

  void increase(Product product) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == product.id) {
        _items[i].quantity++;
        notifyListeners();
        return;
      }
    }
  }

  void decrease(Product product) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == product.id) {
        if (_items[i].quantity > 1) {
          _items[i].quantity--;
        } else {
          _items.removeAt(i);
        }
        notifyListeners();
        return;
      }
    }
  }

  void remove(Product product) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].product.id == product.id) {
        _items.removeAt(i);
        notifyListeners();
        return;
      }
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ============================================
// THEME CONFIGURATION
// ============================================

ThemeData buildAppTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 62, 180, 213),
      brightness: brightness,
    ),
    scaffoldBackgroundColor: isDark ? const Color(0xFF101116) : const Color.fromARGB(255, 223, 255, 253),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: isDark ? const Color.fromARGB(255, 55, 55, 55) : const Color.fromARGB(255, 218, 235, 234),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: isDark ? Colors.white60 : Colors.black54,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
  );
}

// ============================================
// APP SHELL
// ============================================

class ShopBrowserApp extends StatefulWidget {
  const ShopBrowserApp({super.key});

  @override
  State<ShopBrowserApp> createState() => _ShopBrowserAppState();
}

class _ShopBrowserAppState extends State<ShopBrowserApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final CartController _cart = CartController();

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(
          cart: _cart,
          onThemeToggle: toggleTheme,
          isDark: _themeMode == ThemeMode.dark,
        ),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final String idStr = state.pathParameters['id'] ?? '';
          final int? id = int.tryParse(idStr);
          Product? product;
          for (var p in products) {
            if (p.id == id) {
              product = p;
              break;
            }
          }
          if (product == null) {
            return const NotFoundPage();
          }
          return ProductDetailPage(
            product: product,
            cart: _cart,
          );
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => CartPage(
          cart: _cart,
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => CheckoutPage(
          cart: _cart,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Davao Comic Shop',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      routerConfig: _router,
    );
  }
}

// ============================================
// SHARED WIDGETS
// ============================================

class ProductImage extends StatelessWidget {
  final Product product;
  final double? height;

  const ProductImage({
    super.key,
    required this.product,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        product.imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.fitHeight,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined, size: 48),
          );
        },
      ),
    );
  }
}

class CartBadge extends StatelessWidget {
  final int itemCount;

  const CartBadge({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cart',
      onPressed: () => context.go('/cart'),
      icon: Stack(
        alignment: Alignment.topRight,
        children: [
          const Icon(Icons.shopping_cart_outlined),
          if (itemCount > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// HOME PAGE
// ============================================

class HomePage extends StatelessWidget {
  final CartController cart;
  final VoidCallback onThemeToggle;
  final bool isDark;

  const HomePage({
    super.key,
    required this.cart,
    required this.onThemeToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Davao Comic Shop'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: onThemeToggle,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          AnimatedBuilder(
            animation: cart,
            builder: (context, child) => CartBadge(itemCount: cart.itemCount),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int columns = 2;
          if (constraints.maxWidth >= 700) {
            columns = 3;
          }
          if (constraints.maxWidth >= 1100) {
            columns = 4;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What comic would you like today?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enjoy various comic books from DC and Marvel!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth >= 700 ? 0.82 : 0.68,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/product/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProductImage(product: product),
              ),
              const SizedBox(height: 10),
              Text(
                product.category.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 3),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '₱${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// PRODUCT DETAIL PAGE - COMPLETE
// ============================================

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final CartController cart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.cart,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _added = false;

  void _addToCart() {
    widget.cart.add(widget.product);
    setState(() {
      _added = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart.'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          AnimatedBuilder(
            animation: widget.cart,
            builder: (context, child) => CartBadge(itemCount: widget.cart.itemCount),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 800;

          final Widget imageWidget = ProductImage(
            product: product,
            height: isWide ? 520 : 330,
          );

          final Widget detailsWidget = Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addToCart,
                    icon: Icon(_added ? Icons.check_circle_outline : Icons.add_shopping_cart),
                    label: Text(_added ? 'Added to Cart' : 'Add to Cart'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/cart'),
                    child: const Text('View Cart'),
                  ),
                ),
              ],
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: imageWidget),
                      const SizedBox(width: 20),
                      Expanded(child: SizedBox(height: 520, child: detailsWidget)),
                    ],
                  )
                : Column(
                    children: [
                      imageWidget,
                      const SizedBox(height: 4),
                      SizedBox(height: 430, child: detailsWidget),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

// ============================================
// CART PAGE - COMPLETE
// ============================================

class CartPage extends StatelessWidget {
  final CartController cart;

  const CartPage({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, child) {
          if (cart.items.isEmpty) {
            return const EmptyCart();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 800;

              final Widget cartList = ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return CartItemCard(
                    item: cart.items[index],
                    cart: cart,
                  );
                },
              );

              final Widget summaryWidget = Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Items'),
                            Text('${cart.itemCount}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total'),
                            Text(
                              '₱${cart.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => context.go('/checkout'),
                            child: const Text('Proceed to Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cartList),
                    SizedBox(width: 360, child: summaryWidget),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(child: cartList),
                  summaryWidget,
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController cart;

  const CartItemCard({
    super.key,
    required this.item,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: ProductImage(product: item.product),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('₱${item.product.price.toStringAsFixed(2)} each'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => cart.decrease(item.product),
                        icon: const Icon(Icons.remove),
                        visualDensity: VisualDensity.compact,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${item.quantity}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => cart.increase(item.product),
                        icon: const Icon(Icons.add),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => cart.remove(item.product),
                  icon: const Icon(Icons.delete_outline),
                ),
                const SizedBox(height: 10),
                Text(
                  '₱${item.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Add a product before checking out.'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// CHECKOUT PAGE - COMPLETE
// ============================================

class CheckoutPage extends StatelessWidget {
  final CartController cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cart,
      builder: (context, child) {
        if (cart.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Checkout'),
              centerTitle: false,
              elevation: 0,
            ),
            body: const EmptyCart(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout Confirmation'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/cart'),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 76,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Order Confirmed!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Thank you for shopping with Davao Comic Shop.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} × ${item.quantity}',
                                    ),
                                  ),
                                  Text(
                                    '₱${item.subtotal.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₱${cart.total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      cart.clear();
                      context.go('/');
                    },
                    child: const Text('Back to Shop'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================
// NOT FOUND PAGE
// ============================================

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Page not found.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}