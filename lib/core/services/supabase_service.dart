import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:poker_night/core/constants/supabase_constants.dart';
import 'package:poker_night/models/game.dart';
import 'package:poker_night/models/player.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';

/// Service class to handle Supabase operations
class SupabaseService {
  /// Supabase client instance for testing
  static SupabaseClient? _testClient;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => _testClient ?? Supabase.instance.client;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  /// Get current user (método de instância para compatibilidade com testes)
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Override client for testing
  static void overrideClientForTesting(SupabaseClient mockClient) {
    _testClient = mockClient;
  }
  
  /// Reset client after testing
  static void resetClient() {
    _testClient = null;
  }

  // =========================================================================
  // Authentication Methods
  // =========================================================================

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    return response;
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // =========================================================================
  // Subscription Methods
  // =========================================================================

  /// Get user subscription status
  Future<SubscriptionStatus> getUserSubscriptionStatus(String userId) async {
    try {
      final response = await client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .single();

      final status = response['status'] as String;

      switch (status.toLowerCase()) {
        case 'premium':
          return SubscriptionStatus.premium;
        case 'pro':
          return SubscriptionStatus.pro;
        default:
          return SubscriptionStatus.free;
      }
    } catch (e) {
      // Se ocorrer um erro ou o usuário não tiver um registro de assinatura,
      // retornar o status free
      return SubscriptionStatus.free;
    }
  }

  /// Update user subscription
  Future<void> updateUserSubscription({
    required String userId,
    required SubscriptionStatus status,
  }) async {
    final statusString = status.toString().split('.').last;

    try {
      // Check if subscription exists
      final exists = await client
          .from('user_subscriptions')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (exists != null) {
        // Update existing subscription
        await client
            .from('user_subscriptions')
            .update({
              'status': statusString,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      } else {
        // Create new subscription
        await client.from('user_subscriptions').insert({
          'user_id': userId,
          'status': statusString,
          'start_date': DateTime.now().toIso8601String(),
          'end_date': null, // Free plan has no end date
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // Game Methods
  // =========================================================================

  /// Get all games for a user
  Future<List<Game>> getGames(String userId) async {
    try {
      final response = await client
          .from('games')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      final data = response as List;
      return data.map((game) => Game.fromJson(game)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a game by ID
  Future<Game> getGameById(String gameId) async {
    try {
      final response = await client
          .from('games')
          .select()
          .eq('id', gameId)
          .single();

      return Game.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new game
  Future<Game> createGame(Game game) async {
    try {
      final response = await client
          .from('games')
          .insert(game.toJson())
          .select()
          .single();

      return Game.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a game
  Future<Game> updateGame(Game game) async {
    try {
      final response = await client
          .from('games')
          .update(game.toJson())
          .eq('id', game.id)
          .select()
          .single();

      return Game.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a game
  Future<void> deleteGame(String gameId) async {
    try {
      await client
          .from('games')
          .delete()
          .eq('id', gameId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get games count for a user
  Future<int> getGamesCount(String userId) async {
    try {
      final response = await client
          .from('games')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // =========================================================================
  // Player Methods
  // =========================================================================

  /// Get all players for a user
  Future<List<Player>> getPlayers(String userId) async {
    try {
      final response = await client
          .from('players')
          .select()
          .eq('user_id', userId)
          .order('name', ascending: true);

      final data = response as List;
      return data.map((player) => Player.fromJson(player)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a player by ID
  Future<Player> getPlayerById(String playerId) async {
    try {
      final response = await client
          .from('players')
          .select()
          .eq('id', playerId)
          .single();

      return Player.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new player
  Future<Player> createPlayer(Player player) async {
    try {
      final response = await client
          .from('players')
          .insert(player.toJson())
          .select()
          .single();

      return Player.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a player
  Future<Player> updatePlayer(Player player) async {
    try {
      final response = await client
          .from('players')
          .update(player.toJson())
          .eq('id', player.id)
          .select()
          .single();

      return Player.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a player
  Future<void> deletePlayer(String playerId) async {
    try {
      await client
          .from('players')
          .delete()
          .eq('id', playerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get players count for a user
  Future<int> getPlayersCount(String userId) async {
    try {
      final response = await client
          .from('players')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // =========================================================================
  // Feature Toggle Methods
  // =========================================================================

  /// Get all feature toggles
  Future<List<Map<String, dynamic>>> getFeatureToggles() async {
    try {
      final response = await client
          .from('feature_toggles')
          .select()
          .order('feature', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  /// Update a feature toggle
  Future<void> updateFeatureToggle({
    required String feature,
    required bool enabled,
    required String subscriptionLevel,
  }) async {
    try {
      // Check if feature exists
      final exists = await client
          .from('feature_toggles')
          .select('id')
          .eq('feature', feature)
          .maybeSingle();

      if (exists != null) {
        // Update existing feature
        await client
            .from('feature_toggles')
            .update({
              'enabled': enabled,
              'subscription_level': subscriptionLevel,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('feature', feature);
      } else {
        // Create new feature
        await client.from('feature_toggles').insert({
          'feature': feature,
          'enabled': enabled,
          'subscription_level': subscriptionLevel,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // Game-Player Relationship Methods
  // =========================================================================

  /// Add a player to a game
  Future<void> addPlayerToGame({
    required String gameId,
    required String playerId,
    required double buyIn,
    required double cashOut,
  }) async {
    try {
      await client.from('game_players').insert({
        'game_id': gameId,
        'player_id': playerId,
        'buy_in': buyIn,
        'cash_out': cashOut,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Update a player in a game
  Future<void> updatePlayerInGame({
    required String gameId,
    required String playerId,
    required double buyIn,
    required double cashOut,
  }) async {
    try {
      await client
          .from('game_players')
          .update({
            'buy_in': buyIn,
            'cash_out': cashOut,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('game_id', gameId)
          .eq('player_id', playerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a player from a game
  Future<void> removePlayerFromGame({
    required String gameId,
    required String playerId,
  }) async {
    try {
      await client
          .from('game_players')
          .delete()
          .eq('game_id', gameId)
          .eq('player_id', playerId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all players in a game
  Future<List<Map<String, dynamic>>> getPlayersInGame(String gameId) async {
    try {
      final response = await client
          .from('game_players')
          .select('*, players(*)')
          .eq('game_id', gameId);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  /// Get player statistics
  Future<Map<String, dynamic>> getPlayerStatistics(String playerId) async {
    try {
      // Get games played count
      final gamesPlayedResponse = await client
          .from('game_players')
          .select('id')
          .eq('player_id', playerId);
      
      final gamesPlayed = (gamesPlayedResponse as List).length;

      // Get total profit/loss
      final profitLossResponse = await client
          .rpc('calculate_player_profit_loss', params: {'player_id_param': playerId})
          .single();

      // Get win rate
      final winRateResponse = await client
          .rpc('calculate_player_win_rate', params: {'player_id_param': playerId})
          .single();

      return {
        'games_played': gamesPlayed,
        'profit_loss': profitLossResponse['profit_loss'] ?? 0.0,
        'win_rate': winRateResponse['win_rate'] ?? 0.0,
      };
    } catch (e) {
      return {
        'games_played': 0,
        'profit_loss': 0.0,
        'win_rate': 0.0,
      };
    }
  }
}
