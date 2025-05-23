import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        _nameController.text = user.name ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);

      // Solicitar permissão de câmera e galeria
      final status = await Permission.camera.request();
      final storageStatus = await Permission.storage.request();
      final photosStatus = await Permission.photos.request();

      if (status.isDenied ||
          (storageStatus.isDenied && photosStatus.isDenied)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('É necessário permitir o acesso à câmera e galeria'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || _currentUser == null) return;

      // Salvar a imagem localmente
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${_currentUser!.id}.jpg';
      final savedImage = File('${directory.path}/$fileName');

      await File(image.path).copy(savedImage.path);

      // Atualizar o usuário
      final updatedUser = _currentUser!.copyWith(
        photoPath: savedImage.path,
      );

      await _authService.updateUser(updatedUser);
      await _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao selecionar imagem. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    try {
      setState(() => _isLoading = true);

      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text.trim(),
      );

      await _authService.updateUser(updatedUser);
      await _loadUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _currentUser?.photoPath != null
                    ? FileImage(File(_currentUser!.photoPath!))
                    : null,
                child: _currentUser?.photoPath == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              FloatingActionButton.small(
                onPressed: _isLoading ? null : _pickImage,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _currentUser!.email,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SALVAR ALTERAÇÕES'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
