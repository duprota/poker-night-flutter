import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/core/router/app_router.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/features/auth/presentation/screens/login_screen.dart';
import 'package:poker_night/features/games/presentation/screens/games_list_screen.dart';
import '../../mocks/supabase_mocks.dart';

// Mock para o SupabaseService
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late GoRouter router;

  setUp(() {
    // Configurar os mocks
    mockSupabaseClient = SupabaseMocks.createMockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    // Configurar o comportamento do mockSupabaseClient
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    // Substituir a implementação do SupabaseService.client
    SupabaseService.client = mockSupabaseClient;
    
    // Inicializar o router
    final container = ProviderContainer();
    router = container.read(appRouterProvider);
  });

  group('Testes de Navegação', () {
    testWidgets('Deve redirecionar para login quando não autenticado', (WidgetTester tester) async {
      // Configurar o mock para retornar null para a sessão atual
      when(() => mockGoTrueClient.currentSession).thenReturn(null);
      when(() => mockGoTrueClient.currentUser).thenReturn(null);
      
      // Definir a propriedade isAuthenticated
      SupabaseService.isAuthenticated = false;
      
      // Renderizar o app com o router
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Tentar navegar para a tela de jogos
      router.go('/games');
      await tester.pumpAndSettle();
      
      // Verificar se foi redirecionado para a tela de login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(GamesListScreen), findsNothing);
    });

    testWidgets('Deve navegar para a tela de jogos quando autenticado', (WidgetTester tester) async {
      // Configurar o mock para retornar uma sessão válida
      final mockUser = SupabaseMocks.createMockUser();
      final mockSession = SupabaseMocks.createMockSession(user: mockUser);
      
      when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      
      // Definir a propriedade isAuthenticated
      SupabaseService.isAuthenticated = true;
      
      // Renderizar o app com o router
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Navegar para a tela de jogos
      router.go('/games');
      await tester.pumpAndSettle();
      
      // Verificar se está na tela de jogos
      expect(find.byType(GamesListScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Deve redirecionar para jogos quando autenticado e tentar acessar login', (WidgetTester tester) async {
      // Configurar o mock para retornar uma sessão válida
      final mockUser = SupabaseMocks.createMockUser();
      final mockSession = SupabaseMocks.createMockSession(user: mockUser);
      
      when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      
      // Definir a propriedade isAuthenticated
      SupabaseService.isAuthenticated = true;
      
      // Renderizar o app com o router
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Aguardar a renderização completa
      await tester.pumpAndSettle();
      
      // Tentar navegar para a tela de login
      router.go('/login');
      await tester.pumpAndSettle();
      
      // Verificar se foi redirecionado para a tela de jogos
      expect(find.byType(GamesListScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
