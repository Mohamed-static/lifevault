import "dart:io";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:file_picker/file_picker.dart";
import "../../../models/vault_item.dart";
import "../../../models/category.dart";
import "../../../services/vault_service.dart";
import "../../../services/reminder_service.dart";
import "../../../services/storage_service.dart";
import "../../../services/attachment_service.dart";
import "../../../services/tag_service.dart";
import "../../../core/theme.dart";
import "../../../core/category_icons.dart";
import "../../../shared/widgets/tag_selector.dart";

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
  final _storageService = StorageService();
  final _attachmentService = AttachmentService();
  final _tagService = TagService();
  DateTime? _expirationDate;
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<String> _selectedTagIds = [];
  PlatformFile? _pickedFile;
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _vaultService.getCategories();
      setState(() { _categories = cats; _isLoadingCategories = false; });
    } catch (e) {
      setState(() { _isLoadingCategories = false; });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["jpg", "jpeg", "png", "webp", "pdf"]);
    if (result != null && result.files.isNotEmpty) {
      setState(() { _pickedFile = result.files.first; });
    }
  }

  String _mimeTypeFor(String extension) {
    switch (extension.toLowerCase()) {
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "png":
        return "image/png";
      case "webp":
        return "image/webp";
      case "pdf":
        return "application/pdf";
      default:
        return "application/octet-stream";
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() { _expirationDate = picked; });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final newItem = VaultItem(id: "", userId: "", categoryId: _selectedCategory?.id, title: _titleController.text.trim(), description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(), expirationDate: _expirationDate, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final created = await _vaultService.createItem(newItem);
      if (_expirationDate != null) {
        await _reminderService.createDefaultReminders(vaultItemId: created.id, expirationDate: _expirationDate!);
      }
      if (_selectedTagIds.isNotEmpty) {
        await _tagService.setTagsForItem(vaultItemId: created.id, tagIds: _selectedTagIds);
      }
      if (_pickedFile != null && _pickedFile!.path != null) {
        final extension = _pickedFile!.extension ?? "";
        final mimeType = _mimeTypeFor(extension);
        final file = File(_pickedFile!.path!);
        final path = await _storageService.uploadFile(file: file, fileName: _pickedFile!.name, mimeType: mimeType);
        await _attachmentService.createAttachment(vaultItemId: created.id, filePath: path, fileName: _pickedFile!.name, mimeType: mimeType, fileSize: _pickedFile!.size);
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
              Text("Tags", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              TagSelector(selectedTagIds: _selectedTagIds, onChanged: (ids) => setState(() { _selectedTagIds = ids; })),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Date d expiration (optionnel)", prefixIcon: Icon(Icons.event_outlined)),
                  child: Text(_expirationDate == null ? "Aucune date selectionnee" : DateFormat("dd/MM/yyyy").format(_expirationDate!)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Fichier (optionnel, max 10 Mo)", prefixIcon: Icon(Icons.attach_file_rounded)),
                  child: Text(_pickedFile == null ? "Aucun fichier selectionne" : _pickedFile!.name, overflow: TextOverflow.ellipsis),
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
                    : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}