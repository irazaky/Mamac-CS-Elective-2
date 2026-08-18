import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FruitListPage(),
      routes: [
        GoRoute(
          path: 'fruit/:name',
          builder: (context, state) {
            final fruitName = state.pathParameters['name'] ?? '';
            return FruitDetailPage(fruitName: fruitName);
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  final List<String> fruits = const [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Mango',
    'Watermelon'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fruit List')),
      body: ListView.builder(
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          final fruit = fruits[index];
          return ListTile(
            title: Text(fruit),
            onTap: () {
              context.go('/fruit/${fruit.toLowerCase()}');
            },
          );
        },
      ),
    );
  }
}

class FruitDetailPage extends StatelessWidget {
  final String fruitName;
  const FruitDetailPage({super.key, required this.fruitName});
  final Map<String, String> fruitEmojis = const {
    'apple': '🍎',
    'banana': '🍌',
    'orange': '🍊',
    'grapes': '🍇',
    'mango': '🥭',
    'watermelon': '🍉',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = fruitEmojis[fruitName.toLowerCase()] ?? '❓';

    return Scaffold(
      appBar: AppBar(title: Text(fruitName.toUpperCase())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 20),
            Text(
              'Showing illustration for $fruitName',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}