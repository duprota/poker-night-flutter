import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_night/widgets/error_message.dart';

void main() {
  testWidgets('ErrorMessage deve exibir a mensagem de erro fornecida', (WidgetTester tester) async {
    // Arrange
    const errorMessage = 'Erro ao carregar notificações';

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessage(message: errorMessage),
        ),
      ),
    );

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('ErrorMessage deve exibir o ícone de erro', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessage(message: 'Erro'),
        ),
      ),
    );

    // Assert
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('ErrorMessage deve exibir o botão de tentar novamente quando onRetry for fornecido', (WidgetTester tester) async {
    // Arrange
    bool retryPressed = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessage(
            message: 'Erro',
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Tentar novamente'), findsOneWidget);
    
    // Testar o callback
    await tester.tap(find.text('Tentar novamente'));
    expect(retryPressed, isTrue);
  });

  testWidgets('ErrorMessage não deve exibir o botão de tentar novamente quando onRetry não for fornecido', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessage(message: 'Erro'),
        ),
      ),
    );

    // Assert
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('ErrorMessage deve usar o ícone personalizado quando fornecido', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessage(
            message: 'Erro',
            icon: Icons.warning,
          ),
        ),
      ),
    );

    // Assert
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('ErrorMessage deve usar a cor personalizada quando fornecida', (WidgetTester tester) async {
    // Arrange
    const customColor = Colors.orange;

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessage(
            message: 'Erro',
            color: customColor,
          ),
        ),
      ),
    );

    // Assert
    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    expect(icon.color, equals(customColor));
  });

  testWidgets('ErrorMessage deve usar o texto personalizado para o botão quando fornecido', (WidgetTester tester) async {
    // Arrange
    const customButtonText = 'Recarregar';

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessage(
            message: 'Erro',
            retryText: customButtonText,
            onRetry: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text(customButtonText), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });
}
