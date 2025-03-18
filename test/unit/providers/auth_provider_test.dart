import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import '../../mocks/supabase_mocks.dart';

void main() {
  late MockSupabaseService mockSupabaseService;
  late ProviderContainer container;

  // Provider para o mock do SupabaseService
  final mockSupabaseServiceProvider = Provider<SupabaseService>((ref) {
    return mockSupabaseService;
  });

  // Provider para o AuthNotifier com o mock do SupabaseService
  final testAuthProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    return AuthNotifier(ref, mockSupabaseServiceProvider);
  });

  setUpAll(() {
    // Registrar valores de fallback para enums
    setUpMockSupabase();
  });

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    container = ProviderContainer(
      overrides: [
        supabaseServiceProvider.overrideWithProvider(mockSupabaseServiceProvider),
        authProvider.overrideWithProvider(testAuthProvider),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthProvider', () {
    test('estado inicial deve ser anônimo', () {
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, true);
      expect(authState.user, null);
      expect(authState.errorMessage, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.free);
    });

    test('checkSession deve atualizar o estado quando o usuário está autenticado', () async {
      // Configurar o mock para retornar um usuário autenticado
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {'name': 'Test User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      when(() => mockSupabaseService.getCurrentUser()).thenReturn(mockUser);
      when(() => mockSupabaseService.getUserSubscriptionStatus('test-user-id'))
          .thenAnswer((_) async => SubscriptionStatus.premium);

      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).checkSession();

      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, false);
      expect(authState.user, mockUser);
      expect(authState.errorMessage, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.premium);
    });

    test('checkSession deve definir o estado como anônimo quando o usuário não está autenticado', () async {
      // Configurar o mock para retornar null (usuário não autenticado)
      when(() => mockSupabaseService.getCurrentUser()).thenReturn(null);

      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).checkSession();

      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, true);
      expect(authState.user, null);
      expect(authState.errorMessage, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.free);
    });

    test('signIn deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar uma resposta de autenticação válida
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {'name': 'Test User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      final mockAuthResponse = AuthResponse(
        user: mockUser,
        session: Session(
          accessToken: 'test-access-token',
          tokenType: 'bearer',
          refreshToken: 'test-refresh-token',
          expiresIn: 3600,
          user: mockUser,
        ),
      );
      
      when(() => mockSupabaseService.signInWithEmail(
            email: 'test@example.com',
            password: 'password',
          )).thenAnswer((_) async => mockAuthResponse);
      
      when(() => mockSupabaseService.getUserSubscriptionStatus('test-user-id'))
          .thenAnswer((_) async => SubscriptionStatus.premium);

      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).signIn('test@example.com', 'password');

      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, false);
      expect(authState.user, mockUser);
      expect(authState.errorMessage, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.premium);
    });

    test('signIn deve atualizar o estado com erro quando falhar', () async {
      // Configurar o mock para lançar uma exceção
      when(() => mockSupabaseService.signInWithEmail(
            email: 'test@example.com',
            password: 'password',
          )).thenThrow(Exception('Falha na autenticação'));

      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).signIn('test@example.com', 'password');

      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, true);
      expect(authState.user, null);
      expect(authState.errorMessage, contains('Falha na autenticação'));
      expect(authState.subscriptionStatus, SubscriptionStatus.free);
    });

    test('signUp deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar uma resposta de autenticação válida
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {'name': 'Test User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      final mockAuthResponse = AuthResponse(
        user: mockUser,
        session: Session(
          accessToken: 'test-access-token',
          tokenType: 'bearer',
          refreshToken: 'test-refresh-token',
          expiresIn: 3600,
          user: mockUser,
        ),
      );
      
      when(() => mockSupabaseService.signUpWithEmail(
            email: 'test@example.com',
            password: 'password',
            name: 'Test User',
          )).thenAnswer((_) async => mockAuthResponse);
      
      when(() => mockSupabaseService.getUserSubscriptionStatus('test-user-id'))
          .thenAnswer((_) async => SubscriptionStatus.free);

      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).signUp('test@example.com', 'password', 'Test User');

      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, false);
      expect(authState.user, mockUser);
      expect(authState.errorMessage, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.free);
    });

    test('signOut deve atualizar o estado para anônimo', () async {
      // Primeiro, configurar um estado autenticado
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {'name': 'Test User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      when(() => mockSupabaseService.getCurrentUser()).thenReturn(mockUser);
      when(() => mockSupabaseService.getUserSubscriptionStatus('test-user-id'))
          .thenAnswer((_) async => SubscriptionStatus.premium);
      
      await container.read(testAuthProvider.notifier).checkSession();
      
      // Verificar que o estado está autenticado
      expect(container.read(testAuthProvider).isAnonymous, false);
      
      // Configurar o mock para signOut
      when(() => mockSupabaseService.signOut()).thenAnswer((_) async {});
      
      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).signOut();
      
      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.isAnonymous, true);
      expect(authState.user, null);
      expect(authState.errorMessage, null);
      expect(authState.subscriptionStatus, SubscriptionStatus.free);
    });

    test('updateSubscription deve atualizar o status da assinatura', () async {
      // Primeiro, configurar um estado autenticado
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {'name': 'Test User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      when(() => mockSupabaseService.getCurrentUser()).thenReturn(mockUser);
      when(() => mockSupabaseService.getUserSubscriptionStatus('test-user-id'))
          .thenAnswer((_) async => SubscriptionStatus.free);
      
      await container.read(testAuthProvider.notifier).checkSession();
      
      // Verificar que o estado está autenticado com assinatura free
      final initialState = container.read(testAuthProvider);
      expect(initialState.isAnonymous, false);
      expect(initialState.subscriptionStatus, SubscriptionStatus.free);
      
      // Configurar o mock para updateUserSubscription
      when(() => mockSupabaseService.updateUserSubscription(
            userId: 'test-user-id',
            status: SubscriptionStatus.pro,
          )).thenAnswer((_) async {});
      
      // Executar o método a ser testado
      await container.read(testAuthProvider.notifier).updateSubscription(SubscriptionStatus.pro);
      
      // Verificar o estado resultante
      final authState = container.read(testAuthProvider);
      expect(authState.subscriptionStatus, SubscriptionStatus.pro);
    });

    test('hasAccess deve retornar false para usuário anônimo', () {
      // Garantir que o estado é anônimo
      expect(container.read(testAuthProvider).isAnonymous, true);
      
      // Verificar acesso para várias funcionalidades
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.createGame), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.joinGame), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.unlimitedPlayers), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.statistics), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.exportData), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.customThemes), false);
    });

    test('hasAccess deve retornar valores corretos baseados no status da assinatura', () async {
      // Configurar um estado autenticado com assinatura premium
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {'name': 'Test User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      when(() => mockSupabaseService.getCurrentUser()).thenReturn(mockUser);
      when(() => mockSupabaseService.getUserSubscriptionStatus('test-user-id'))
          .thenAnswer((_) async => SubscriptionStatus.premium);
      
      await container.read(testAuthProvider.notifier).checkSession();
      
      // Verificar acesso para usuário premium
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.createGame), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.joinGame), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.unlimitedPlayers), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.statistics), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.exportData), false);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.customThemes), true);
      
      // Atualizar para assinatura pro
      when(() => mockSupabaseService.updateUserSubscription(
            userId: 'test-user-id',
            status: SubscriptionStatus.pro,
          )).thenAnswer((_) async {});
      
      await container.read(testAuthProvider.notifier).updateSubscription(SubscriptionStatus.pro);
      
      // Verificar acesso para usuário pro
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.createGame), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.joinGame), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.unlimitedPlayers), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.statistics), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.exportData), true);
      expect(container.read(testAuthProvider.notifier).hasAccess(SubscriptionFeature.customThemes), true);
    });
  });
}
