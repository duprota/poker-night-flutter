import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poker_night/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Teste de inicialização do app', (WidgetTester tester) async {
      // Inicializa o app
      app.main();
      
      // Aguarda a renderização completa
      await tester.pumpAndSettle();
      
      // Verifica se o app iniciou corretamente
      // Isso dependerá da sua tela inicial, mas podemos verificar algo básico
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
