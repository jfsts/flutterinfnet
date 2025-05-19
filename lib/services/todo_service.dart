import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'auth_service.dart';

class TodoService {
  static const String _key = 'todos';
  final AuthService _authService = AuthService();

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
  }

  Future<void> addTodo(Todo todo) async {
    final todos = await getTodos();
    todos.add(todo);
    await saveTodos(todos);
  }

  Future<void> removeTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((todo) => todo.id == id);
    await saveTodos(todos);
  }

  Future<void> toggleTodo(String id) async {
    final todos = await getTodos();
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      todos[index].isCompleted = !todos[index].isCompleted;
      await saveTodos(todos);
    }
  }

  Future<void> updateTodo(Todo todo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      await saveTodos(todos);
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
}
