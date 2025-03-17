import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/feature_toggle_provider.dart';

/// Utilitário para verificar acesso a funcionalidades baseado em assinaturas e feature toggles
class FeatureAccess {
  /// Verifica se uma feature está habilitada e se o usuário tem acesso a ela
  /// Retorna true se a feature está habilitada e o usuário tem acesso
  static bool canAccess(WidgetRef ref, Feature feature) {
    // Verificar se a feature está ativada
    final featureToggleNotifier = ref.read(featureToggleProvider.notifier);
    final isFeatureEnabled = featureToggleNotifier.isFeatureEnabled(feature);
    
    if (!isFeatureEnabled) {
      return false;
    }
    
    // Mapear Feature para SubscriptionFeature correspondente
    SubscriptionFeature? subscriptionFeature;
    
    switch (feature) {
      case Feature.createGame:
        subscriptionFeature = SubscriptionFeature.createGame;
        break;
      case Feature.unlimitedPlayers:
        subscriptionFeature = SubscriptionFeature.unlimitedPlayers;
        break;
      case Feature.statistics:
        subscriptionFeature = SubscriptionFeature.statistics;
        break;
      // Features que não têm uma SubscriptionFeature correspondente
      // são consideradas acessíveis para todos os usuários autenticados
      default:
        final authState = ref.read(authProvider);
        return !authState.isAnonymous;
    }
    
    // Verificar se o usuário tem acesso à SubscriptionFeature
    if (subscriptionFeature != null) {
      final authNotifier = ref.read(authProvider.notifier);
      return authNotifier.hasAccess(subscriptionFeature);
    }
    
    return true;
  }
  
  /// Verifica se uma feature está habilitada e se o usuário tem acesso a ela
  /// Se não tiver acesso, exibe um diálogo explicando o motivo
  /// Retorna true se a feature está habilitada e o usuário tem acesso
  static Future<bool> checkAccessWithDialog(
    BuildContext context,
    WidgetRef ref,
    Feature feature
  ) async {
    // Verificar se a feature está ativada
    final featureToggleNotifier = ref.read(featureToggleProvider.notifier);
    final isFeatureEnabled = featureToggleNotifier.isFeatureEnabled(feature);
    
    if (!isFeatureEnabled) {
      await _showFeatureDisabledDialog(context, feature);
      return false;
    }
    
    // Mapear Feature para SubscriptionFeature correspondente
    SubscriptionFeature? subscriptionFeature;
    
    switch (feature) {
      case Feature.createGame:
        subscriptionFeature = SubscriptionFeature.createGame;
        break;
      case Feature.unlimitedPlayers:
        subscriptionFeature = SubscriptionFeature.unlimitedPlayers;
        break;
      case Feature.statistics:
        subscriptionFeature = SubscriptionFeature.statistics;
        break;
      default:
        final authState = ref.read(authProvider);
        if (authState.isAnonymous) {
          await _showLoginRequiredDialog(context);
          return false;
        }
        return true;
    }
    
    // Verificar se o usuário tem acesso à SubscriptionFeature
    if (subscriptionFeature != null) {
      final authNotifier = ref.read(authProvider.notifier);
      final hasAccess = authNotifier.hasAccess(subscriptionFeature);
      
      if (!hasAccess) {
        await _showSubscriptionRequiredDialog(context, subscriptionFeature);
        return false;
      }
    }
    
    return true;
  }
  
  /// Exibe um diálogo informando que a feature está desabilitada
  static Future<void> _showFeatureDisabledDialog(
    BuildContext context,
    Feature feature
  ) async {
    String featureName = _getFeatureName(feature);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Funcionalidade indisponível'),
        content: Text(
          'A funcionalidade "$featureName" está temporariamente indisponível. '
          'Por favor, tente novamente mais tarde.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
        backgroundColor: const Color(0xFF222222),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF1F0FB),
          fontSize: 16,
        ),
      ),
    );
  }
  
  /// Exibe um diálogo informando que o login é necessário
  static Future<void> _showLoginRequiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login necessário'),
        content: Text(
          'Você precisa fazer login para acessar esta funcionalidade.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar para a tela de login (a ser implementada)
              // Navigator.of(context).pushNamed('/login');
            },
            child: Text('Fazer login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6), // Primary purple
            ),
          ),
        ],
        backgroundColor: const Color(0xFF222222),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF1F0FB),
          fontSize: 16,
        ),
      ),
    );
  }
  
  /// Exibe um diálogo informando que uma assinatura é necessária
  static Future<void> _showSubscriptionRequiredDialog(
    BuildContext context,
    SubscriptionFeature feature
  ) async {
    String featureName;
    String planRequired;
    
    switch (feature) {
      case SubscriptionFeature.createGame:
        featureName = 'criar jogos';
        planRequired = 'se autenticar';
        break;
      case SubscriptionFeature.unlimitedPlayers:
        featureName = 'adicionar jogadores ilimitados';
        planRequired = 'Premium ou Pro';
        break;
      case SubscriptionFeature.statistics:
        featureName = 'acessar estatísticas avançadas';
        planRequired = 'Pro';
        break;
      default:
        featureName = 'acessar esta funcionalidade';
        planRequired = 'fazer upgrade';
    }
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assinatura necessária'),
        content: Text(
          'Para $featureName, você precisa $planRequired. '
          'Faça upgrade do seu plano para desbloquear esta funcionalidade.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar para a tela de assinaturas (a ser implementada)
              // Navigator.of(context).pushNamed('/subscriptions');
            },
            child: Text('Ver planos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6), // Primary purple
            ),
          ),
        ],
        backgroundColor: const Color(0xFF222222),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF1F0FB),
          fontSize: 16,
        ),
      ),
    );
  }
  
  /// Retorna o nome amigável de uma feature
  static String _getFeatureName(Feature feature) {
    switch (feature) {
      case Feature.createGame:
        return 'Criar jogo';
      case Feature.joinGame:
        return 'Entrar em jogo';
      case Feature.unlimitedPlayers:
        return 'Jogadores ilimitados';
      case Feature.statistics:
        return 'Estatísticas avançadas';
      case Feature.exportData:
        return 'Exportar dados';
      case Feature.darkMode:
        return 'Modo escuro';
      case Feature.notifications:
        return 'Notificações';
      case Feature.chatInGame:
        return 'Chat durante o jogo';
      case Feature.tournaments:
        return 'Torneios';
      case Feature.leaderboards:
        return 'Rankings';
      default:
        return 'Desconhecida';
    }
  }
  
  /// Widget condicional que exibe seu filho apenas se a feature estiver disponível
  static Widget conditionalFeature({
    required BuildContext context,
    required WidgetRef ref,
    required Feature feature,
    required Widget child,
    Widget? fallback,
  }) {
    final hasAccess = canAccess(ref, feature);
    
    if (hasAccess) {
      return child;
    } else {
      return fallback ?? SizedBox.shrink();
    }
  }
}
