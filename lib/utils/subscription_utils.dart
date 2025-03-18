import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Utilitário para verificar permissões de assinatura e exibir diálogos de upgrade
class SubscriptionUtils {
  /// Verifica se o usuário tem acesso a uma funcionalidade específica
  /// Retorna true se tem acesso, false caso contrário
  static bool checkAccess(WidgetRef ref, SubscriptionFeature feature) {
    final authNotifier = ref.read(authProvider.notifier);
    return authNotifier.hasAccess(feature);
  }
  
  /// Verifica se o usuário tem acesso a uma funcionalidade e, se não tiver,
  /// exibe um diálogo de upgrade
  /// Retorna true se tem acesso, false caso contrário
  static Future<bool> checkAccessWithDialog(
    BuildContext context, 
    WidgetRef ref, 
    SubscriptionFeature feature
  ) async {
    final hasAccess = checkAccess(ref, feature);
    
    if (!hasAccess) {
      await _showUpgradeDialog(context, feature);
    }
    
    return hasAccess;
  }
  
  /// Exibe um diálogo informando que o usuário precisa fazer upgrade
  /// para acessar uma funcionalidade
  static Future<void> _showUpgradeDialog(
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
        title: Text('Upgrade necessário'),
        content: Text(
          'Para $featureName, você precisa $planRequired. '
          'Faça upgrade do seu plano para desbloquear esta funcionalidade.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar para a tela de assinaturas (a ser implementada)
              // Navigator.of(context).pushNamed('/subscriptions');
            },
            child: Text('Ver planos'),
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
  
  /// Retorna o nome do plano de assinatura atual do usuário
  static String getSubscriptionName(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return 'Gratuito';
      case SubscriptionStatus.premium:
        return 'Premium';
      case SubscriptionStatus.pro:
        return 'Pro';
      default:
        return 'Desconhecido';
    }
  }
  
  /// Retorna a cor associada ao plano de assinatura
  static Color getSubscriptionColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return const Color(0xFF0EA5E9); // Secondary blue
      case SubscriptionStatus.premium:
        return const Color(0xFF8B5CF6); // Primary purple
      case SubscriptionStatus.pro:
        return const Color(0xFFD946EF); // Accent pink
      default:
        return Colors.grey;
    }
  }
  
  /// Retorna os limites associados ao plano de assinatura
  static Map<String, dynamic> getSubscriptionLimits(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return {
          'maxPlayers': 8,
          'maxGames': 5,
          'statistics': false,
          'export': false,
        };
      case SubscriptionStatus.premium:
        return {
          'maxPlayers': 20,
          'maxGames': 50,
          'statistics': false,
          'export': true,
        };
      case SubscriptionStatus.pro:
        return {
          'maxPlayers': double.infinity,
          'maxGames': double.infinity,
          'statistics': true,
          'export': true,
        };
      default:
        return {
          'maxPlayers': 8,
          'maxGames': 5,
          'statistics': false,
          'export': false,
        };
    }
  }
}
