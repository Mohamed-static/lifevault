import "package:flutter/material.dart";
import "../../../services/auth_service.dart";
import "../../../core/theme.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _authService.signUp(email: _emailController.text.trim(), password: _passwordController.text, fullName: _nameController.text.trim());
      if (mounted) Navigator.pop(context);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Creer un compte", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 32),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom complet"), validator: (v) => (v == null || v.isEmpty) ? "Nom requis" : null),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email"), validator: (v) => (v == null || !v.contains("@")) ? "Email invalide" : null),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe"), validator: (v) => (v == null || v.length < 6) ? "6 caracteres minimum" : null),
                if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger))),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _isLoading ? null : _handleRegister, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("S inscrire")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
