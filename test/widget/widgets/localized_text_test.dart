import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poker_night/widgets/common/localized_text.dart';

void main() {
  // Widget com construtor padrão (compatibilidade)
  Widget createWidgetUnderTest({String Function(AppLocalizations)? textBuilder, String? translationKey, Map<String, dynamic>? args}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
      ],
      locale: const Locale('en'), // Definir o idioma padrão para inglês para consistência nos testes
      home: Scaffold(
        body: textBuilder != null 
            ? LocalizedText(textBuilder: textBuilder)
            : LocalizedText.key(
                translationKey: translationKey ?? 'appTitle',
                args: args,
              ),
      ),
    );
  }

  group('LocalizedText Widget Tests', () {
    testWidgets('Deve exibir o texto traduzido corretamente usando textBuilder', (WidgetTester tester) async {
      // Renderizar o widget com textBuilder
      await tester.pumpWidget(createWidgetUnderTest(
        textBuilder: (l10n) => l10n.appTitle,
      ));
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o texto traduzido é exibido
      expect(find.text('Poker Night'), findsOneWidget);
    });

    testWidgets('Deve exibir o texto traduzido corretamente usando translationKey', (WidgetTester tester) async {
      // Renderizar o widget com translationKey
      await tester.pumpWidget(createWidgetUnderTest(
        translationKey: 'appTitle',
      ));
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o texto traduzido é exibido
      expect(find.text('Poker Night'), findsOneWidget);
    });

    testWidgets('Deve exibir texto de fallback quando a tradução não existe', (WidgetTester tester) async {
      // Renderizar o widget com uma chave de tradução inexistente
      await tester.pumpWidget(createWidgetUnderTest(
        translationKey: 'non_existent_key',
      ));
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o texto de fallback é exibido
      expect(find.text('Missing translation'), findsOneWidget);
    });
  });
}
