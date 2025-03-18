import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/supabase_service.dart';

/// Enum para representar as features que podem ser ativadas/desativadas
enum Feature {
  createGame,        // Criar um jogo
  joinGame,          // Entrar em um jogo
  unlimitedPlayers,  // Jogadores ilimitados
  statistics,        // Estatísticas avançadas
  exportData,        // Exportar dados
  darkMode,          // Modo escuro
  notifications,     // Notificações
  chatInGame,        // Chat durante o jogo
  tournaments,       // Torneios
  leaderboards,      // Rankings
  deepLinks,         // Deep Links
}

/// Estado para o provider de feature toggles
class FeatureToggleState {
  final Map<Feature, bool> features;
  final Map<Feature, String> subscriptionLevels;
  final bool isLoading;
  final String? errorMessage;
  
  const FeatureToggleState({
    this.features = const {},
    this.subscriptionLevels = const {},
    this.isLoading = false,
    this.errorMessage,
  });
  
  FeatureToggleState copyWith({
    Map<Feature, bool>? features,
    Map<Feature, String>? subscriptionLevels,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeatureToggleState(
      features: features ?? this.features,
      subscriptionLevels: subscriptionLevels ?? this.subscriptionLevels,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
  
  /// Verifica se uma feature está ativada
  bool isEnabled(Feature feature) {
    return features[feature] ?? false;
  }
  
  /// Obtém o nível de assinatura necessário para uma feature
  String getRequiredSubscription(Feature feature) {
    return subscriptionLevels[feature] ?? 'free';
  }
}

/// Notifier para gerenciar o estado dos feature toggles
class FeatureToggleNotifier extends StateNotifier<FeatureToggleState> {
  final SupabaseService _supabaseService;
  
  FeatureToggleNotifier(this._supabaseService) : super(const FeatureToggleState()) {
    // Carregar os feature toggles ao inicializar
    loadFeatureToggles();
  }
  
  /// Carregar os feature toggles do Supabase
  Future<void> loadFeatureToggles() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Buscar os feature toggles usando o SupabaseService
      final response = await _supabaseService.getFeatureToggles();
      
      // Converter a resposta para um Map<Feature, bool> e Map<Feature, String>
      final Map<Feature, bool> features = {};
      final Map<Feature, String> subscriptionLevels = {};
      
      for (final toggle in response) {
        final featureName = toggle['feature'] as String;
        final isEnabled = toggle['enabled'] as bool;
        final subscriptionLevel = toggle['subscription_level'] as String;
        
        // Converter a string para o enum Feature
        try {
          final feature = Feature.values.firstWhere(
            (f) => f.toString().split('.').last == featureName
          );
          features[feature] = isEnabled;
          subscriptionLevels[feature] = subscriptionLevel;
        } catch (e) {
          // Ignorar features que não existem no enum
          print('Feature não encontrada: $featureName');
        }
      }
      
      // Atualizar o estado com os feature toggles carregados
      state = state.copyWith(
        features: features,
        subscriptionLevels: subscriptionLevels,
        isLoading: false
      );
    } catch (e) {
      // Em caso de erro, definir valores padrão para as features críticas
      final defaultFeatures = <Feature, bool>{
        Feature.createGame: true,
        Feature.joinGame: true,
        Feature.darkMode: true,
      };
      
      final defaultSubscriptionLevels = <Feature, String>{
        Feature.createGame: 'free',
        Feature.joinGame: 'free',
        Feature.darkMode: 'free',
        Feature.unlimitedPlayers: 'premium',
        Feature.statistics: 'premium',
        Feature.exportData: 'pro',
        Feature.notifications: 'premium',
        Feature.chatInGame: 'premium',
        Feature.tournaments: 'pro',
        Feature.leaderboards: 'premium',
        Feature.deepLinks: 'free',
      };
      
      state = state.copyWith(
        features: defaultFeatures,
        subscriptionLevels: defaultSubscriptionLevels,
        isLoading: false,
        errorMessage: 'Erro ao carregar feature toggles: ${e.toString()}',
      );
    }
  }
  
  /// Verificar se uma feature está ativada
  bool isFeatureEnabled(Feature feature) {
    return state.isEnabled(feature);
  }
  
  /// Obter o nível de assinatura necessário para uma feature
  String getRequiredSubscription(Feature feature) {
    return state.getRequiredSubscription(feature);
  }
  
  /// Atualizar uma feature toggle no Supabase
  Future<void> updateFeatureToggle(Feature feature, bool enabled, String subscriptionLevel) async {
    try {
      final featureName = feature.toString().split('.').last;
      
      await _supabaseService.updateFeatureToggle(
        feature: featureName,
        enabled: enabled,
        subscriptionLevel: subscriptionLevel,
      );
      
      // Atualizar o estado local
      final updatedFeatures = Map<Feature, bool>.from(state.features);
      updatedFeatures[feature] = enabled;
      
      final updatedSubscriptionLevels = Map<Feature, String>.from(state.subscriptionLevels);
      updatedSubscriptionLevels[feature] = subscriptionLevel;
      
      state = state.copyWith(
        features: updatedFeatures,
        subscriptionLevels: updatedSubscriptionLevels,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar feature toggle: ${e.toString()}',
      );
    }
  }
}

/// Provider para o serviço Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provider para acessar o estado dos feature toggles
final featureToggleProvider = StateNotifierProvider<FeatureToggleNotifier, FeatureToggleState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return FeatureToggleNotifier(supabaseService);
});
