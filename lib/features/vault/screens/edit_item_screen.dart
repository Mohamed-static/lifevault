import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../../../models/vault_item.dart";
import "../../../models/category.dart";
import "../../../services/vault_service.dart";
import "../../../services/reminder_service.dart";
import "../../../core/theme.dart";
import "../../../core/category_icons.dart";

class EditItemScreen extends StatefulWidget {
  final VaultItem item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _vaultService = VaultService();
  final _reminderService = ReminderService();
  DateTime? _expirationDate;
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description ?? "");
    _expirationDate = widget.item.expirationDate;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _vaultService.getCategories();
      final match = cats.where((c) => c.id == widget.item.categoryId);
      setState(() {
        _categories = cats;
        _selectedCategory = match.isNotEmpty ? match.first : null;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() { _isLoadingCategories = false; });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() { _expirationDate = picked; });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final updated = VaultItem(
        id: widget.item.id,
        userId: widget.item.userId,
        categoryId: _selectedCategory?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        expirationDate: _expirationDate,
        createdAt: widget.item.createdAt,
        updatedAt: DateTime.now(),
      );
      await _vaultService.updateItem(widget.item.id, updated);
      final expirationChanged = _expirationDate != widget.item.expirationDate;
      if (expirationChanged) {
        await _reminderService.deleteRemindersForItem(widget.item.id);
        if (_expirationDate != null) {
          await _reminderService.createDefaultReminders(vaultItemId: widget.item.id, expirationDate: _expirationDate!);
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _errorMessage = "Erreur lors de la modification"; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier l element")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Titre", prefixIcon: Icon(Icons.title_rounded)), validator: (v) => (v == null || v.isEmpty) ? "Titre requis" : null),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: "Description (optionnel)", prefixIcon: Icon(Icons.notes_rounded))),
              const SizedBox(height: AppSpacing.md),
              Text("Categorie", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              _isLoadingCategories
                  ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  : Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _categories.map((cat) {
                        final selected = _selectedCategory?.id == cat.id;
                        return ChoiceChip(
                          label: Text(cat.name),
                          avatar: Icon(categoryIcon(cat.name), size: 16, color: selected ? Colors.white : AppColors.primaryLight),
                          selected: selected,
                          onSelected: (_) => setState(() { _selectedCategory = selected ? null : cat; }),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: BorderSide(color: selected ? AppColors.primary : AppColors.borderDark)),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Date d expiration (optionnel)",
                    prefixIcon: const Icon(Icons.event_outlined),
                    suffixIcon: _expirationDate != null
                        ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() { _expirationDate = null; }))
                        : null,
                  ),
                  child: Text(_expirationDate == null ? "Aucune date selectionnee" : DateFormat("dd/MM/yyyy").format(_expirationDate!)),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _errorMessage != null
                    ? Padding(padding: const EdgeInsets.only(top: AppSpacing.md), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger)))
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Enregistrer les modifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}