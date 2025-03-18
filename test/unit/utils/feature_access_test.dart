import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';
import 'package:poker_night/utils/feature_access.dart';

// Mocks para os notifiers
class MockAuthNotifier extends Mock implements AuthNotifier {}
class MockFeatureToggleNotifier extends Mock implements FeatureToggleNotifier {}

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockFeatureToggleNotifier mockFeatureToggleNotifier;
  late FeatureAccess featureAccess;

  setUp(() {
    // Configurar os mocks
    mockAuthNotifier = MockAuthNotifier();
    mockFeatureToggleNotifier = MockFeatureToggleNotifier();
    
    // Configurar comportamentos padrão
    when(() => mockAuthNotifier.hasAccess(any())).thenReturn(true);
    when(() => mockFeatureToggleNotifier.isFeatureEnabled(any())).thenReturn(true);
    
    // Criar o FeatureAccess com os mocks
    featureAccess = FeatureAccess(
      authNotifier: mockAuthNotifier,
      featureToggleNotifier: mockFeatureToggleNotifier,
    );
  });

  group('FeatureAccess Tests', () {
    test('canAccessFeature deve retornar true quando feature está habilitada e usuário tem acesso', () {
      // Configurar os mocks
      when(() => mockFeatureToggleNotifier.isFeatureEnabled(Feature.createGame))
          .thenReturn(true);
      when(() => mockAuthNotifier.hasAccess(SubscriptionFeature.createGame))
          .thenReturn(true);
      
      // Verificar acesso
      final result = featureAccess.canAccessFeature(
        feature: Feature.createGame,
        subscriptionFeature: SubscriptionFeature.createGame,
      );
      
      // Verificar resultado
      expect(result, true);
    });

    test('canAccessFeature deve retornar false quando feature está desabilitada', () {
      // Configurar os mocks
      when(() => mockFeatureToggleNotifier.isFeatureEnabled(Feature.createGame))
          .thenReturn(false);
      when(() => mockAuthNotifier.hasAccess(SubscriptionFeature.createGame))
          .thenReturn(true);
      
      // Verificar acesso
      final result = featureAccess.canAccessFeature(
        feature: Feature.createGame,
        subscriptionFeature: SubscriptionFeature.createGame,
      );
      
      // Verificar resultado
      expect(result, false);
    });

    test('canAccessFeature deve retornar false quando usuário não tem acesso', () {
      // Configurar os mocks
      when(() => mockFeatureToggleNotifier.isFeatureEnabled(Feature.statistics))
          .thenReturn(true);
      when(() => mockAuthNotifier.hasAccess(SubscriptionFeature.statistics))
          .thenReturn(false);
      
      // Verificar acesso
      final result = featureAccess.canAccessFeature(
        feature: Feature.statistics,
        subscriptionFeature: SubscriptionFeature.statistics,
      );
      
      // Verificar resultado
      expect(result, false);
    });

    test('canAccessFeature deve retornar false quando feature está desabilitada e usuário não tem acesso', () {
      // Configurar os mocks
      when(() => mockFeatureToggleNotifier.isFeatureEnabled(Feature.statistics))
          .thenReturn(false);
      when(() => mockAuthNotifier.hasAccess(SubscriptionFeature.statistics))
          .thenReturn(false);
      
      // Verificar acesso
      final result = featureAccess.canAccessFeature(
        feature: Feature.statistics,
        subscriptionFeature: SubscriptionFeature.statistics,
      );
      
      // Verificar resultado
      expect(result, false);
    });

    test('conditionalFeature deve retornar o widget quando tem acesso', () {
      // Configurar os mocks
      when(() => mockFeatureToggleNotifier.isFeatureEnabled(Feature.createGame))
          .thenReturn(true);
      when(() => mockAuthNotifier.hasAccess(SubscriptionFeature.createGame))
          .thenReturn(true);
      
      // Criar widgets para teste
      final accessWidget = Container();
      final noAccessWidget = Container();
      
      // Chamar o método conditionalFeature
      final result = featureAccess.conditionalFeature(
        feature: Feature.createGame,
        subscriptionFeature: SubscriptionFeature.createGame,
        accessWidget: accessWidget,
        noAccessWidget: noAccessWidget,
      );
      
      // Verificar resultado
      expect(result, accessWidget);
    });

    test('conditionalFeature deve retornar o widget alternativo quando não tem acesso', () {
      // Configurar os mocks
      when(() => mockFeatureToggleNotifier.isFeatureEnabled(Feature.statistics))
          .thenReturn(false);
      when(() => mockAuthNotifier.hasAccess(SubscriptionFeature.statistics))
          .thenReturn(true);
      
      // Criar widgets para teste
      final accessWidget = Container();
      final noAccessWidget = Container();
      
      // Chamar o método conditionalFeature
      final result = featureAccess.conditionalFeature(
        feature: Feature.statistics,
        subscriptionFeature: SubscriptionFeature.statistics,
        accessWidget: accessWidget,
        noAccessWidget: noAccessWidget,
      );
      
      // Verificar resultado
      expect(result, noAccessWidget);
    });
  });
}
