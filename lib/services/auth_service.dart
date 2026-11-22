import 'package:cs_elective_2/models/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  static const _mobileRedirectUrl = 'io.supabase.cselective2://login-callback/';

  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  // returns true if the user is signed in right away
  // (false means they still need to confirm their email)
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      // the handle_new_user trigger copies these into the profiles table
      data: {'firstname': firstName, 'lastname': lastName},
    );
    return res.session != null;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  // 3rd-party login. on web this redirects to Google and comes back to the app;
  // on mobile it uses the registered deep link callback scheme.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : _mobileRedirectUrl,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // profile + role of the logged in user
  Future<UserProfile?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select('*, roles(role)')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;

    return UserProfile(
      id: data['id'],
      email: data['email'] ?? '',
      firstName: data['firstname'] ?? '',
      lastName: data['lastname'] ?? '',
      role: data['roles']?['role'] ?? 'customer',
    );
  }
}
