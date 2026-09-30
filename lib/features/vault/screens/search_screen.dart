import "package:flutter/material.dart";
import "../../../models/vault_item.dart";
import "../../../services/vault_service.dart";
import "../../../core/theme.dart";
import "../../../shared/widgets/vault_item_card.dart";
import "item_details_screen.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _vaultService = VaultService();
  List<VaultItem> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _hasSearched = false; });
      return;
    }
    setState(() { _isLoading = true; _hasSearched = true; });
    try {
      final results = await _vaultService.searchItems(query.trim());
      setState(() { _results = results; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  void _openDetails(VaultItem item) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _search,
          decoration: const InputDecoration(
            hintText: "Rechercher un element...",
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () { _controller.clear(); _search(""); },
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 48, color: Theme.of(context).textTheme.bodyMedium?.color),
                        const SizedBox(height: AppSpacing.sm),
                        Text("Recherchez par titre", style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).textTheme.bodyMedium?.color),
                            const SizedBox(height: AppSpacing.sm),
                            Text("Aucun resultat", style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: _results.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: VaultItemCard(item: e.value, index: e.key, onTap: () => _openDetails(e.value)),
                        )).toList(),
                      ),
      ),
    );
  }
}