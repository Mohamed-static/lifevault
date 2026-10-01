import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";
import "register_screen.dart";
import "forgot_password_screen.dart";
import "package:flutter/gestures.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signIn(email: _emailController.text.trim(), password: _passwordController.text);
    } catch (e) {
      setState(() { _errorMessage = e.toString().contains("lente") ? "Connexion lente, verifiez votre reseau" : "Email ou mot de passe incorrect"; });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 5, child: _BrandPanel(isDark: isDark)),
                  Expanded(flex: 4, child: Center(child: SingleChildScrollView(child: _buildForm(context)))),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text("LifeVault", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildForm(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Bon retour", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 6),
            Text("Connectez-vous pour acceder a votre coffre.", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13)),
              child: _isGoogleLoading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_rounded, size: 22, color: Theme.of(context).textTheme.bodyLarge?.color),
                        const SizedBox(width: 8),
                        const Text("Continuer avec Google"),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).dividerTheme.color)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text("EMAIL", style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, letterSpacing: 1)),
                ),
                Expanded(child: Divider(color: Theme.of(context).dividerTheme.color)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text("Email", style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "vous@exemple.com"),
              validator: (v) => (v == null || !v.contains("@")) ? "Email invalide" : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mot de passe", style: Theme.of(context).textTheme.labelSmall),
                GestureDetector(
                  onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())); },
                  child: Text("Mot de passe oublie", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "••••••••",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                  onPressed: () => setState(() { _obscurePassword = !_obscurePassword; }),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? "Mot de passe requis" : null,
            ),
            AnimatedSize(
              duration: AppMotion.fast,
              child: _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(color: AppColors.dangerMuted, borderRadius: BorderRadius.circular(AppRadius.sm)),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                            const SizedBox(width: 6),
                            Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Se connecter"),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: "Pas encore de compte ? "),
                    TextSpan(
                      text: "Inscrivez-vous",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()..onTap = () { Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())); },
                    ),
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

class _BrandPanel extends StatelessWidget {
  final bool isDark;
  const _BrandPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLightElevated,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text("LifeVault", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32)),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: 320,
            child: Text(
              "Vos documents, vos echeances et vos informations essentielles, centralises et proteges.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _FeatureLine(icon: Icons.lock_outline_rounded, text: "Chiffrement et acces prive"),
          const SizedBox(height: AppSpacing.md),
          _FeatureLine(icon: Icons.notifications_none_rounded, text: "Rappels avant chaque echeance"),
          const SizedBox(height: AppSpacing.md),
          _FeatureLine(icon: Icons.folder_outlined, text: "Organisation par categories"),
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}