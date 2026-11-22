import 'package:supabase_flutter/supabase_flutter.dart';

// turns any error into a short message we can show to the user
String errorMessage(Object error) {
  if (error is AuthException) return error.message;
  if (error is PostgrestException) {
    // 42501 = row level security blocked the action
    if (error.code == '42501') return 'You do not have permission to do that.';
    return error.message;
  }
  return error.toString().replaceFirst('Exception: ', '');
}
