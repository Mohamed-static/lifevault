import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:url_launcher/url_launcher.dart";
import "../../../models/vault_item.dart";
import "../../../models/attachment.dart";
import "../../../services/vault_service.dart";
import "../../../services/reminder_service.dart";
import "../../../services/storage_service.dart";
import "../../../services/attachment_service.dart";
import "../../../core/theme.dart";
import "../../../core/category_icons.dart";

class ItemDetailsScreen extends StatefulWidget {
  final VaultItem item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final _vaultService = VaultService();
  final _reminderService = ReminderService();
  final _storageService = StorageService();
  final _attachmentService = AttachmentService();
  bool _isDeleting = false;
  String? _categoryName;
  bool _isLoadingCategory = true;
  Attachment? _attachment;
  String? _signedUrl;
  bool _isLoadingAttachment = true;

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadAttachment();
  }

  Future<void> _loadCategory() async {
    if (widget.item.categoryId == null) {
      setState(() { _isLoadingCategory = false; });
      return;
    }
    try {
      final cats = await _vaultService.getCategories();
      final match = cats.where((c) => c.id == widget.item.categoryId);
      setState(() { _categoryName = match.isNotEmpty ? match.first.name : null; _isLoadingCategory = false; });
    } catch (e) {
      setState(() { _isLoadingCategory = false; });
    }
  }

  Future<void> _loadAttachment() async {
    try {
      final att = await _attachmentService.getAttachmentForItem(widget.item.id);
      if (att != null) {
        final url = await _storageService.getSignedUrl(att.filePath);
        setState(() { _attachment = att; _signedUrl = url; _isLoadingAttachment = false; });
      } else {
        setState(() { _isLoadingAttachment = false; });
      }
    } catch (e) {
      setState(() { _isLoadingAttachment = false; });
    }
  }

  Future<void> _openFile() async {
    if (_signedUrl == null) return;
    final uri = Uri.parse(_signedUrl!);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
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
      if (_attachment != null) {
        await _storageService.deleteFile(_attachment!.filePath);
        await _attachmentService.deleteAttachment(_attachment!.id);
      }
      await _reminderService.deleteRemindersForItem(widget.item.id);
      await _vaultService.deleteItem(widget.item.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _isDeleting = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression")));
    }
  }

  Widget _infoRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.sm)),
          child: Icon(icon, size: 18, color: AppColors.primaryLight),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attachmentSection(BuildContext context) {
    if (_isLoadingAttachment) return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (_attachment == null || _signedUrl == null) return const SizedBox.shrink();
    if (_attachment!.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: GestureDetector(
          onTap: _openFile,
          child: CachedNetworkImage(imageUrl: _signedUrl!, height: 200, width: double.infinity, fit: BoxFit.cover, placeholder: (c, u) => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())), errorWidget: (c, u, e) => const SizedBox(height: 100, child: Center(child: Icon(Icons.broken_image_outlined)))),
        ),
      );
    }
    return InkWell(
      onTap: _openFile,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderDark), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_outlined, color: AppColors.danger),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(_attachment!.fileName, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.open_in_new_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title, overflow: TextOverflow.ellipsis),
        actions: [IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger), onPressed: _isDeleting ? null : _handleDelete)],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _attachmentSection(context),
                  if (_attachment != null) const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isLoadingCategory && _categoryName != null) ...[
                            _infoRow(context, icon: categoryIcon(_categoryName), label: "Categorie", value: _categoryName!),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (item.description != null) ...[
                            _infoRow(context, icon: Icons.notes_rounded, label: "Description", value: item.description!),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          _infoRow(context, icon: Icons.calendar_today_outlined, label: "Date de creation", value: DateFormat("dd/MM/yyyy").format(item.createdAt)),
                          if (item.expirationDate != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _infoRow(
                              context,
                              icon: Icons.event_busy_outlined,
                              label: "Date d expiration",
                              value: DateFormat("dd/MM/yyyy").format(item.expirationDate!),
                              valueColor: item.isExpired ? AppColors.danger : (item.isExpiringSoon ? AppColors.warning : null),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
