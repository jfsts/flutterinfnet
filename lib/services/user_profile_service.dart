import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static const String _collection = 'user_profiles';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cria ou atualiza perfil do usuário no Firestore
  Future<bool> createOrUpdateProfile({
    required String uid,
    required String email,
    String? name,
    String? photoPath,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(uid);

      // Verificar se o perfil já existe
      final docSnapshot = await docRef.get();

      UserProfile profile;
      if (docSnapshot.exists) {
        // Atualizar perfil existente
        final existingProfile = UserProfile.fromMap(docSnapshot.data()!);
        profile = existingProfile.copyWith(
          email: email,
          name: name,
          photoPath: photoPath,
        );
      } else {
        // Criar novo perfil
        profile = UserProfile.fromAuth(
          uid: uid,
          email: email,
          name: name,
        ).copyWith(photoPath: photoPath);
      }

      await docRef.set(profile.toMap(), SetOptions(merge: true));
      print('✅ Perfil salvo no Firestore para UID: $uid');
      return true;
    } catch (e) {
      print('❌ Erro ao salvar perfil: $e');
      return false;
    }
  }

  /// Obtém perfil do usuário atual
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      return await getUserProfile(user.uid);
    } catch (e) {
      print('❌ Erro ao obter perfil atual: $e');
      return null;
    }
  }

  /// Obtém perfil por UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }

      // Se não existe, tentar criar um básico a partir do Firebase Auth
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        final basicProfile = UserProfile.fromAuth(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
        );

        await createOrUpdateProfile(
          uid: basicProfile.uid,
          email: basicProfile.email,
          name: basicProfile.name,
        );

        return basicProfile;
      }

      return null;
    } catch (e) {
      print('❌ Erro ao obter perfil: $e');
      return null;
    }
  }

  /// Atualiza nome do usuário
  Future<bool> updateUserName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection(_collection).doc(user.uid).update({
        'name': name,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Nome atualizado no Firestore: $name');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar nome: $e');
      return false;
    }
  }

  /// Atualiza caminho da foto
  Future<bool> updatePhotoPath(String photoPath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection(_collection).doc(user.uid).update({
        'photoPath': photoPath,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Foto atualizada no Firestore: $photoPath');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar foto: $e');
      return false;
    }
  }

  /// Remove caminho da foto
  Future<bool> removePhoto() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection(_collection).doc(user.uid).update({
        'photoPath': null,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Foto removida do Firestore');
      return true;
    } catch (e) {
      print('❌ Erro ao remover foto: $e');
      return false;
    }
  }

  /// Atualiza preferências do usuário
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection(_collection).doc(user.uid).update({
        'preferences': preferences,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Preferências atualizadas no Firestore');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar preferências: $e');
      return false;
    }
  }

  /// Deleta perfil do usuário
  Future<bool> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
      print('✅ Perfil deletado do Firestore: $uid');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar perfil: $e');
      return false;
    }
  }

  /// Stream do perfil do usuário atual
  Stream<UserProfile?> get currentUserProfileStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(_collection)
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Sincroniza dados do Firebase Auth com Firestore
  Future<bool> syncWithFirebaseAuth() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Obter perfil atual do Firestore
      final currentProfile = await getUserProfile(user.uid);

      if (currentProfile == null) {
        // Criar perfil básico se não existir
        print('🔄 Sincronização - Criando perfil para: ${user.email}');
        print('🔄 Sincronização - Nome do Auth: "${user.displayName}"');

        return await createOrUpdateProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
        );
      } else {
        bool needsUpdate = false;
        final updates = <String, dynamic>{};

        // Atualizar email se mudou no Auth
        if (currentProfile.email != user.email) {
          updates['email'] = user.email ?? '';
          needsUpdate = true;
        }

        // Sincronizar nome se estiver vazio no Firestore mas preenchido no Auth
        if (!currentProfile.hasName &&
            user.displayName != null &&
            user.displayName!.isNotEmpty) {
          updates['name'] = user.displayName;
          needsUpdate = true;
          print(
              '🔄 Sincronização - Atualizando nome vazio no Firestore com: "${user.displayName}"');
        }

        if (needsUpdate) {
          updates['updatedAt'] = DateTime.now().toIso8601String();
          await _firestore
              .collection(_collection)
              .doc(user.uid)
              .update(updates);
          print('✅ Perfil sincronizado com Firebase Auth');
        }
      }

      return true;
    } catch (e) {
      print('❌ Erro na sincronização: $e');
      return false;
    }
  }

  /// Obtém todos os perfis (admin only)
  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro ao obter todos os perfis: $e');
      return [];
    }
  }

  /// Busca perfis por nome
  Future<List<UserProfile>> searchProfilesByName(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro na busca por nome: $e');
      return [];
    }
  }

  /// Verifica se um perfil existe
  Future<bool> profileExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('❌ Erro ao verificar existência do perfil: $e');
      return false;
    }
  }

  /// Força a sincronização completa do usuário atual
  Future<bool> forceSyncCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      print('🔄 Sincronização forçada - UID: ${user.uid}');
      print('🔄 Sincronização forçada - Email: ${user.email}');
      print('🔄 Sincronização forçada - DisplayName: "${user.displayName}"');

      // Sempre atualizar/criar perfil com dados do Auth
      await createOrUpdateProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
      );

      return true;
    } catch (e) {
      print('❌ Erro na sincronização forçada: $e');
      return false;
    }
  }

  /// Obtém estatísticas dos perfis
  Future<Map<String, dynamic>> getProfileStats() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final profiles = querySnapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .toList();

      final totalProfiles = profiles.length;
      final profilesWithNames = profiles.where((p) => p.hasName).length;
      final profilesWithPhotos = profiles.where((p) => p.hasPhoto).length;

      return {
        'totalProfiles': totalProfiles,
        'profilesWithNames': profilesWithNames,
        'profilesWithPhotos': profilesWithPhotos,
        'percentWithNames': totalProfiles > 0
            ? (profilesWithNames / totalProfiles * 100).round()
            : 0,
        'percentWithPhotos': totalProfiles > 0
            ? (profilesWithPhotos / totalProfiles * 100).round()
            : 0,
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      return {};
    }
  }
}
