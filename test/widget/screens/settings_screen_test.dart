import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/locale_provider.dart';
import 'package:poker_night/screens/settings/settings_screen.dart';

// Mock para o GoRouter
class MockGoRouter extends Mock implements GoRouter {}

// Mock para o LocaleNotifier
class MockLocaleNotifier extends Mock implements LocaleNotifier {}

void main() {
  late MockGoRouter mockGoRouter;
  late MockLocaleNotifier mockLocaleNotifier;

  setUp(() {
    mockGoRouter = MockGoRouter();
    mockLocaleNotifier = MockLocaleNotifier();
    
    // Configurar comportamentos padrão
    when(() => mockLocaleNotifier.getCurrentLanguageName()).thenReturn('Português');
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        localeProvider.notifier.overrideWith((_) => mockLocaleNotifier),
        localeProvider.overrideWithValue(const Locale('pt')),
      ],
      child: InheritedGoRouter(
        goRouter: mockGoRouter,
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
          home: const SettingsScreen(),
        ),
      ),
    );
  }

  group('SettingsScreen Tests', () {
    testWidgets('Deve exibir o título da tela corretamente', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o título da tela é exibido
      expect(find.text('Configurações'), findsOneWidget);
    });

    testWidgets('Deve exibir a opção de idioma com o idioma atual', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se a opção de idioma é exibida
      expect(find.text('Idioma'), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
    });

    testWidgets('Deve navegar para a tela de configurações de idioma ao clicar na opção', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Clicar na opção de idioma
      await tester.tap(find.text('Idioma'));
      await tester.pumpAndSettle();
      
      // Verificar se o método go foi chamado com a rota correta
      verify(() => mockGoRouter.push('/settings/language')).called(1);
    });

    testWidgets('Deve exibir a opção de tema', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se a opção de tema é exibida
      expect(find.text('Tema'), findsOneWidget);
    });

    testWidgets('Deve exibir a opção de notificações', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se a opção de notificações é exibida
      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets('Deve exibir a opção de sobre o aplicativo', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se a opção de sobre o aplicativo é exibida
      expect(find.text('Sobre o aplicativo'), findsOneWidget);
    });

    testWidgets('Deve exibir o botão de voltar', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Verificar se o botão de voltar é exibido
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Deve voltar para a tela anterior ao clicar no botão de voltar', (WidgetTester tester) async {
      // Renderizar o widget
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Clicar no botão de voltar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verificar se o método pop foi chamado
      verify(() => mockGoRouter.pop()).called(1);
    });
  });
}

// Widget auxiliar para fornecer o GoRouter
class InheritedGoRouter extends InheritedWidget {
  final GoRouter goRouter;

  const InheritedGoRouter({
    Key? key,
    required this.goRouter,
    required Widget child,
  }) : super(key: key, child: child);

  static InheritedGoRouter of(BuildContext context) {
    final InheritedGoRouter? result =
        context.dependOnInheritedWidgetOfExactType<InheritedGoRouter>();
    assert(result != null, 'No InheritedGoRouter found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedGoRouter oldWidget) {
    return goRouter != oldWidget.goRouter;
  }
}
