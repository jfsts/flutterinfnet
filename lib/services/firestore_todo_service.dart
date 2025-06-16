import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import 'simple_firebase_auth_service.dart';

class FirestoreTodoService {
  static const String _collection = 'todos';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SimpleFirebaseAuthService _authService = SimpleFirebaseAuthService();

  /// Obtém todas as tarefas do usuário atual
  Future<List<Todo>> getTodos() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return [];

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: currentUser.id)
          .get();

      final todos = querySnapshot.docs
          .map((doc) => Todo.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Ordenar no cliente por data de criação (mais recente primeira)
      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return todos;
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      return [];
    }
  }

  /// Adiciona uma nova tarefa
  Future<bool> addTodo(Todo todo) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;

      // Remove o ID para deixar o Firestore gerar automaticamente
      final todoData = todo.toJson();
      todoData.remove('id');

      // Adiciona o userId do usuário atual
      todoData['userId'] = currentUser.id;

      await _firestore.collection(_collection).add(todoData);
      return true;
    } catch (e) {
      print('Erro ao adicionar tarefa: $e');
      return false;
    }
  }

  /// Remove uma tarefa
  Future<bool> removeTodo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover tarefa: $e');
      return false;
    }
  }

  /// Alterna o status de conclusão de uma tarefa
  Future<bool> toggleTodo(String id) async {
    try {
      final docRef = _firestore.collection(_collection).doc(id);
      final doc = await docRef.get();

      if (!doc.exists) return false;

      final currentStatus = doc.data()?['isCompleted'] ?? false;
      await docRef.update({'isCompleted': !currentStatus});
      return true;
    } catch (e) {
      print('Erro ao alterar status da tarefa: $e');
      return false;
    }
  }

  /// Atualiza uma tarefa existente
  Future<bool> updateTodo(Todo todo) async {
    try {
      final todoData = todo.toJson();
      todoData.remove('id'); // Remove ID do mapa de dados

      await _firestore.collection(_collection).doc(todo.id).update(todoData);
      return true;
    } catch (e) {
      print('Erro ao atualizar tarefa: $e');
      return false;
    }
  }

  /// Obtém uma tarefa específica por ID
  Future<Todo?> getTodoById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) return null;

      return Todo.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Erro ao buscar tarefa: $e');
      return null;
    }
  }

  /// Obtém estatísticas das tarefas do usuário
  Future<Map<String, int>> getTodoStats() async {
    try {
      final todos = await getTodos();
      final total = todos.length;
      final completed = todos.where((todo) => todo.isCompleted).length;
      final pending = total - completed;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
      };
    } catch (e) {
      print('Erro ao calcular estatísticas: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
      };
    }
  }

  /// Remove todas as tarefas do usuário (uso cuidadoso)
  Future<bool> clearAllTodos() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: currentUser.id)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Erro ao limpar todas as tarefas: $e');
      return false;
    }
  }
}
