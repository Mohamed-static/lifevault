import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../models/vault_item.dart";
import "../../../models/category.dart";
import "../../../services/vault_service.dart";
import "../../../core/theme.dart";
import "../../../core/category_icons.dart";
import "../../../shared/widgets/empty_state.dart";
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
  List<Category> _categories = [];
  Map<String, int> _categoryCounts = {};
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
      final counts = <String, int>{};
      for (final item in items) {
        if (item.categoryId != null) {
          counts[item.categoryId!] = (counts[item.categoryId!] ?? 0) + 1;
        }
      }
      setState(() { _items = items; _expiringSoon = expiring; _categories = cats; _categoryCounts = counts; _isLoading = false; });
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

  Widget _sectionHeader(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text("Voir tout", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _attentionTile(VaultItem item) {
    final days = item.daysUntilExpiration ?? 0;
    final isUrgent = days <= 7;
    return InkWell(
      onTap: () => _openDetails(item),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: (isUrgent ? AppColors.dangerMuted : AppColors.warningMuted), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(Icons.event_busy_outlined, size: 18, color: isUrgent ? AppColors.danger : AppColors.warning),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("Expiration proche", style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: isUrgent ? AppColors.dangerMuted : AppColors.warningMuted, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text("${days}j", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUrgent ? AppColors.danger : AppColors.warning)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCell(Category cat) {
    final count = _categoryCounts[cat.id] ?? 0;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColors.borderLight)),
        child: Column(
          children: [
            Icon(categoryIcon(cat.name), size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(cat.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text("$count", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _recentTile(VaultItem item) {
    return InkWell(
      onTap: () => _openDetails(item),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primaryMuted, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(DateFormat("dd MMM").format(item.createdAt), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
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
                Positioned(right: 8, top: 8, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle))),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text("Votre vie importante, au meme endroit.", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                          const SizedBox(width: AppSpacing.sm),
                          Text("Rechercher dans votre coffre...", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  if (_expiringSoon.isNotEmpty) ...[
                    _sectionHeader(context, "A traiter bientot", onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColors.borderLight)),
                      child: Column(
                        children: _expiringSoon.take(3).map((item) => _attentionTile(item)).toList(),
                      ),
                    ),
                  ],
                  if (_categories.isNotEmpty) ...[
                    _sectionHeader(context, "Votre coffre"),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.85,
                      children: _categories.map((cat) => _categoryCell(cat)).toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: _openAddItem,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text("Ajouter"),
                  ),
                  if (_items.isEmpty)
                    EmptyState(
                      icon: Icons.inbox_outlined,
                      title: "Votre coffre est vide",
                      description: "Ajoutez vos documents, recus, garanties et notes importantes pour les garder en securite.",
                      actionLabel: "Ajouter un element",
                      onAction: _openAddItem,
                    )
                  else ...[
                    _sectionHeader(context, "Recemment ajoute"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColors.borderLight)),
                      child: Column(
                        children: _items.take(5).map((item) => _recentTile(item)).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}