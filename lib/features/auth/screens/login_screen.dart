import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";
import "register_screen.dart";
import "forgot_password_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signIn(email: _emailController.text.trim(), password: _passwordController.text);
    } catch (e) {
      setState(() { _errorMessage = e.toString().contains("lente") ? "Connexion lente, verifiez votre reseau et reessayez" : "Email ou mot de passe incorrect"; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      setState(() { _errorMessage = "Erreur de connexion Google"; });
    } finally {
      if (mounted) setState(() { _isGoogleLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.gradientPrimary.scale(0.08)),
            ),
          ),
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
                          Container(
                            width: 72,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(AppRadius.lg)),
                            child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text("LifeVault", style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text("Votre coffre-fort numerique", style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: AppSpacing.xxl),
                          OutlinedButton.icon(
                            onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                            icon: _isGoogleLoading
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.g_mobiledata_rounded, size: 24),
                            label: const Text("Continuer avec Google"),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm), child: Text("ou", style: Theme.of(context).textTheme.bodyMedium)),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline_rounded)), validator: (v) => (v == null || !v.contains("@")) ? "Email invalide" : null),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Mot de passe",
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                                onPressed: () => setState(() { _obscurePassword = !_obscurePassword; }),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? "Mot de passe requis" : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())); },
                              child: const Text("Mot de passe oublie ?"),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _errorMessage != null
                                ? Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger)))
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Se connecter"),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Center(
                            child: TextButton(
                              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())); },
                              child: const Text("Pas encore de compte ? Inscrivez-vous"),
                            ),
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