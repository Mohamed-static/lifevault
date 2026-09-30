import "package:flutter/material.dart";
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
                    child: Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(AppRadius.lg)),
                      child: Text(
                        (_profile?.fullName?.isNotEmpty == true ? _profile!.fullName![0] : "?").toUpperCase(),
                        style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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