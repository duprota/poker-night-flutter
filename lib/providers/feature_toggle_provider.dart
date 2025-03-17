import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}

/// Estado para o provider de feature toggles
class FeatureToggleState {
  final Map<Feature, bool> features;
  final bool isLoading;
  final String? errorMessage;
  
  const FeatureToggleState({
    this.features = const {},
    this.isLoading = false,
    this.errorMessage,
  });
  
  FeatureToggleState copyWith({
    Map<Feature, bool>? features,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeatureToggleState(
      features: features ?? this.features,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
  
  /// Verifica se uma feature está ativada
  bool isEnabled(Feature feature) {
    return features[feature] ?? false;
  }
}

/// Notifier para gerenciar o estado dos feature toggles
class FeatureToggleNotifier extends StateNotifier<FeatureToggleState> {
  FeatureToggleNotifier() : super(const FeatureToggleState()) {
    // Carregar os feature toggles ao inicializar
    loadFeatureToggles();
  }
  
  // Obter o cliente Supabase
  final supabase = Supabase.instance.client;
  
  /// Carregar os feature toggles do Supabase
  Future<void> loadFeatureToggles() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Buscar os feature toggles da tabela feature_toggles
      final response = await supabase
          .from('feature_toggles')
          .select()
          .order('feature');
      
      // Converter a resposta para um Map<Feature, bool>
      final Map<Feature, bool> features = {};
      for (final toggle in response) {
        final featureName = toggle['feature'] as String;
        final isEnabled = toggle['enabled'] as bool;
        
        // Converter a string para o enum Feature
        try {
          final feature = Feature.values.firstWhere(
            (f) => f.toString().split('.').last == featureName
          );
          features[feature] = isEnabled;
        } catch (e) {
          // Ignorar features que não existem no enum
          print('Feature não encontrada: $featureName');
        }
      }
      
      // Atualizar o estado com os feature toggles carregados
      state = state.copyWith(features: features, isLoading: false);
    } catch (e) {
      // Em caso de erro, definir valores padrão para as features críticas
      final defaultFeatures = <Feature, bool>{
        Feature.createGame: true,
        Feature.joinGame: true,
        Feature.darkMode: true,
      };
      
      state = state.copyWith(
        features: defaultFeatures,
        isLoading: false,
        errorMessage: 'Erro ao carregar feature toggles: ${e.toString()}',
      );
    }
  }
  
  /// Verificar se uma feature está ativada
  bool isFeatureEnabled(Feature feature) {
    return state.isEnabled(feature);
  }
  
  /// Sobrescrever localmente o estado de uma feature (apenas para testes)
  void overrideFeature(Feature feature, bool enabled) {
    final updatedFeatures = Map<Feature, bool>.from(state.features);
    updatedFeatures[feature] = enabled;
    
    state = state.copyWith(features: updatedFeatures);
  }
}

/// Provider para acessar o estado dos feature toggles
final featureToggleProvider = StateNotifierProvider<FeatureToggleNotifier, FeatureToggleState>((ref) {
  return FeatureToggleNotifier();
});
