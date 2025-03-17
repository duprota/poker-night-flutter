import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/locale_provider.dart';
import 'package:poker_night/screens/settings/language_settings_screen.dart';

// Mock para o LocaleNotifier
class MockLocaleNotifier extends Mock implements LocaleNotifier {}

void main() {
  late MockLocaleNotifier mockLocaleNotifier;

  setUp(() {
    mockLocaleNotifier = MockLocaleNotifier();
    
    // Configurar comportamentos padrão
    when(() => mockLocaleNotifier.getCurrentLanguageName()).thenReturn('Português');
    when(() => mockLocaleNotifier.getSupportedLanguages()).thenReturn([
      {'code': 'pt', 'name': 'Português', 'locale': const Locale('pt')},
      {'code': 'en', 'name': 'English', 'locale': const Locale('en')},
    ]);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        localeProvider.notifier.overrideWith((_) => mockLocaleNotifier),
        localeProvider.overrideWithValue(const Locale('pt')),
      ],
      child: MaterialApp(
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
        home: const LanguageSettingsScreen(),
      ),
    );
  }

  group('LanguageSettingsScreen Tests', () {
    testWidgets('Deve exibir a lista de idiomas suportados', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se os idiomas são exibidos
      expect(find.text('Português'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('Deve marcar o idioma atual como selecionado', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o idioma atual está marcado como selecionado
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Verificar se o card do idioma atual tem a borda colorida
      final card = tester.widget<Card>(
        find.ancestor(
          of: find.text('Português'),
          matching: find.byType(Card),
        ).first,
      );
      expect(card.shape, isA<RoundedRectangleBorder>());
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side, isNot(BorderSide.none));
    });

    testWidgets('Deve chamar setLocale ao selecionar um idioma', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Clicar no idioma inglês
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      
      // Verificar se o método setLocale foi chamado com o idioma correto
      verify(() => mockLocaleNotifier.setLocale(const Locale('en'))).called(1);
    });
  });
}
