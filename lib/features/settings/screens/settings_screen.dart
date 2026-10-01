import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";
import "../../../main.dart";
import "../../profile/screens/profile_screen.dart";
import "../../auth/screens/login_screen.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  bool _isDeletingAccount = false;

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Se deconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Deconnexion")),
        ],
      ),
    );
    if (confirm == true) await _authService.signOut();
  }

  Future<void> _handleDeleteAccount() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Supprimer votre compte ?"),
        content: const Text("Cette action supprimera definitivement votre compte, vos elements et vos fichiers. Cette action est irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Continuer", style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (firstConfirm != true || !mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Etes-vous vraiment sur ?"),
        content: const Text("Dernier avertissement : toutes vos donnees seront perdues definitivement."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer definitivement", style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (secondConfirm != true || !mounted) return;

    setState(() { _isDeletingAccount = true; });
    try {
      await _authService.deleteAccount();
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
      }
    } catch (e) {
      setState(() { _isDeletingAccount = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression du compte")));
    }
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _tile({required IconData icon, required String label, VoidCallback? onTap, Widget? trailing, Color? color}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? AppColors.primaryLight),
        title: Text(label, style: TextStyle(color: color)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parametres")),
      body: _isDeletingAccount
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                children: [
                  _sectionTitle(context, "Compte"),
                  _tile(icon: Icons.person_outline_rounded, label: "Profil", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                  _sectionTitle(context, "Apparence"),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeModeNotifier,
                    builder: (context, mode, _) {
                      return _tile(
                        icon: mode == ThemeMode.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        label: mode == ThemeMode.dark ? "Theme sombre" : "Theme clair",
                        trailing: Switch(value: mode == ThemeMode.dark, onChanged: (_) => toggleTheme(), activeThumbColor: AppColors.primary),
                      );
                    },
                  ),
                  _sectionTitle(context, "Securite"),
                  _tile(icon: Icons.logout_rounded, label: "Se deconnecter", onTap: _handleSignOut),
                  _tile(icon: Icons.delete_forever_outlined, label: "Supprimer mon compte", onTap: _handleDeleteAccount, color: AppColors.danger),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }
}
