import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vault_item.dart';
import '../models/category.dart';
import 'supabase_service.dart';

/// Toute requete est implicitement filtree par les policies RLS
/// (auth.uid() = user_id) definies en base : impossible de lire/modifier
/// les donnees d'un autre utilisateur, meme en cas de bug cote client.
class VaultService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<VaultItem>> getItems() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Utilisateur non authentifie');

    final data = await _client
        .from('vault_items')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => VaultItem.fromJson(e)).toList();
  }

  Future<List<VaultItem>> getExpiringSoon() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Utilisateur non authentifie');

    final now = DateTime.now();
    final in30Days = now.add(const Duration(days: 30));

    final data = await _client
        .from('vault_items')
        .select()
        .eq('user_id', userId)
        .not('expiration_date', 'is', null)
        .lte('expiration_date', in30Days.toIso8601String().split('T').first)
        .order('expiration_date', ascending: true);

    return (data as List).map((e) => VaultItem.fromJson(e)).toList();
  }

  Future<VaultItem> createItem(VaultItem item) async {
    final data = await _client
        .from('vault_items')
        .insert(item.toInsertJson())
        .select()
        .single();

    return VaultItem.fromJson(data);
  }

  Future<VaultItem> updateItem(String id, VaultItem item) async {
    final data = await _client
        .from('vault_items')
        .update(item.toInsertJson())
        .eq('id', id)
        .select()
        .single();

    return VaultItem.fromJson(data);
  }

  Future<void> deleteItem(String id) async {
    await _client.from('vault_items').delete().eq('id', id);
  }

  Future<List<VaultItem>> searchItems(String query) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Utilisateur non authentifie');

    final data = await _client
        .from('vault_items')
        .select()
        .eq('user_id', userId)
        .ilike('title', '%\%')
        .order('created_at', ascending: false);

    return (data as List).map((e) => VaultItem.fromJson(e)).toList();
  }

  Future<List<Category>> getCategories() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Utilisateur non authentifie');

    final data = await _client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('name');

    return (data as List).map((e) => Category.fromJson(e)).toList();
  }
}
