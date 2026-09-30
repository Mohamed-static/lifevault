import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../models/reminder.dart";
import "../../../models/vault_item.dart";
import "../../../services/reminder_service.dart";
import "../../../services/vault_service.dart";
import "../../../core/theme.dart";
import "../../vault/screens/item_details_screen.dart";

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminderService = ReminderService();
  final _vaultService = VaultService();
  List<Reminder> _reminders = [];
  Map<String, VaultItem> _itemsById = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final reminders = await _reminderService.getUpcomingReminders();
      final items = await _vaultService.getItems();
      final map = <String, VaultItem>{};
      for (final item in items) {
        map[item.id] = item;
      }
      setState(() { _reminders = reminders; _itemsById = map; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rappels")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _reminders.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: 400,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 48, color: Theme.of(context).textTheme.bodyMedium?.color),
                                const SizedBox(height: AppSpacing.sm),
                                Text("Aucun rappel a venir", style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        final item = _itemsById[reminder.vaultItemId];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Card(
                            child: ListTile(
                              onTap: item != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item))) : null,
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
                                child: const Icon(Icons.timer_outlined, color: AppColors.warning),
                              ),
                              title: Text(item?.title ?? "Element supprime"),
                              subtitle: Text(reminder.scheduledDate != null ? "Rappel le ${DateFormat("dd/MM/yyyy").format(reminder.scheduledDate!)}" : "Date non definie"),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}