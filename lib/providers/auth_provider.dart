import 'package:cs_elective_2/models/user_profile.dart';
import 'package:cs_elective_2/providers/cart_provider.dart';
import 'package:cs_elective_2/providers/category_provider.dart';
import 'package:cs_elective_2/providers/product_filter_provider.dart';
import 'package:cs_elective_2/providers/product_provider.dart';
import 'package:cs_elective_2/providers/supabase_provider.dart';
import 'package:cs_elective_2/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseProvider));
});

// the current session. emits again every time the user logs in or out
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final service = ref.watch(authServiceProvider);
  yield service.currentSession;
  await for (final state in service.authChanges) {
    yield state.session;
  }
});

// only the user id, so nothing rebuilds when the token is just refreshed
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).value?.user.id;
});

// profile + role of the logged in user
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return null;
  return ref.read(authServiceProvider).fetchProfile();
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).value?.isAdmin ?? false;
});

// login / sign up / logout actions. the state is only used for loading + errors
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authServiceProvider)
          .signIn(email: email, password: password),
    );
  }

  // returns true if the user is signed in right after signing up
  Future<bool> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    state = const AsyncLoading();
    var signedIn = false;
    state = await AsyncValue.guard(() async {
      signedIn = await ref
          .read(authServiceProvider)
          .signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          );
    });
    return signedIn;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signInWithGoogle(),
    );
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();

    // the cart is emptied on logout and old data is thrown away
    ref.read(cartProvider.notifier).clear();
    ref.invalidate(productFilterProvider);
    ref.invalidate(productProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(maxPriceProvider);
  }
}
