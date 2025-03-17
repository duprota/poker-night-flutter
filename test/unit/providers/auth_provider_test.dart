import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../mocks/supabase_mocks.dart';

// Mock para o SupabaseService
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;
  late MockSession mockSession;
  late ProviderContainer container;

  setUp(() {
    // Configurar os mocks
    mockSupabaseClient = SupabaseMocks.createMockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = SupabaseMocks.createMockUser();
    mockSession = SupabaseMocks.createMockSession(user: mockUser);
    
    // Configurar o comportamento do mockSupabaseClient
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    // Substituir a implementação do SupabaseService.client
    SupabaseService.client = mockSupabaseClient;
    
    // Criar o container do Riverpod
    container = ProviderContainer();
  });

  tearDown(() {
    // Limpar o container após cada teste
    container.dispose();
  });

  group('AuthNotifier Tests', () {
    test('Estado inicial deve ser anônimo', () {
      // Configurar o mock para retornar null para a sessão atual
      when(() => mockGoTrueClient.currentSession).thenReturn(null);
      when(() => mockGoTrueClient.currentUser).thenReturn(null);
      
      // Obter o estado inicial
      final authState = container.read(authProvider);
      
      // Verificar se o estado inicial é anônimo
      expect(authState.isAnonymous, true);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.free);
    });

    test('signIn deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar uma sessão válida
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => AuthResponse(
        session: mockSession,
        user: mockUser,
      ));
      
      // Configurar o mock para retornar dados de assinatura
      final mockPostgrestFilterBuilder = MockPostgrestFilterBuilder();
      final mockPostgrestBuilder = MockPostgrestBuilder();
      
      when(() => mockSupabaseClient.from('user_subscriptions'))
          .thenReturn(mockPostgrestBuilder);
      when(() => mockPostgrestBuilder.select())
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.eq('user_id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.single())
          .thenAnswer((_) async => {'status': 'premium'});
      
      // Executar o método de login
      await container.read(authProvider.notifier).signIn(
        email: 'test@example.com',
        password: 'password',
      );
      
      // Verificar se o estado foi atualizado corretamente
      final authState = container.read(authProvider);
      expect(authState.isAnonymous, false);
      expect(authState.user, isNotNull);
      expect(authState.isLoading, false);
      expect(authState.error, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.premium);
      
      // Verificar se o método foi chamado com os parâmetros corretos
      verify(() => mockGoTrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password',
      )).called(1);
    });

    test('signIn deve atualizar o estado corretamente quando falhar', () async {
      // Configurar o mock para lançar uma exceção
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Invalid login credentials'));
      
      // Executar o método de login
      await container.read(authProvider.notifier).signIn(
        email: 'test@example.com',
        password: 'wrong-password',
      );
      
      // Verificar se o estado foi atualizado corretamente
      final authState = container.read(authProvider);
      expect(authState.isAnonymous, true);
      expect(authState.user, null);
      expect(authState.isLoading, false);
      expect(authState.error, 'Invalid login credentials');
      
      // Verificar se o método foi chamado com os parâmetros corretos
      verify(() => mockGoTrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'wrong-password',
      )).called(1);
    });
    
    test('hasAccess deve retornar corretamente com base no status de assinatura', () {
      // Configurar o mock para ter um usuário com assinatura premium
      when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      
      final notifier = container.read(authProvider.notifier);
      
      // Definir o estado manualmente para teste
      notifier.updateSubscriptionStatus(SubscriptionStatus.premium);
      
      // Verificar permissões
      expect(notifier.hasAccess(SubscriptionFeature.createGame), true);
      expect(notifier.hasAccess(SubscriptionFeature.unlimitedPlayers), true);
      expect(notifier.hasAccess(SubscriptionFeature.statistics), false); // Requer Pro
      
      // Atualizar para Pro e verificar novamente
      notifier.updateSubscriptionStatus(SubscriptionStatus.pro);
      expect(notifier.hasAccess(SubscriptionFeature.statistics), true);
      
      // Voltar para Free e verificar novamente
      notifier.updateSubscriptionStatus(SubscriptionStatus.free);
      expect(notifier.hasAccess(SubscriptionFeature.unlimitedPlayers), false);
    });
  });
}
