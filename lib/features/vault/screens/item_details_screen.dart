import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../models/vault_item.dart";
import "../../../services/vault_service.dart";
import "../../../services/reminder_service.dart";
import "../../../core/theme.dart";

class ItemDetailsScreen extends StatefulWidget {
  final VaultItem item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final _vaultService = VaultService();
  final _reminderService = ReminderService();
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer cet element ?"),
        content: const Text("Cette action est irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() { _isDeleting = true; });
    try {
      await _reminderService.deleteRemindersForItem(widget.item.id);
      await _vaultService.deleteItem(widget.item.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _isDeleting = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: _isDeleting ? null : _handleDelete)],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.description != null) ...[
                      const Text("Description", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(item.description!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                    ],
                    const Text("Date de creation", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(DateFormat("dd/MM/yyyy").format(item.createdAt), style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    if (item.expirationDate != null) ...[
                      const Text("Date d expiration", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(DateFormat("dd/MM/yyyy").format(item.expirationDate!), style: TextStyle(fontSize: 16, color: item.isExpired ? AppColors.danger : (item.isExpiringSoon ? AppColors.warning : AppColors.textPrimary), fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
