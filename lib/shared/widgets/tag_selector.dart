import "package:flutter/material.dart";
import "../../models/tag.dart";
import "../../services/tag_service.dart";
import "../../core/theme.dart";

class TagSelector extends StatefulWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onChanged;

  const TagSelector({super.key, required this.selectedTagIds, required this.onChanged});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final _tagService = TagService();
  final _newTagController = TextEditingController();
  List<Tag> _allTags = [];
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _tagService.getTags();
      setState(() { _allTags = tags; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _createTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    setState(() { _isCreating = true; });
    try {
      final tag = await _tagService.createTag(name);
      setState(() {
        _allTags.add(tag);
        _allTags.sort((a, b) => a.name.compareTo(b.name));
        _newTagController.clear();
        widget.onChanged([...widget.selectedTagIds, tag.id]);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la creation du tag")));
    } finally {
      if (mounted) setState(() { _isCreating = false; });
    }
  }

  void _toggleTag(String tagId) {
    final current = List<String>.from(widget.selectedTagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    widget.onChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _allTags.map((tag) {
            final selected = widget.selectedTagIds.contains(tag.id);
            return FilterChip(
              label: Text(tag.name),
              selected: selected,
              onSelected: (_) => _toggleTag(tag.id),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: BorderSide(color: selected ? AppColors.primary : AppColors.borderDark)),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTagController,
                decoration: const InputDecoration(hintText: "Nouveau tag...", isDense: true),
                onSubmitted: (_) => _createTag(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: _isCreating
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_circle_outline_rounded),
              onPressed: _isCreating ? null : _createTag,
              color: AppColors.primaryLight,
            ),
          ],
        ),
      ],
    );
  }
}