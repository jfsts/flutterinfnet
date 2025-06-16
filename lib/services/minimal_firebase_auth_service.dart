import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as AppUser;

class MinimalFirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar novo usuário - Apenas Firebase Auth
  Future<bool> register(String email, String password, String name) async {
    try {
      print('🚀 Iniciando registro para: $email');
      
      // Criar usuário no Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('❌ UserCredential.user é null');
        return false;
      }

      print('✅ Usuário criado no Firebase Auth: ${firebaseUser.uid}');
      
      // Tentar atualizar o display name
      try {
        await firebaseUser.updateDisplayName(name);
        print('✅ Display name atualizado');
      } catch (e) {
        print('⚠️ Erro ao atualizar display name: $e');
      }

      print('🎉 Registro concluído com sucesso!');
      return true;
      
    } catch (e) {
      print('❌ Erro ao registrar usuário: $e');
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      print('🚀 Iniciando login para: $email');
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Login realizado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao fazer login: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('✅ Logout realizado');
    } catch (e) {
      print('❌ Erro ao fazer logout: $e');
    }
  }

  // Recuperar senha
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Email de recuperação enviado');
      return true;
    } catch (e) {
      print('❌ Erro ao enviar email de recuperação: $e');
      return false;
    }
  }

  // Verificar se está logado
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Obter usuário atual - Apenas Firebase Auth
  Future<AppUser.User?> getCurrentUser() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      return AppUser.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? '',
        password: '',
      );
    } catch (e) {
      print('❌ Erro ao obter usuário atual: $e');
      return null;
    }
  }

  // Atualizar usuário - Apenas Firebase Auth
  Future<void> updateUser(AppUser.User updatedUser) async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      // Atualizar apenas no Firebase Auth
      if (firebaseUser.displayName != updatedUser.name) {
        await firebaseUser.updateDisplayName(updatedUser.name);
      }

      print('✅ Usuário atualizado');
    } catch (e) {
      print('❌ Erro ao atualizar usuário: $e');
    }
  }
} 