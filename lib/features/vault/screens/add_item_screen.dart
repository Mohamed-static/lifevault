import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../models/vault_item.dart";
import "../../../services/vault_service.dart";
import "../../../services/reminder_service.dart";
import "../../../core/theme.dart";

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vaultService = VaultService();
  final _reminderService = ReminderService();
  DateTime? _expirationDate;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) setState(() { _expirationDate = picked; });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final newItem = VaultItem(id: "", userId: "", title: _titleController.text.trim(), description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(), expirationDate: _expirationDate, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final created = await _vaultService.createItem(newItem);
      if (_expirationDate != null) {
        await _reminderService.createDefaultReminders(vaultItemId: created.id, expirationDate: _expirationDate!);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _errorMessage = "Erreur lors de la creation"; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un element")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Titre"), validator: (v) => (v == null || v.isEmpty) ? "Titre requis" : null),
                const SizedBox(height: 16),
                TextFormField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: "Description (optionnel)")),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Date d expiration (optionnel)"),
                    child: Text(_expirationDate == null ? "Aucune date selectionnee" : DateFormat("dd/MM/yyyy").format(_expirationDate!)),
                  ),
                ),
                if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger))),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: _isLoading ? null : _handleSave, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Enregistrer")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
