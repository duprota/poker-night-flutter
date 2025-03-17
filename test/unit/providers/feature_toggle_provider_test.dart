import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import '../../mocks/supabase_mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestBuilder mockPostgrestBuilder;
  late MockPostgrestFilterBuilder mockPostgrestFilterBuilder;
  late ProviderContainer container;

  setUp(() {
    // Configurar os mocks
    mockSupabaseClient = SupabaseMocks.createMockSupabaseClient();
    mockPostgrestBuilder = MockPostgrestBuilder();
    mockPostgrestFilterBuilder = MockPostgrestFilterBuilder();
    
    // Configurar o comportamento do mockSupabaseClient
    when(() => mockSupabaseClient.from('feature_toggles'))
        .thenReturn(mockPostgrestBuilder);
    when(() => mockPostgrestBuilder.select())
        .thenReturn(mockPostgrestFilterBuilder);
    
    // Substituir a implementação do SupabaseService.client
    SupabaseService.client = mockSupabaseClient;
    
    // Criar o container do Riverpod
    container = ProviderContainer();
  });

  tearDown(() {
    // Limpar o container após cada teste
    container.dispose();
  });

  group('FeatureToggleProvider Tests', () {
    test('Estado inicial deve ter todas as features desabilitadas', () {
      // Obter o estado inicial
      final featureToggleState = container.read(featureToggleProvider);
      
      // Verificar se o estado inicial tem todas as features desabilitadas
      expect(featureToggleState.enabledFeatures, isEmpty);
      expect(featureToggleState.isLoading, false);
      expect(featureToggleState.error, null);
    });

    test('loadFeatureToggles deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar dados de feature toggles
      when(() => mockPostgrestFilterBuilder.order('feature', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenAnswer((_) async => PostgrestResponse(
            data: [
              {
                'feature': 'createGame',
                'enabled': true,
                'subscription_level': 'free'
              },
              {
                'feature': 'statistics',
                'enabled': true,
                'subscription_level': 'pro'
              },
              {
                'feature': 'darkMode',
                'enabled': true,
                'subscription_level': 'all'
              },
              {
                'feature': 'tournaments',
                'enabled': false,
                'subscription_level': 'pro'
              }
            ],
            count: 4,
            status: 200,
            error: null,
            statusText: 'OK'
          ));
      
      // Executar o método de carregamento de feature toggles
      await container.read(featureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se o estado foi atualizado corretamente
      final featureToggleState = container.read(featureToggleProvider);
      expect(featureToggleState.enabledFeatures.length, 3);
      expect(featureToggleState.enabledFeatures, contains(Feature.createGame));
      expect(featureToggleState.enabledFeatures, contains(Feature.statistics));
      expect(featureToggleState.enabledFeatures, contains(Feature.darkMode));
      expect(featureToggleState.enabledFeatures, isNot(contains(Feature.tournaments)));
      expect(featureToggleState.isLoading, false);
      expect(featureToggleState.error, null);
    });

    test('loadFeatureToggles deve atualizar o estado corretamente quando falhar', () async {
      // Configurar o mock para lançar uma exceção
      when(() => mockPostgrestFilterBuilder.order('feature', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenThrow(Exception('Failed to load feature toggles'));
      
      // Executar o método de carregamento de feature toggles
      await container.read(featureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se o estado foi atualizado corretamente
      final featureToggleState = container.read(featureToggleProvider);
      expect(featureToggleState.enabledFeatures, isEmpty);
      expect(featureToggleState.isLoading, false);
      expect(featureToggleState.error, 'Failed to load feature toggles');
    });
    
    test('isFeatureEnabled deve retornar corretamente com base no estado', () async {
      // Configurar o mock para retornar dados de feature toggles
      when(() => mockPostgrestFilterBuilder.order('feature', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenAnswer((_) async => PostgrestResponse(
            data: [
              {
                'feature': 'createGame',
                'enabled': true,
                'subscription_level': 'free'
              },
              {
                'feature': 'statistics',
                'enabled': true,
                'subscription_level': 'pro'
              }
            ],
            count: 2,
            status: 200,
            error: null,
            statusText: 'OK'
          ));
      
      // Executar o método de carregamento de feature toggles
      await container.read(featureToggleProvider.notifier).loadFeatureToggles();
      
      // Verificar se o método isFeatureEnabled retorna corretamente
      final notifier = container.read(featureToggleProvider.notifier);
      expect(notifier.isFeatureEnabled(Feature.createGame), true);
      expect(notifier.isFeatureEnabled(Feature.statistics), true);
      expect(notifier.isFeatureEnabled(Feature.tournaments), false);
    });
    
    test('toggleFeature deve alterar o estado corretamente', () {
      final notifier = container.read(featureToggleProvider.notifier);
      
      // Habilitar uma feature
      notifier.toggleFeature(Feature.createGame, true);
      expect(notifier.isFeatureEnabled(Feature.createGame), true);
      
      // Desabilitar a feature
      notifier.toggleFeature(Feature.createGame, false);
      expect(notifier.isFeatureEnabled(Feature.createGame), false);
      
      // Habilitar outra feature
      notifier.toggleFeature(Feature.statistics, true);
      expect(notifier.isFeatureEnabled(Feature.statistics), true);
      expect(notifier.isFeatureEnabled(Feature.createGame), false);
    });
  });
}
