import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

/// Widget que verifica se o usuário tem acesso a uma feature
/// e exibe o conteúdo apenas se tiver acesso
class FeatureAccess extends ConsumerWidget {
  final Feature feature;
  final Widget child;
  final Widget? fallbackWidget;

  const FeatureAccess({
    super.key,
    required this.feature,
    required this.child,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    final featureToggleState = ref.watch(featureToggleProvider);
    final isEnabled = featureToggleState.isEnabled(feature);
    
    if (!isEnabled) {
      // Mostrar feedback ou widget alternativo
      showDisabledFeatureDialog(context, safeL10n, feature);
      return fallbackWidget ?? const SizedBox.shrink();
    }
    
    final requiredSubscription = featureToggleState.getRequiredSubscription(feature);
    if (requiredSubscription == null) {
      return child;
    }
    
    final authState = ref.watch(authProvider);
    final hasAccess = ref.read(authProvider.notifier).hasAccess(
      SubscriptionFeature.values.firstWhere(
        (f) => f.toString() == requiredSubscription,
        orElse: () => SubscriptionFeature.createGame,
      )
    );
    
    if (hasAccess) {
      return child;
    }
    
    // Mostrar diálogo de upgrade
    showSubscriptionRequiredDialog(context, safeL10n, feature, requiredSubscription);
    return fallbackWidget ?? const SizedBox.shrink();
  }
  
  /// Mostra um diálogo quando a feature está desativada
  void showDisabledFeatureDialog(BuildContext context, SafeL10n safeL10n, Feature feature) {
    final featureName = feature.toString().split('.').last;
    
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(safeL10n.featureDisabled),
          content: Text(safeL10n.get(
            'featureDisabledDescription', 
            'This feature is currently disabled. Please check back later.',
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(safeL10n.ok),
            ),
          ],
        ),
      );
    });
  }
  
  /// Mostra um diálogo quando é necessário fazer upgrade da assinatura
  void showSubscriptionRequiredDialog(
    BuildContext context, 
    SafeL10n safeL10n, 
    Feature feature, 
    String requiredLevel
  ) {
    final featureName = feature.toString().split('.').last;
    
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(safeL10n.subscriptionRequired),
          content: Text(safeL10n.get(
            'subscriptionRequiredDescription', 
            'This feature requires a $requiredLevel subscription. Upgrade your plan to access it.',
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(safeL10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navegar para a tela de assinatura
                Navigator.of(context).pushNamed('/subscription');
              },
              child: Text(safeL10n.upgrade),
            ),
          ],
        ),
      );
    });
  }
}

/// Função utilitária para verificar se uma feature está disponível
/// e exibir um widget apenas se estiver
Widget conditionalFeature({
  required BuildContext context,
  required WidgetRef ref,
  required Feature feature,
  required Widget child,
  Widget? fallbackWidget,
}) {
  return FeatureAccess(
    feature: feature,
    child: child,
    fallbackWidget: fallbackWidget,
  );
}
