import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Todo> get pendingTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();
  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todos = await _todoService.getTodos();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar tarefas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      await _todoService.addTodo(todo);
      _todos.add(todo);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar tarefa: $e';
      notifyListeners();
    }
  }

  Future<void> toggleTodo(String id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          isCompleted: !_todos[index].isCompleted,
        );
        await _todoService.toggleTodo(id);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao alterar status da tarefa: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      _todos.removeWhere((todo) => todo.id == id);
      await _todoService.removeTodo(id);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar tarefa: $e';
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        await _todoService.updateTodo(todo);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao atualizar tarefa: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
