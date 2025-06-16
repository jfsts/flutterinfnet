import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user.dart';
import '../models/user_profile.dart';
import '../services/simple_firebase_auth_service.dart';
import '../services/user_profile_service.dart';
import '../services/avatar_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SimpleFirebaseAuthService _authService = SimpleFirebaseAuthService();
  final UserProfileService _profileService = UserProfileService();
  final AvatarService _avatarService = AvatarService();
  final _nameController = TextEditingController();

  User? _currentUser;
  UserProfile? _userProfile;
  File? _userAvatar;
  bool _isLoading = false;
  bool _isUpdatingName = false;
  bool _isDisposed = false;
  bool _hasLoadedData = false; // Flag para evitar carregamentos duplicados
  bool _isSavingAvatar = false; // Flag para indicar salvamento do avatar

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nameController.dispose();
    super.dispose();
  }

  /// Carrega dados do usuário atual e seu avatar
  Future<void> _loadUserData() async {
    if (!mounted || _isDisposed || _hasLoadedData) return;

    setState(() => _isLoading = true);

    try {
      // Carregar dados básicos do Auth
      final user = await _authService.getCurrentUser();
      if (user != null && mounted && !_isDisposed) {
        _currentUser = user;

        // Carregar perfil completo do Firestore
        final profile = await _profileService.getCurrentUserProfile();
        if (profile != null && mounted && !_isDisposed) {
          _userProfile = profile;

          // Verificar se o widget ainda está montado antes de usar o controller
          if (mounted && !_isDisposed) {
            _nameController.text = profile.hasName ? profile.name! : '';
          }

          // Carregar avatar do usuário baseado no UID do Firebase
          final avatar = await _avatarService.getUserAvatar(profile.uid);
          if (mounted && !_isDisposed) {
            setState(() {
              _userAvatar = avatar;
            });
          }

          // Debug para verificar dados carregados
          print(
              '✅ Perfil carregado: ${profile.hasName ? profile.name : 'sem nome'} (${profile.email})');
        } else {
          print('⚠️ Perfil não encontrado no Firestore');
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar dados do usuário: $e');
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _hasLoadedData = true; // Marca como dados carregados
        });
      }
    }
  }

  /// Seleciona e salva nova imagem de perfil
  Future<void> _pickAndSaveAvatar() async {
    if (_currentUser == null || !mounted || _isDisposed) return;

    try {
      // Solicitar permissões
      await _requestPermissions();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || !mounted || _isDisposed) return;

      // Atualizar imediatamente a UI com a imagem selecionada
      final selectedImageFile = File(image.path);
      if (mounted && !_isDisposed) {
        setState(() {
          _userAvatar = selectedImageFile;
          _isSavingAvatar = true; // Indicar que está salvando
        });
      }

      // Salvar avatar com o UID do Firebase em background
      final savedPath = await _avatarService.saveUserAvatar(
        _currentUser!.id,
        selectedImageFile,
      );

      if (savedPath != null && mounted && !_isDisposed) {
        // Avatar já foi atualizado na UI, apenas mostrar mensagem de sucesso
        _showSuccessMessage('Avatar atualizado com sucesso! 📸');
      } else {
        if (mounted && !_isDisposed) {
          // Se falhou ao salvar, reverter para avatar anterior
          final previousAvatar =
              await _avatarService.getUserAvatar(_currentUser!.id);
          setState(() => _userAvatar = previousAvatar);
          _showErrorMessage('Erro ao salvar avatar. Tente novamente.');
        }
      }
    } catch (e) {
      print('❌ Erro ao selecionar avatar: $e');
      if (mounted && !_isDisposed) {
        _showErrorMessage(
            'Erro ao selecionar imagem. Verifique as permissões.');
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isSavingAvatar = false);
      }
    }
  }

  /// Solicita permissões necessárias
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status.isPermanentlyDenied) {
        throw Exception('Permissão negada permanentemente');
      }
    }
  }

  /// Atualiza o nome do usuário
  Future<void> _updateUserName() async {
    if (_userProfile == null || !mounted || _isDisposed) return;

    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage('Por favor, digite um nome válido.');
      return;
    }

    final newName = _nameController.text.trim();
    if (newName == _userProfile!.name && _userProfile!.hasName) {
      _showErrorMessage('O nome não foi alterado.');
      return; // Sem mudanças
    }

    if (mounted && !_isDisposed) {
      setState(() => _isUpdatingName = true);
    }

    try {
      print('🔍 Debug - Atualizando nome no Firestore para: "$newName"');
      final success = await _profileService.updateUserName(newName);

      if (success && mounted && !_isDisposed) {
        // Recarregar dados do usuário após atualização
        _hasLoadedData = false; // Reset flag para permitir recarregamento
        await _loadUserData();
        _showSuccessMessage('Nome atualizado com sucesso! ✅');
      } else {
        if (mounted && !_isDisposed) {
          _showErrorMessage('Erro ao atualizar nome. Tente novamente.');
        }
      }
    } catch (e) {
      print('❌ Erro ao atualizar nome: $e');
      if (mounted && !_isDisposed) {
        _showErrorMessage('Erro ao atualizar nome. Verifique sua conexão.');
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() => _isUpdatingName = false);
      }
    }
  }

  /// Mostra dialog de confirmação
  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Mostra mensagem de sucesso
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mostra mensagem de erro
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return const Center(
        child: Text('Erro ao carregar perfil do usuário'),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            16.0, 16.0, 16.0, 32.0), // Padding extra na parte inferior
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar section
            _buildAvatarSection(),
            const SizedBox(height: 24),

            // User info
            _buildUserInfoCard(),
            const SizedBox(height: 20),

            // Name update
            _buildNameUpdateCard(),
            const SizedBox(height: 20),

            // Logout button
            _buildLogoutCard(),

            // Espaço extra para garantir que o botão não seja tampado
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: (_isLoading || _isSavingAvatar) ? null : _pickAndSaveAvatar,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  border: Border.all(
                    color: _isSavingAvatar
                        ? Colors.green.withOpacity(0.5)
                        : Colors.blue.withOpacity(0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _userAvatar != null
                    ? ClipOval(
                        child: Image.file(
                          _userAvatar!,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey[600],
                      ),
              ),
              if (_isLoading)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              if (_isSavingAvatar)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              if (!_isLoading && !_isSavingAvatar)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isSavingAvatar
              ? 'Salvando avatar...'
              : _userAvatar == null
                  ? 'Toque para adicionar foto'
                  : 'Toque para alterar foto',
          style: TextStyle(
            color: _isSavingAvatar ? Colors.green[600] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Informações do Usuário',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Email', _userProfile!.email, Icons.email),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Nome',
              _userProfile!.hasName
                  ? _userProfile!.name!
                  : 'Defina seu nome abaixo ⬇️',
              Icons.account_circle,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
                'ID do usuário', _userProfile!.uid, Icons.fingerprint),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNameUpdateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Alterar Nome',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_userProfile!.hasName)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seu nome não está definido. Digite abaixo para personalizar seu perfil!',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: !_userProfile!.hasName
                    ? 'Digite seu nome completo'
                    : 'Nome completo',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
                helperText: 'Como você gostaria de ser chamado',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdatingName ? null : _updateUserName,
                icon: _isUpdatingName
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isUpdatingName ? 'Salvando...' : 'Salvar Nome'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20), // Padding maior para mais destaque
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.exit_to_app, color: Colors.red, size: 24),
                SizedBox(width: 12),
                Text(
                  'Sair da Conta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Desconecte-se da sua conta de forma segura.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50, // Altura fixa para botão mais destacado
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await _showConfirmDialog(
                    'Sair da Conta',
                    'Tem certeza que deseja sair? Você precisará fazer login novamente.',
                  );

                  if (confirmed) {
                    await _authService.logout();
                    if (mounted) {
                      // Navegar para tela de login usando rota nomeada
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Fazer Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
