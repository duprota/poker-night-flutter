import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poker_night/core/router/app_router.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: PokerNightApp(),
    ),
  );
}

// Provider para gerenciar o idioma selecionado
final localeProvider = StateProvider<Locale>((ref) {
  // Português como idioma padrão
  return const Locale('pt', 'BR');
});

class PokerNightApp extends ConsumerWidget {
  const PokerNightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'Poker Night',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português (Brasil)
        Locale('en', 'US'), // Inglês (EUA)
      ],
    );
  }
}
