import "package:flutter/material.dart";
import "../../../models/vault_item.dart";
import "../../../services/vault_service.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";
import "../../../shared/widgets/vault_item_card.dart";
import "../../vault/screens/add_item_screen.dart";
import "../../vault/screens/item_details_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _vaultService = VaultService();
  final _authService = AuthService();
  List<VaultItem> _items = [];
  List<VaultItem> _expiringSoon = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final items = await _vaultService.getItems();
      final expiring = await _vaultService.getExpiringSoon();
      setState(() { _items = items; _expiringSoon = expiring; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  void _openDetails(VaultItem item) async {
    final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)));
    if (changed == true) _loadData();
  }

  void _openAddItem() async {
    final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
    if (created == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LifeVault"),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _authService.signOut())],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: "Elements", value: "${_items.length}", color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: "Expirent bientot", value: "${_expiringSoon.length}", color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_expiringSoon.isNotEmpty) ...[
                    const Text("Expirent bientot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._expiringSoon.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: VaultItemCard(item: item, onTap: () => _openDetails(item)))),
                    const SizedBox(height: 24),
                  ],
                  const Text("Tous les elements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_items.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text("Aucun element pour le moment", style: TextStyle(color: AppColors.textSecondary)))),
                  ..._items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: VaultItemCard(item: item, onTap: () => _openDetails(item)))),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(onPressed: _openAddItem, child: const Icon(Icons.add)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
