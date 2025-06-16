import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'simple_firebase_auth_service.dart';

class TodoService {
  static const String _key = 'todos';
  final SimpleFirebaseAuthService _authService = SimpleFirebaseAuthService();

  // StreamController para notificar mudanças nas todos
  final StreamController<List<Todo>> _todosController =
      StreamController<List<Todo>>.broadcast();

  /// Stream de todos que emite mudanças em tempo real
  Stream<List<Todo>> getTodosStream() {
    // Carregar dados iniciais
    _loadInitialTodos();
    return _todosController.stream;
  }

  /// Carrega dados iniciais para o stream
  Future<void> _loadInitialTodos() async {
    final todos = await getTodos();
    if (!_todosController.isClosed) {
      _todosController.add(todos);
    }
  }

  /// Notifica o stream sobre mudanças
  Future<void> _notifyChanges() async {
    final todos = await getTodos();
    if (!_todosController.isClosed) {
      _todosController.add(todos);
    }
  }

  Future<List<Todo>> getTodos() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_key);

    if (todosString == null) {
      return [];
    }

    final List<dynamic> todosList = jsonDecode(todosString);
    final allTodos = todosList.map((json) => Todo.fromJson(json)).toList();

    // Filtrar apenas as tarefas do usuário atual
    return allTodos.where((todo) => todo.userId == currentUser.id).toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();

    // Preservar tarefas de outros usuários
    final allTodos = await _getAllTodos();
    final currentUser = await _authService.getCurrentUser();

    if (currentUser != null) {
      // Remover tarefas antigas do usuário atual
      allTodos.removeWhere((todo) => todo.userId == currentUser.id);
      // Adicionar novas tarefas do usuário atual
      allTodos.addAll(todos);
    }

    final String todosString = jsonEncode(
      allTodos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_key, todosString);

    // Notificar mudanças no stream
    await _notifyChanges();
  }

  Future<bool> addTodo(Todo todo) async {
    try {
      final todos = await getTodos();
      todos.add(todo);
      await saveTodos(todos);
      return true;
    } catch (e) {
      print('Erro ao adicionar todo: $e');
      return false;
    }
  }

  Future<bool> removeTodo(String id) async {
    try {
      final todos = await getTodos();
      todos.removeWhere((todo) => todo.id == id);
      await saveTodos(todos);
      return true;
    } catch (e) {
      print('Erro ao remover todo: $e');
      return false;
    }
  }

  Future<bool> toggleTodo(String id) async {
    try {
      final todos = await getTodos();
      final index = todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        todos[index].isCompleted = !todos[index].isCompleted;
        await saveTodos(todos);
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao alterar status do todo: $e');
      return false;
    }
  }

  Future<bool> updateTodo(Todo todo) async {
    try {
      final todos = await getTodos();
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = todo;
        await saveTodos(todos);
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao atualizar todo: $e');
      return false;
    }
  }

  // Método privado para obter todas as tarefas sem filtrar por usuário
  Future<List<Todo>> _getAllTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_key);

    if (todosString == null) {
      return [];
    }

    final List<dynamic> todosList = jsonDecode(todosString);
    return todosList.map((json) => Todo.fromJson(json)).toList();
  }

  /// Dispose do stream controller
  void dispose() {
    _todosController.close();
  }
}
