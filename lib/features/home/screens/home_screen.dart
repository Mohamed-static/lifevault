import "package:flutter/material.dart";
import "../../../models/vault_item.dart";
import "../../../models/category.dart";
import "../../../services/vault_service.dart";
import "../../../core/theme.dart";
import "../../../shared/widgets/vault_item_card.dart";
import "../../vault/screens/add_item_screen.dart";
import "../../vault/screens/item_details_screen.dart";
import "../../vault/screens/search_screen.dart";
import "../../reminders/screens/reminders_screen.dart";
import "../../settings/screens/settings_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _vaultService = VaultService();
  List<VaultItem> _items = [];
  List<VaultItem> _expiringSoon = [];
  Map<String, String> _categoryNames = {};
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
      final cats = await _vaultService.getCategories();
      final catMap = <String, String>{};
      for (final Category c in cats) {
        catMap[c.id] = c.name;
      }
      setState(() { _items = items; _expiringSoon = expiring; _categoryNames = catMap; _isLoading = false; });
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
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
              if (_expiringSoon.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: "Elements", value: "${_items.length}", icon: Icons.folder_outlined, gradient: AppColors.gradientPrimary)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _StatCard(label: "Expirent bientot", value: "${_expiringSoon.length}", icon: Icons.timer_outlined, gradient: const LinearGradient(colors: [AppColors.warning, AppColors.danger]))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_expiringSoon.isNotEmpty) ...[
                    Text("Expirent bientot", style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    ..._expiringSoon.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: VaultItemCard(item: e.value, index: e.key, categoryName: e.value.categoryId != null ? _categoryNames[e.value.categoryId] : null, onTap: () => _openDetails(e.value)))),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text("Tous les elements", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).textTheme.bodyMedium?.color),
                            const SizedBox(height: AppSpacing.sm),
                            Text("Aucun element pour le moment", style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ..._items.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: VaultItemCard(item: e.value, index: e.key, categoryName: e.value.categoryId != null ? _categoryNames[e.value.categoryId] : null, onTap: () => _openDetails(e.value)))),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(onPressed: _openAddItem, child: const Icon(Icons.add_rounded)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({required this.label, required this.value, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}