import 'package:flutter/material.dart';
import 'package:infnet_validators/infnet_validators.dart';
import '../services/simple_firebase_auth_service.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SimpleFirebaseAuthService();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Verificar se foi passado um email como argumento
    final String? email = ModalRoute.of(context)?.settings.arguments as String?;
    if (email != null && email.isNotEmpty && _emailController.text.isEmpty) {
      _emailController.text = email;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou senha inválidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const AppLogo(),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: EmailValidator.validateForForm,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: PasswordValidator.validateForForm,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Entrar',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: const Text('Não tem uma conta? Cadastre-se'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/reset-password');
                    },
                    child: const Text('Esqueceu sua senha?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
