import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_night/widgets/loading_indicator.dart';

void main() {
  testWidgets('LoadingIndicator deve exibir um CircularProgressIndicator', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingIndicator não deve exibir mensagem quando nenhuma for fornecida', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(),
        ),
      ),
    );

    // Assert
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('LoadingIndicator deve exibir a mensagem personalizada quando fornecida', (WidgetTester tester) async {
    // Arrange
    const customMessage = 'Carregando notificações...';

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(message: customMessage),
        ),
      ),
    );

    // Assert
    expect(find.text(customMessage), findsOneWidget);
  });

  testWidgets('LoadingIndicator deve usar o tamanho personalizado quando fornecido', (WidgetTester tester) async {
    // Arrange
    const customSize = 48.0;

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(size: customSize),
        ),
      ),
    );

    // Assert
    final progressIndicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    
    expect(progressIndicator.strokeWidth, equals(4.0)); // Valor padrão
    
    final sizedBox = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      ).first,
    );
    
    expect(sizedBox.width, equals(customSize));
    expect(sizedBox.height, equals(customSize));
  });

  testWidgets('LoadingIndicator deve usar a cor personalizada quando fornecida', (WidgetTester tester) async {
    // Arrange
    const customColor = Colors.red;

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(color: customColor),
        ),
      ),
    );

    // Assert
    final progressIndicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    
    expect(progressIndicator.valueColor?.value, equals(customColor));
  });
}
