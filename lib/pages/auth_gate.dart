import 'package:cs_elective_2/pages/login_page.dart';
import 'package:cs_elective_2/pages/Products.dart';
import 'package:cs_elective_2/providers/auth_provider.dart';
import 'package:cs_elective_2/utils/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// decides which screen to show: login or the shop
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session.isLoading) return const _Loading();

    final userId = ref.watch(userIdProvider);
    if (userId == null) return const LoginPage(); // signed out

    // signed in -> load the profile (we need the role)
    final profile = ref.watch(profileProvider);
    return profile.when(
      loading: () => const _Loading(),
      error: (e, _) => _Problem(message: errorMessage(e)),
      data: (p) => p == null
          ? const _Problem(message: 'No profile found for this account.')
          : const ProductsPage(),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _Problem extends ConsumerWidget {
  const _Problem({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
