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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Initialize timeago localization
  initTimeagoLocalization();
  
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
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    
    // Inicializar o serviço de notificação
    // Isso carregará as notificações do usuário quando estiver autenticado
    ref.watch(notificationProvider);
    
    // Inicializar o serviço de deep link
    // Isso configurará os handlers para processar deep links
    ref.watch(deepLinkProvider);
    
    return MaterialApp.router(
      title: 'Poker Night',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme
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
  }
}
