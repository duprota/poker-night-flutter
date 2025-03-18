import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import '../../mocks/supabase_mocks.dart';

void main() {
  late MockSupabaseService mockSupabaseService;
  late ProviderContainer container;

  // Provider para o mock do SupabaseService
  final mockSupabaseServiceProvider = Provider<SupabaseService>((ref) {
    return mockSupabaseService;
  });

  // Provider para o FeatureToggleNotifier com o mock do SupabaseService
  final testFeatureToggleProvider = StateNotifierProvider<FeatureToggleNotifier, FeatureToggleState>((ref) {
    return FeatureToggleNotifier(ref.read(mockSupabaseServiceProvider));
  });

  setUpAll(() {
    // Registrar valores de fallback para enums
    setUpMockSupabase();
  });

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    container = ProviderContainer(
      overrides: [
        mockSupabaseServiceProvider.overrideWithValue(mockSupabaseService),
        featureToggleProvider.overrideWithProvider(testFeatureToggleProvider),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FeatureToggleProvider Tests', () {
    test('Estado inicial deve ter isLoading como true', () {
      // Simular que o loadFeatureToggles ainda não foi chamado
      when(() => mockSupabaseService.getFeatureToggles())
          .thenAnswer((_) async => []);
      
      // Obter o estado inicial
      final featureToggleState = container.read(testFeatureToggleProvider);
      
      // Verificar se o estado inicial tem isLoading como true
      expect(featureToggleState.features, isEmpty);
      expect(featureToggleState.isLoading, true);
      expect(featureToggleState.errorMessage, null);
    });

    test('loadFeatureToggles deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar dados de feature toggles
      when(() => mockSupabaseService.getFeatureToggles())
          .thenAnswer((_) async => [
                {
                  'feature': 'createGame',
                  'enabled': true,
                  'subscription_level': 'free'
                },
                {
                  'feature': 'joinGame',
                  'enabled': true,
                  'subscription_level': 'free'
                },
                {
                  'feature': 'statistics',
                  'enabled': true,
                  'subscription_level': 'premium'
                },
              ]);
      
      // Chamar o método a ser testado
      await container.read(testFeatureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se o estado foi atualizado corretamente
      final featureToggleState = container.read(testFeatureToggleProvider);
      expect(featureToggleState.features.length, 3);
      expect(featureToggleState.features[Feature.createGame], true);
      expect(featureToggleState.features[Feature.joinGame], true);
      expect(featureToggleState.features[Feature.statistics], true);
      expect(featureToggleState.subscriptionLevels[Feature.createGame], 'free');
      expect(featureToggleState.subscriptionLevels[Feature.statistics], 'premium');
      expect(featureToggleState.isLoading, false);
      expect(featureToggleState.errorMessage, null);
    });

    test('loadFeatureToggles deve atualizar o estado com erro quando falhar', () async {
      // Configurar o mock para lançar uma exceção
      when(() => mockSupabaseService.getFeatureToggles())
          .thenThrow(Exception('Erro ao carregar feature toggles'));
      
      // Chamar o método a ser testado
      await container.read(testFeatureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se o estado foi atualizado com o erro
      final featureToggleState = container.read(testFeatureToggleProvider);
      expect(featureToggleState.isLoading, false);
      expect(featureToggleState.errorMessage, isNotNull);
    });

    test('isFeatureEnabled deve retornar o valor correto', () async {
      // Configurar o mock para retornar dados de feature toggles
      when(() => mockSupabaseService.getFeatureToggles())
          .thenAnswer((_) async => [
                {
                  'feature': 'createGame',
                  'enabled': true,
                  'subscription_level': 'free'
                },
                {
                  'feature': 'statistics',
                  'enabled': false,
                  'subscription_level': 'premium'
                },
              ]);
      
      // Carregar os feature toggles
      await container.read(testFeatureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se isFeatureEnabled retorna o valor correto
      final notifier = container.read(testFeatureToggleProvider.notifier);
      expect(notifier.isFeatureEnabled(Feature.createGame), true);
      expect(notifier.isFeatureEnabled(Feature.statistics), false);
      expect(notifier.isFeatureEnabled(Feature.darkMode), false); // Feature não carregada
    });

    test('getRequiredSubscription deve retornar o valor correto', () async {
      // Configurar o mock para retornar dados de feature toggles
      when(() => mockSupabaseService.getFeatureToggles())
          .thenAnswer((_) async => [
                {
                  'feature': 'createGame',
                  'enabled': true,
                  'subscription_level': 'free'
                },
                {
                  'feature': 'statistics',
                  'enabled': true,
                  'subscription_level': 'premium'
                },
              ]);
      
      // Carregar os feature toggles
      await container.read(testFeatureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se getRequiredSubscription retorna o valor correto
      final notifier = container.read(testFeatureToggleProvider.notifier);
      expect(notifier.getRequiredSubscription(Feature.createGame), 'free');
      expect(notifier.getRequiredSubscription(Feature.statistics), 'premium');
      expect(notifier.getRequiredSubscription(Feature.darkMode), 'free'); // Feature não carregada
    });

    test('updateFeatureToggle deve atualizar o estado corretamente', () async {
      // Configurar o mock para retornar dados de feature toggles
      when(() => mockSupabaseService.getFeatureToggles())
          .thenAnswer((_) async => [
                {
                  'feature': 'createGame',
                  'enabled': true,
                  'subscription_level': 'free'
                },
              ]);
      
      // Configurar o mock para updateFeatureToggle
      when(() => mockSupabaseService.updateFeatureToggle(
            feature: any(named: 'feature'),
            enabled: any(named: 'enabled'),
            subscriptionLevel: any(named: 'subscriptionLevel'),
          )).thenAnswer((_) async {});
      
      // Carregar os feature toggles
      await container.read(testFeatureToggleProvider.notifier).loadFeatureToggles();
      
      // Chamar o método a ser testado
      await container.read(testFeatureToggleProvider.notifier).updateFeatureToggle(
            Feature.createGame,
            false,
            'premium',
          );
      
      // Verificar se o estado foi atualizado corretamente
      final featureToggleState = container.read(testFeatureToggleProvider);
      expect(featureToggleState.features[Feature.createGame], false);
      expect(featureToggleState.subscriptionLevels[Feature.createGame], 'premium');
    });
  });
}
