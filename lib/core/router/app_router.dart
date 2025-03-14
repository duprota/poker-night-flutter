import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/features/auth/presentation/screens/login_screen.dart';
import 'package:poker_night/features/auth/presentation/screens/register_screen.dart';
import 'package:poker_night/features/auth/presentation/screens/splash_screen.dart';
import 'package:poker_night/features/games/presentation/screens/game_details_screen.dart';
import 'package:poker_night/features/games/presentation/screens/games_list_screen.dart';
import 'package:poker_night/features/games/presentation/screens/new_game_screen.dart';
import 'package:poker_night/features/players/presentation/screens/player_details_screen.dart';
import 'package:poker_night/features/players/presentation/screens/players_list_screen.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = SupabaseService.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToSplash = state.matchedLocation == '/';

      // If not logged in and not going to auth pages, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
        return '/login';
      }

      // If logged in and going to auth pages, redirect to games list
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return '/games';
      }

      return null;
    },
    routes: [
      // Splash and Auth routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Games routes
      GoRoute(
        path: '/games',
        builder: (context, state) => const GamesListScreen(),
      ),
      GoRoute(
        path: '/games/new',
        builder: (context, state) => const NewGameScreen(),
      ),
      GoRoute(
        path: '/games/:id',
        builder: (context, state) {
          final gameId = state.pathParameters['id']!;
          return GameDetailsScreen(gameId: gameId);
        },
      ),
      
      // Players routes
      GoRoute(
        path: '/players',
        builder: (context, state) => const PlayersListScreen(),
      ),
      GoRoute(
        path: '/players/:id',
        builder: (context, state) {
          final playerId = state.pathParameters['id']!;
          return PlayerDetailsScreen(playerId: playerId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});
