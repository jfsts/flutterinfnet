import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../services/todo_service.dart';
import '../services/auth_service.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_form.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TodoService _todoService = TodoService();
  final AuthService _authService = AuthService();
  List<Todo> _todos = [];
  User? _currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserAndTodos();
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() => _currentUser = user);
    await _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _todoService.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  Future<void> _addTodo(Todo todo) async {
    await _todoService.addTodo(todo);
    await _loadTodos();
  }

  Future<void> _toggleTodo(String id) async {
    await _todoService.toggleTodo(id);
    await _loadTodos();
  }

  Future<void> _deleteTodo(String id) async {
    await _todoService.removeTodo(id);
    await _loadTodos();
  }

  Future<void> _editTodo(Todo todo) async {
    await _todoService.updateTodo(todo);
    await _loadTodos();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showAddTodoForm() {
    if (_currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          body: SafeArea(
            child: AddTodoForm(
              onAdd: _addTodo,
              userId: _currentUser!.id,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return TodoItem(
          todo: todo,
          onToggle: _toggleTodo,
          onDelete: _deleteTodo,
          onEdit: _editTodo,
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
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddTodoForm,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
