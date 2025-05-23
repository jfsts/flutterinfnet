import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos {
    final sortedTodos = List<Todo>.from(_todos);

    // Ordena as tarefas: vencidas e não concluídas primeiro, depois por data de vencimento, depois por data de criação
    sortedTodos.sort((a, b) {
      // Se uma está concluída e a outra não, a não concluída vem primeiro
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Se ambas não estão concluídas, verifica se estão vencidas
      if (!a.isCompleted && !b.isCompleted) {
        final aOverdue = a.isOverdue;
        final bOverdue = b.isOverdue;

        // Tarefas vencidas vêm primeiro
        if (aOverdue != bOverdue) {
          return aOverdue ? -1 : 1;
        }
      }

      // Se têm data de vencimento, ordena por ela
      if (a.dueDate != null && b.dueDate != null) {
        final comparison = a.dueDate!.compareTo(b.dueDate!);
        if (comparison != 0) return comparison;

        // Se têm horário também, considera o horário
        if (a.dueTime != null && b.dueTime != null) {
          final aMinutes = a.dueTime!.hour * 60 + a.dueTime!.minute;
          final bMinutes = b.dueTime!.hour * 60 + b.dueTime!.minute;
          final timeComparison = aMinutes.compareTo(bMinutes);
          if (timeComparison != 0) return timeComparison;
        }
      }

      // Se apenas uma tem data de vencimento, ela vem primeiro
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;

      // Por último, ordena por data de criação (mais recente primeiro)
      return b.createdAt.compareTo(a.createdAt);
    });

    return List.unmodifiable(sortedTodos);
  }

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
