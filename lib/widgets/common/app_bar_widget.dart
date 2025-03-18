import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget de barra de aplicativo personalizada para o aplicativo Poker Night
class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  /// Título da barra de aplicativo
  final String title;
  
  /// Ações adicionais para a barra de aplicativo (opcional)
  final List<Widget>? actions;
  
  /// Se deve mostrar o botão de voltar (opcional)
  final bool showBackButton;
  
  /// Callback para o botão de voltar (opcional)
  final VoidCallback? onBackPressed;
  
  /// Construtor
  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final safeL10n = localizations != null ? SafeL10n(localizations) : null;
    
    return AppBar(
      title: Text(
        safeL10n?.get(title, title) ?? title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : null,
      actions: actions,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
