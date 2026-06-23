import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Convert a storage_path to a full public URL.
/// Handles both old raw paths (e.g. "userId/mealId/0.jpg") and new full URLs.
String resolvePhotoUrl(SupabaseClient supabase, String storagePath) {
  if (storagePath.startsWith('http')) return storagePath;
  return supabase.storage.from('meal-photos').getPublicUrl(storagePath);
}
