import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.resetPassword(_emailController.text.trim());
      setState(() { _emailSent = true; });
    } catch (e) {
      setState(() { _errorMessage = "Une erreur est survenue. Reessayez."; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _emailSent ? _buildSuccessView(context) : _buildFormView(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: AppColors.gradientPrimary.scale(0.15), borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryLight, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text("Mot de passe oublie", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text("Entrez votre email, nous vous enverrons un lien de reinitialisation.", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xxl),
          TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline_rounded)), validator: (v) => (v == null || !v.contains("@")) ? "Email invalide" : null),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _errorMessage != null
                ? Padding(padding: const EdgeInsets.only(top: AppSpacing.md), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger)))
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleReset,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Envoyer le lien"),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 28),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text("Email envoye", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text("Verifiez votre boite mail et suivez le lien pour reinitialiser votre mot de passe.", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Retour a la connexion")),
      ],
    );
  }
}