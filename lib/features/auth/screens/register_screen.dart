import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signUp(email: _emailController.text.trim(), password: _passwordController.text, fullName: _nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte cree. Verifiez votre email pour confirmer.")));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() { _errorMessage = "Erreur lors de l inscription"; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppColors.gradientPrimary.scale(0.08)))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Creer un compte", style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text("Rejoignez LifeVault en quelques secondes", style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: AppSpacing.xxl),
                          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom complet", prefixIcon: Icon(Icons.person_outline_rounded)), validator: (v) => (v == null || v.isEmpty) ? "Nom requis" : null),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline_rounded)), validator: (v) => (v == null || !v.contains("@")) ? "Email invalide" : null),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe", prefixIcon: Icon(Icons.lock_outline_rounded)), validator: (v) => (v == null || v.length < 8) ? "8 caracteres minimum" : null),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _errorMessage != null
                                ? Padding(padding: const EdgeInsets.only(top: AppSpacing.md), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger)))
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("S inscrire"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
