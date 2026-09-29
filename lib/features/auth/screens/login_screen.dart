import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";
import "register_screen.dart";

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
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signIn(email: _emailController.text.trim(), password: _passwordController.text);
    } catch (e) {
      setState(() { _errorMessage = "Email ou mot de passe incorrect"; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("LifeVault", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                const Text("Connectez-vous a votre coffre-fort", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 40),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email"), validator: (v) => (v == null || !v.contains("@")) ? "Email invalide" : null),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe"), validator: (v) => (v == null || v.isEmpty) ? "Mot de passe requis" : null),
                if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger))),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _isLoading ? null : _handleLogin, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Se connecter")),
                const SizedBox(height: 16),
                TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())); }, child: const Text("Pas encore de compte ? Inscrivez-vous")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

