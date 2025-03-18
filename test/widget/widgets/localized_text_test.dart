import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poker_night/widgets/common/localized_text.dart';

void main() {
  Widget createWidgetUnderTest({required String translationKey, Map<String, dynamic>? args}) {
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
      locale: const Locale('pt'), // Definir o idioma padrão para português
      home: Scaffold(
        body: LocalizedText(
          translationKey: translationKey,
          args: args,
        ),
      ),
    );
  }

  group('LocalizedText Widget Tests', () {
    testWidgets('Deve exibir o texto traduzido corretamente', (WidgetTester tester) async {
      // Renderizar o widget com uma chave de tradução simples
      await tester.pumpWidget(createWidgetUnderTest(translationKey: 'app_name'));
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o texto traduzido é exibido
      expect(find.text('Poker Night'), findsOneWidget);
    });

    testWidgets('Deve exibir o texto traduzido com argumentos corretamente', (WidgetTester tester) async {
      // Renderizar o widget com uma chave de tradução que aceita argumentos
      await tester.pumpWidget(createWidgetUnderTest(
        translationKey: 'welcome_user',
        args: {'name': 'João'},
      ));
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o texto traduzido com o argumento é exibido
      expect(find.text('Bem-vindo, João!'), findsOneWidget);
    });

    testWidgets('Deve aplicar o estilo de texto corretamente', (WidgetTester tester) async {
      // Renderizar o widget com um estilo de texto personalizado
      await tester.pumpWidget(
        MaterialApp(
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
          locale: const Locale('pt'),
          home: Scaffold(
            body: LocalizedText(
              translationKey: 'app_name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Encontrar o widget Text
      final textWidget = tester.widget<Text>(find.text('Poker Night'));
      
      // Verificar se o estilo foi aplicado corretamente
      expect(textWidget.style!.fontSize, 24);
      expect(textWidget.style!.fontWeight, FontWeight.bold);
      expect(textWidget.style!.color, Colors.red);
    });

    testWidgets('Deve aplicar o alinhamento de texto corretamente', (WidgetTester tester) async {
      // Renderizar o widget com um alinhamento personalizado
      await tester.pumpWidget(
        MaterialApp(
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
          locale: const Locale('pt'),
          home: Scaffold(
            body: LocalizedText(
              translationKey: 'app_name',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Encontrar o widget Text
      final textWidget = tester.widget<Text>(find.text('Poker Night'));
      
      // Verificar se o alinhamento foi aplicado corretamente
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('Deve exibir o texto traduzido em inglês quando o idioma é alterado', (WidgetTester tester) async {
      // Renderizar o widget com o idioma inglês
      await tester.pumpWidget(
        MaterialApp(
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
          locale: const Locale('en'), // Definir o idioma para inglês
          home: Scaffold(
            body: LocalizedText(
              translationKey: 'app_name',
            ),
          ),
        ),
      );
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o texto traduzido em inglês é exibido
      expect(find.text('Poker Night'), findsOneWidget);
    });
  });
}
