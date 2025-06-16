import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  final _uuid = const Uuid();

  // Registrar novo usuário
  Future<bool> register(String email, String password, String name) async {
    final users = await _getUsers();

    // Verificar se o email já está em uso
    if (users.any((user) => user.email == email)) {
      return false;
    }

    // Criar novo usuário
    final newUser = User(
      id: _uuid.v4(),
      email: email,
      password: password,
      name: name,
    );

    users.add(newUser);
    await _saveUsers(users);
    return true;
  }

  // Login
  Future<bool> login(String email, String password) async {
    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => User(id: '', email: '', password: ''),
    );

    if (user.id.isEmpty) {
      return false;
    }

    // Salvar usuário atual
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    return true;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Recuperar senha (envia email fictício)
  Future<bool> resetPassword(String email) async {
    final users = await _getUsers();
    return users.any((user) => user.email == email);
  }

  // Verificar se está logado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  // Obter usuário atual
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  // Atualizar usuário
  Future<void> updateUser(User updatedUser) async {
    final users = await _getUsers();
    final index = users.indexWhere((user) => user.id == updatedUser.id);

    if (index != -1) {
      users[index] = updatedUser;
      await _saveUsers(users);

      // Atualizar usuário atual se for o mesmo
      final currentUser = await getCurrentUser();
      if (currentUser?.id == updatedUser.id) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _currentUserKey, jsonEncode(updatedUser.toJson()));
      }
    }
  }

  // Métodos privados para gerenciar usuários
  Future<List<User>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];

    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((json) => User.fromJson(json)).toList();
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = jsonEncode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }
}
