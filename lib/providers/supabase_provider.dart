import 'package:cs_elective_2/services/product_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(supabaseProvider));
});