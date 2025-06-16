import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/firestore_todo_service.dart';

/// Provider para gerenciamento de estado das tarefas
class TodoProvider extends ChangeNotifier {
  final FirestoreTodoService _todoService = FirestoreTodoService();

  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters computados
  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get pendingTodos => _todos.where((todo) => !todo.isCompleted).length;

  List<Todo> get completedTodosList =>
      _todos.where((todo) => todo.isCompleted).toList();
  List<Todo> get pendingTodosList =>
      _todos.where((todo) => !todo.isCompleted).toList();

  /// Carrega todas as tarefas
  Future<void> loadTodos() async {
    _setLoading(true);
    _setError(null);

    try {
      final todos = await _todoService.getTodos();
      _todos = todos;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar tarefas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona uma nova tarefa
  Future<bool> addTodo(String title, String description) async {
    _setError(null);

    try {
      final todo = Todo(
        id: '', // Será gerado pelo Firestore
        title: title,
        description: description,
        isCompleted: false,
        createdAt: DateTime.now(),
        userId: '', // Será definido pelo service
      );

      final success = await _todoService.addTodo(todo);
      if (success) {
        await loadTodos(); // Recarrega a lista
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao adicionar tarefa: $e');
      return false;
    }
  }

  /// Atualiza uma tarefa existente
  Future<bool> updateTodo(Todo todo) async {
    _setError(null);

    try {
      final success = await _todoService.updateTodo(todo);
      if (success) {
        // Atualiza localmente
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = todo;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao atualizar tarefa: $e');
      return false;
    }
  }

  /// Alterna o status de completado de uma tarefa
  Future<bool> toggleTodo(String id) async {
    _setError(null);

    try {
      final success = await _todoService.toggleTodo(id);
      if (success) {
        // Atualiza localmente
        final index = _todos.indexWhere((t) => t.id == id);
        if (index != -1) {
          _todos[index] = _todos[index].copyWith(
            isCompleted: !_todos[index].isCompleted,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao alterar status da tarefa: $e');
      return false;
    }
  }

  /// Remove uma tarefa
  Future<bool> removeTodo(String id) async {
    _setError(null);

    try {
      final success = await _todoService.removeTodo(id);
      if (success) {
        // Remove localmente
        _todos.removeWhere((todo) => todo.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao remover tarefa: $e');
      return false;
    }
  }

  /// Busca tarefas por texto
  List<Todo> searchTodos(String query) {
    if (query.isEmpty) return _todos;

    final lowerQuery = query.toLowerCase();
    return _todos.where((todo) {
      return todo.title.toLowerCase().contains(lowerQuery) ||
          todo.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtra tarefas por status
  List<Todo> filterTodos({bool? isCompleted}) {
    if (isCompleted == null) return _todos;
    return _todos.where((todo) => todo.isCompleted == isCompleted).toList();
  }

  /// Limpa todos os erros
  void clearError() {
    _setError(null);
  }

  /// Recarrega as tarefas (refresh)
  Future<void> refresh() async {
    await loadTodos();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
