import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as AppUser;

/// Serviço de autenticação Firebase seguindo documentação oficial
/// https://firebase.google.com/docs/flutter/
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de mudanças de estado de autenticação (padrão oficial)
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual (padrão oficial)
  static User? get currentUser => _auth.currentUser;

  /// Registrar novo usuário conforme documentação oficial
  static Future<UserCredential?> register(
      String email, String password, String displayName) async {
    try {
      print('🚀 Iniciando registro: $email');

      // Criar usuário conforme documentação oficial
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar perfil conforme documentação oficial
      if (credential.user != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!
            .reload(); // Recarregar dados conforme documentação
      }

      print('✅ Usuário registrado com sucesso: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Erro FirebaseAuth no registro: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Erro geral no registro: $e');
      rethrow;
    }
  }

  /// Login conforme documentação oficial
  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      print('🚀 Iniciando login: $email');

      // Login conforme documentação oficial
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login realizado com sucesso: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Erro FirebaseAuth no login: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Erro geral no login: $e');
      rethrow;
    }
  }

  /// Logout conforme documentação oficial
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Logout realizado');
    } catch (e) {
      print('❌ Erro no logout: $e');
      rethrow;
    }
  }

  /// Reset de senha conforme documentação oficial
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Email de reset enviado para: $email');
    } on FirebaseAuthException catch (e) {
      print('❌ Erro no reset de senha: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Verificar se está logado
  static bool get isSignedIn => _auth.currentUser != null;

  /// Obter dados do usuário atual conforme documentação oficial
  static AppUser.User? getCurrentAppUser() {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    return AppUser.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      password: '', // Nunca expor senha
    );
  }

  /// Atualizar perfil do usuário conforme documentação oficial
  static Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não logado');

    try {
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Recarregar dados conforme documentação oficial
      await user.reload();
      print('✅ Perfil atualizado');
    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  /// Verificar se email está verificado
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Enviar verificação de email conforme documentação oficial
  static Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não logado');

    try {
      await user.sendEmailVerification();
      print('✅ Email de verificação enviado');
    } catch (e) {
      print('❌ Erro ao enviar verificação: $e');
      rethrow;
    }
  }

  /// Reautenticar usuário conforme documentação oficial
  static Future<void> reauthenticate(String password) async {
    final User? user = _auth.currentUser;
    if (user?.email == null) throw Exception('Usuário ou email não disponível');

    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Reautenticação realizada');
    } on FirebaseAuthException catch (e) {
      print('❌ Erro na reautenticação: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Deletar conta conforme documentação oficial
  static Future<void> deleteAccount(String currentPassword) async {
    try {
      // Reautenticar antes de deletar (recomendação oficial)
      await reauthenticate(currentPassword);

      // Deletar conta
      await _auth.currentUser?.delete();
      print('✅ Conta deletada');
    } catch (e) {
      print('❌ Erro ao deletar conta: $e');
      rethrow;
    }
  }

  /// Gerenciar erros Firebase conforme documentação oficial
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Usuário desabilitado.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
