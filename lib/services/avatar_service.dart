import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AvatarService {
  static const String _avatarFolderName = 'user_avatars';

  /// Obtém o diretório onde os avatares são armazenados
  Future<Directory> _getAvatarDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${appDir.path}/$_avatarFolderName');

    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    return avatarDir;
  }

  /// Obtém o caminho do avatar para um usuário específico
  Future<String> _getAvatarPath(String userId) async {
    final avatarDir = await _getAvatarDirectory();
    return '${avatarDir.path}/avatar_$userId.jpg';
  }

  /// Salva o avatar de um usuário
  Future<String?> saveUserAvatar(String userId, File imageFile) async {
    try {
      final avatarPath = await _getAvatarPath(userId);
      final savedFile = await imageFile.copy(avatarPath);

      print('✅ Avatar salvo para usuário $userId: $avatarPath');
      return savedFile.path;
    } catch (e) {
      print('❌ Erro ao salvar avatar: $e');
      return null;
    }
  }

  /// Obtém o avatar de um usuário (se existir)
  Future<File?> getUserAvatar(String userId) async {
    try {
      final avatarPath = await _getAvatarPath(userId);
      final file = File(avatarPath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao obter avatar: $e');
      return null;
    }
  }

  /// Verifica se o usuário tem avatar
  Future<bool> hasUserAvatar(String userId) async {
    try {
      final avatarPath = await _getAvatarPath(userId);
      return await File(avatarPath).exists();
    } catch (e) {
      print('❌ Erro ao verificar avatar: $e');
      return false;
    }
  }

  /// Remove o avatar de um usuário
  Future<bool> deleteUserAvatar(String userId) async {
    try {
      final avatarPath = await _getAvatarPath(userId);
      final file = File(avatarPath);

      if (await file.exists()) {
        await file.delete();
        print('✅ Avatar removido para usuário $userId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erro ao remover avatar: $e');
      return false;
    }
  }

  /// Lista todos os avatares salvos (para debug/limpeza)
  Future<List<File>> getAllAvatars() async {
    try {
      final avatarDir = await _getAvatarDirectory();
      final files = avatarDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.jpg'))
          .cast<File>()
          .toList();

      return files;
    } catch (e) {
      print('❌ Erro ao listar avatares: $e');
      return [];
    }
  }

  /// Limpa avatares órfãos (usuários que não existem mais)
  Future<void> cleanupOrphanedAvatars(List<String> activeUserIds) async {
    try {
      final allAvatars = await getAllAvatars();

      for (final avatar in allAvatars) {
        final fileName = avatar.path.split('/').last;
        final userId =
            fileName.replaceAll('avatar_', '').replaceAll('.jpg', '');

        if (!activeUserIds.contains(userId)) {
          await avatar.delete();
          print('🧹 Avatar órfão removido: $fileName');
        }
      }
    } catch (e) {
      print('❌ Erro na limpeza de avatares: $e');
    }
  }

  /// Obtém informações sobre o armazenamento de avatares
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final avatarDir = await _getAvatarDirectory();
      final avatars = await getAllAvatars();

      int totalSize = 0;
      for (final avatar in avatars) {
        totalSize += await avatar.length();
      }

      return {
        'directory': avatarDir.path,
        'totalAvatars': avatars.length,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('❌ Erro ao obter informações de armazenamento: $e');
      return {};
    }
  }
}
