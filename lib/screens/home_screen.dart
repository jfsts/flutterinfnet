import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../services/firestore_todo_service.dart';
import '../services/simple_firebase_auth_service.dart';
import '../widgets/todo_item.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreTodoService _todoService = FirestoreTodoService();
  final SimpleFirebaseAuthService _authService = SimpleFirebaseAuthService();
  User? _currentUser;
  late TabController _tabController;

  // Future para carregar tarefas
  Future<List<Todo>>? _todosFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserAndTodos();

    // Listener para detectar mudanças de aba
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        // Quando volta para aba Tarefas, recarrega os dados apenas se necessário
        if (_todosFuture == null) {
          _refreshTodos();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndTodos() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {
      _currentUser = user;
      _todosFuture = _todoService.getTodos(); // Carrega tarefas inicialmente
    });
  }

  /// Recarrega as tarefas
  void _refreshTodos() {
    if (mounted) {
      setState(() {
        _todosFuture = _todoService.getTodos();
      });
    }
  }

  Future<void> _toggleTodo(String id) async {
    final success = await _todoService.toggleTodo(id);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao alterar status da tarefa'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success) {
      // Atualizar lista após mudança
      _refreshTodos();
    }
  }

  Future<void> _deleteTodo(String id) async {
    final success = await _todoService.removeTodo(id);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao remover tarefa'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success) {
      // Atualizar lista após remoção
      _refreshTodos();
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final success = await _todoService.updateTodo(todo);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar tarefa'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success) {
      // Atualizar lista após edição
      _refreshTodos();
    }
  }

  Future<void> _logout() async {
    // Mostrar confirmação antes do logout
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text(
            'Tem certeza que deseja sair? Você precisará fazer login novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _showAddTodoForm() async {
    if (_currentUser == null) return;

    final result = await Navigator.of(context).pushNamed('/add-todo');

    // Se voltou da tela de adicionar tarefa, atualizar lista
    if (result == true) {
      _refreshTodos();
    }
  }

  Widget _buildTodoList() {
    return FutureBuilder<List<Todo>>(
      key: const Key(
          'todos_future_builder'), // Key para evitar reconstruções desnecessárias
      future: _todosFuture,
      builder: (context, snapshot) {
        print(
            '🔄 FutureBuilder - Connection: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, HasError: ${snapshot.hasError}');

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Erro
        if (snapshot.hasError) {
          print('❌ Erro no FutureBuilder: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Erro ao carregar tarefas'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshTodos,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        // Dados carregados
        final todos = snapshot.data ?? [];
        print('📋 Tarefas carregadas: ${todos.length}');

        if (todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma tarefa encontrada',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toque no + para adicionar sua primeira tarefa',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshTodos,
                  child: const Text('Atualizar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshTodos(),
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoItem(
                todo: todo,
                onToggle: _toggleTodo,
                onDelete: _deleteTodo,
                onEdit: _editTodo,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Tarefas',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Perfil',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodoList(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          // Só mostra o botão na aba de Tarefas (index 0)
          return _tabController.index == 0
              ? FloatingActionButton(
                  onPressed: _showAddTodoForm,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : const SizedBox.shrink(); // Widget vazio quando não deve mostrar
        },
      ),
    );
  }
}
