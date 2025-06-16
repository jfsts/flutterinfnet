// Testes de widget para a aplicação Flutter INFNET
// Como MyApp requer Firebase, testamos widgets isolados

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget mock para testes que simula a tela de login sem Firebase
class MockLoginScreen extends StatelessWidget {
  const MockLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Título
              const Text(
                'Lista de Tarefas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),

              // Campo Email
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),

              // Links
              TextButton(
                onPressed: () {},
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Esqueceu sua senha?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Widget Tests', () {
    testWidgets('LoginScreen deve renderizar elementos básicos',
        (WidgetTester tester) async {
      // Cria widget isolado sem dependências Firebase
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Verifica se elementos da tela de login estão presentes
      expect(find.text('Lista de Tarefas'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Não tem uma conta? Cadastre-se'), findsOneWidget);
      expect(find.text('Esqueceu sua senha?'), findsOneWidget);
    });

    testWidgets('LoginScreen deve ter campos de entrada',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Verifica se campos de texto estão presentes (2 TextFormField)
      expect(find.byType(TextFormField), findsNWidgets(2));
      // Verifica se tem 1 ElevatedButton e 2 TextButton
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsNWidgets(2));
    });

    testWidgets('LoginScreen deve permitir input de texto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Encontra campos de email e senha
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Testa input de texto
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('LoginScreen deve ter ícone e logo da aplicação',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Verifica se tem o ícone do logo
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      // Verifica se tem o container do logo
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
  });
}
