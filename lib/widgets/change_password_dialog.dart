import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onChangePassword;

  const ChangePasswordDialog({
    super.key,
    required this.onChangePassword,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onChangePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
      }
    } catch (e) {
      // O erro será tratado no componente pai
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Alterar Senha'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para sua segurança, confirme sua senha atual antes de definir uma nova.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Senha atual
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Senha atual *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _showCurrentPassword = !_showCurrentPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite sua senha atual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nova senha
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nova senha *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                  ),
                  helperText: 'Mínimo 6 caracteres',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a nova senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'A nova senha deve ser diferente da atual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirmar nova senha
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar nova senha *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_clock),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme a nova senha';
                  }
                  if (value != _newPasswordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dicas de segurança
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates,
                            size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Dicas para uma senha segura:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Use pelo menos 8 caracteres\n'
                      '• Combine letras, números e símbolos\n'
                      '• Evite informações pessoais',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Alterar Senha'),
        ),
      ],
    );
  }
}
