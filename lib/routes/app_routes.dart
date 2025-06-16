import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_todo_screen.dart';
import '../screens/profile_screen.dart';

/// Classe que define todas as rotas nomeadas do aplicativo
class AppRoutes {
  // Nomes das rotas
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String addTodo = '/add-todo';
  static const String profile = '/profile';

  /// Mapa de rotas do aplicativo
  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        resetPassword: (context) => const ResetPasswordScreen(),
        home: (context) => const HomeScreen(),
        addTodo: (context) => const AddTodoScreen(),
        profile: (context) => const ProfileScreen(),
      };

  /// Rota inicial do aplicativo
  static const String initialRoute = login;

  /// Gerador de rotas para rotas dinâmicas
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        // Pode receber email como argumento
        final email = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: RouteSettings(name: login, arguments: email),
        );

      case register:
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
          settings: const RouteSettings(name: register),
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (context) => const ResetPasswordScreen(),
          settings: const RouteSettings(name: resetPassword),
        );

      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: const RouteSettings(name: home),
        );

      case addTodo:
        return MaterialPageRoute(
          builder: (context) => const AddTodoScreen(),
          settings: const RouteSettings(name: addTodo),
        );

      case profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: const RouteSettings(name: profile),
        );

      default:
        return null;
    }
  }

  /// Rota de erro para rotas não encontradas
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Página não encontrada'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'A página solicitada não existe.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
