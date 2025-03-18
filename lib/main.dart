import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/core/router/app_router.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/core/theme/app_theme.dart';
import 'package:poker_night/core/utils/timeago_localization.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/deep_link_provider.dart';
import 'package:poker_night/providers/locale_provider.dart';
import 'package:poker_night/providers/notification_provider.dart';
import 'package:poker_night/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    debugPrint('Iniciando aplicativo Poker Night...');
    await SupabaseService.initialize();
    
    // Initialize timeago localization
    initTimeagoLocalization();
    
    debugPrint('Inicialização concluída com sucesso!');
  } catch (e) {
    debugPrint('Erro durante a inicialização do aplicativo: $e');
    // Continuamos mesmo com erro para permitir o desenvolvimento local
  }
  
  runApp(
    const ProviderScope(
      child: PokerNightApp(),
    ),
  );
}

class PokerNightApp extends ConsumerWidget {
  const PokerNightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final router = ref.watch(appRouterProvider);
      final locale = ref.watch(localeProvider);
      final theme = ref.watch(themeProvider);
      
      // Inicializar o serviço de notificação
      // Isso carregará as notificações do usuário quando estiver autenticado
      try {
        ref.watch(notificationProvider);
      } catch (e) {
        debugPrint('Erro ao inicializar o serviço de notificação: $e');
      }
      
      // Inicializar o serviço de deep link
      // Isso configurará os handlers para processar deep links
      try {
        ref.watch(deepLinkProvider);
      } catch (e) {
        debugPrint('Erro ao inicializar o serviço de deep link: $e');
      }
      
      return MaterialApp.router(
        title: 'Poker Night',
        theme: theme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        
        // Configuração de localização
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt'), // Português
          Locale('en'), // Inglês
        ],
      );
    } catch (e) {
      debugPrint('Erro ao renderizar o aplicativo: $e');
      return MaterialApp.router(
        title: 'Poker Night',
        routerConfig: ref.watch(appRouterProvider),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}
