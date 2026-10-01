import "dart:io";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:cached_network_image/cached_network_image.dart";
import "../../../models/user_profile.dart";
import "../../../services/profile_service.dart";
import "../../../core/theme.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _editing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName ?? "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked == null) return;

    setState(() { _isUploadingAvatar = true; });
    try {
      final newUrl = await _profileService.uploadAvatar(File(picked.path));
      final refreshed = await _profileService.getProfile();
      setState(() {
        _profile = refreshed.avatarUrl == newUrl ? refreshed : UserProfile(
          id: refreshed.id,
          email: refreshed.email,
          fullName: refreshed.fullName,
          avatarUrl: newUrl,
          createdAt: refreshed.createdAt,
          updatedAt: refreshed.updatedAt,
        );
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
    } finally {
      if (mounted) setState(() { _isUploadingAvatar = false; });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _errorMessage = null; });
    try {
      final updated = await _profileService.updateProfile(fullName: _nameController.text.trim());
      setState(() { _profile = updated; _editing = false; });
    } catch (e) {
      setState(() { _errorMessage = "Erreur lors de la mise a jour"; });
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          if (!_isLoading && !_editing)
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => setState(() { _editing = true; })),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(AppRadius.lg)),
                          clipBehavior: Clip.antiAlias,
                          child: _profile?.avatarUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _profile!.avatarUrl!,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                  placeholder: (c, u) => const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                  errorWidget: (c, u, e) => Text(
                                    (_profile?.fullName?.isNotEmpty == true ? _profile!.fullName![0] : "?").toUpperCase(),
                                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Text(
                                  (_profile?.fullName?.isNotEmpty == true ? _profile!.fullName![0] : "?").toUpperCase(),
                                  style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                              child: _isUploadingAvatar
                                  ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Nom complet", style: Theme.of(context).textTheme.labelSmall),
                        const SizedBox(height: AppSpacing.sm),
                        _editing
                            ? TextFormField(controller: _nameController, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)), validator: (v) => (v == null || v.isEmpty) ? "Nom requis" : null)
                            : Text(_profile?.fullName?.isNotEmpty == true ? _profile!.fullName! : "Non renseigne", style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.lg),
                        Text("Email", style: Theme.of(context).textTheme.labelSmall),
                        const SizedBox(height: AppSpacing.sm),
                        Text(_profile?.email ?? "", style: Theme.of(context).textTheme.bodyLarge),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(_errorMessage!, style: const TextStyle(color: AppColors.danger)),
                        ],
                        if (_editing) ...[
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving ? null : () => setState(() { _editing = false; _nameController.text = _profile?.fullName ?? ""; }),
                                  child: const Text("Annuler"),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _handleSave,
                                  child: _isSaving
                                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text("Enregistrer"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}