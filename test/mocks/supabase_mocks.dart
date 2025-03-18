import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/models/game.dart';
import 'package:poker_night/models/player.dart';
import 'package:poker_night/providers/auth_provider.dart';

/// Configurar valores de fallback para enums e outros tipos
void setUpMockSupabase() {
  registerFallbackValue(SubscriptionStatus.free);
}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGotrueClient extends Mock implements GoTrueClient {}

class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}

class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

class MockSupabaseService extends Mock implements SupabaseService {
  final Map<String, User> _users = {};
  final Map<String, SubscriptionStatus> _subscriptions = {};
  final Map<String, List<Game>> _games = {};
  final Map<String, List<Player>> _players = {};
  User? _currentUser;

  MockSupabaseService() {
    // Configurar comportamento padrão para métodos comuns
    registerFallbackValue(Game(
      id: 'default-game-id',
      userId: 'default-user-id',
      name: 'Default Game',
      location: 'Default Location',
      date: DateTime.now(),
      buyIn: 50.0,
    ));

    registerFallbackValue(Player(
      id: 'default-player-id',
      userId: 'default-user-id',
      name: 'Default Player',
      email: 'default@example.com',
      phone: '123456789',
    ));

    // Configurar comportamento padrão para métodos de autenticação
    when(() => getCurrentUser()).thenAnswer((_) => _currentUser);
    
    when(() => signInWithEmail(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((invocation) async {
      final email = invocation.namedArguments[const Symbol('email')] as String;
      final password = invocation.namedArguments[const Symbol('password')] as String;
      
      if (_users.containsKey(email) && password == 'password') {
        _currentUser = _users[email];
        return AuthResponse(
          user: _currentUser,
          session: Session(
            accessToken: 'test-token',
            tokenType: 'bearer',
            refreshToken: 'test-refresh',
            expiresIn: 3600,
            user: _currentUser!,
          ),
        );
      } else {
        throw AuthException('Invalid credentials');
      }
    });
    
    when(() => signUpWithEmail(
      email: any(named: 'email'),
      password: any(named: 'password'),
      name: any(named: 'name'),
    )).thenAnswer((invocation) async {
      final email = invocation.namedArguments[const Symbol('email')] as String;
      final name = invocation.namedArguments[const Symbol('name')] as String;
      
      if (_users.containsKey(email)) {
        throw AuthException('Email already in use');
      } else {
        final user = User(
          id: 'user-${_users.length + 1}',
          appMetadata: {},
          userMetadata: {'name': name},
          aud: 'authenticated',
          email: email,
          phone: '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        _users[email] = user;
        _currentUser = user;
        _subscriptions[user.id] = SubscriptionStatus.free;
        
        return AuthResponse(
          user: user,
          session: Session(
            accessToken: 'test-token',
            tokenType: 'bearer',
            refreshToken: 'test-refresh',
            expiresIn: 3600,
            user: user,
          ),
        );
      }
    });
    
    when(() => signOut()).thenAnswer((_) async {
      _currentUser = null;
    });
    
    when(() => getUserSubscriptionStatus(any())).thenAnswer((invocation) async {
      final userId = invocation.positionalArguments[0] as String;
      return _subscriptions[userId] ?? SubscriptionStatus.free;
    });
    
    when(() => updateUserSubscription(
      userId: any(named: 'userId'),
      status: any(named: 'status'),
    )).thenAnswer((invocation) async {
      final userId = invocation.namedArguments[const Symbol('userId')] as String;
      final status = invocation.namedArguments[const Symbol('status')] as SubscriptionStatus;
      _subscriptions[userId] = status;
    });
    
    // Configurar comportamento padrão para métodos de jogos
    when(() => getGames(any())).thenAnswer((invocation) async {
      final userId = invocation.positionalArguments[0] as String;
      return _games[userId] ?? [];
    });
    
    when(() => getGameById(any())).thenAnswer((invocation) async {
      final gameId = invocation.positionalArguments[0] as String;
      
      for (final games in _games.values) {
        for (final game in games) {
          if (game.id == gameId) {
            return game;
          }
        }
      }
      
      throw Exception('Game not found');
    });
    
    when(() => createGame(any())).thenAnswer((invocation) async {
      final game = invocation.positionalArguments[0] as Game;
      
      if (!_games.containsKey(game.userId)) {
        _games[game.userId] = [];
      }
      
      _games[game.userId]!.add(game);
      return game;
    });
    
    when(() => updateGame(any())).thenAnswer((invocation) async {
      final updatedGame = invocation.positionalArguments[0] as Game;
      
      if (!_games.containsKey(updatedGame.userId)) {
        throw Exception('User not found');
      }
      
      final games = _games[updatedGame.userId]!;
      final index = games.indexWhere((g) => g.id == updatedGame.id);
      
      if (index == -1) {
        throw Exception('Game not found');
      }
      
      games[index] = updatedGame;
      return updatedGame;
    });
    
    when(() => deleteGame(any())).thenAnswer((invocation) async {
      final gameId = invocation.positionalArguments[0] as String;
      
      for (final userId in _games.keys) {
        final games = _games[userId]!;
        final index = games.indexWhere((g) => g.id == gameId);
        
        if (index != -1) {
          games.removeAt(index);
          return;
        }
      }
      
      throw Exception('Game not found');
    });
    
    when(() => getGamesCount(any())).thenAnswer((invocation) async {
      final userId = invocation.positionalArguments[0] as String;
      return _games[userId]?.length ?? 0;
    });
    
    // Configurar comportamento padrão para métodos de jogadores
    when(() => getPlayers(any())).thenAnswer((invocation) async {
      final userId = invocation.positionalArguments[0] as String;
      return _players[userId] ?? [];
    });
    
    when(() => getPlayerById(any())).thenAnswer((invocation) async {
      final playerId = invocation.positionalArguments[0] as String;
      
      for (final players in _players.values) {
        for (final player in players) {
          if (player.id == playerId) {
            return player;
          }
        }
      }
      
      throw Exception('Player not found');
    });
    
    when(() => createPlayer(any())).thenAnswer((invocation) async {
      final player = invocation.positionalArguments[0] as Player;
      
      if (!_players.containsKey(player.userId)) {
        _players[player.userId] = [];
      }
      
      _players[player.userId]!.add(player);
      return player;
    });
    
    when(() => updatePlayer(any())).thenAnswer((invocation) async {
      final updatedPlayer = invocation.positionalArguments[0] as Player;
      
      if (!_players.containsKey(updatedPlayer.userId)) {
        throw Exception('User not found');
      }
      
      final players = _players[updatedPlayer.userId]!;
      final index = players.indexWhere((p) => p.id == updatedPlayer.id);
      
      if (index == -1) {
        throw Exception('Player not found');
      }
      
      players[index] = updatedPlayer;
      return updatedPlayer;
    });
    
    when(() => deletePlayer(any())).thenAnswer((invocation) async {
      final playerId = invocation.positionalArguments[0] as String;
      
      for (final userId in _players.keys) {
        final players = _players[userId]!;
        final index = players.indexWhere((p) => p.id == playerId);
        
        if (index != -1) {
          players.removeAt(index);
          return;
        }
      }
      
      throw Exception('Player not found');
    });
    
    when(() => getPlayersCount(any())).thenAnswer((invocation) async {
      final userId = invocation.positionalArguments[0] as String;
      return _players[userId]?.length ?? 0;
    });
    
    // Configurar comportamento padrão para métodos de feature toggles
    when(() => getFeatureToggles()).thenAnswer((_) async {
      return [
        {
          'feature': 'createGame',
          'enabled': true,
          'subscription_level': 'free',
        },
        {
          'feature': 'joinGame',
          'enabled': true,
          'subscription_level': 'free',
        },
        {
          'feature': 'unlimitedPlayers',
          'enabled': true,
          'subscription_level': 'premium',
        },
        {
          'feature': 'statistics',
          'enabled': true,
          'subscription_level': 'premium',
        },
        {
          'feature': 'exportData',
          'enabled': true,
          'subscription_level': 'pro',
        },
        {
          'feature': 'darkMode',
          'enabled': true,
          'subscription_level': 'free',
        },
      ];
    });
    
    when(() => updateFeatureToggle(
      feature: any(named: 'feature'),
      enabled: any(named: 'enabled'),
      subscriptionLevel: any(named: 'subscriptionLevel'),
    )).thenAnswer((_) async {});
  }

  // Métodos auxiliares para configurar o estado do mock
  void addUser(User user, {SubscriptionStatus status = SubscriptionStatus.free}) {
    _users[user.email!] = user;
    _subscriptions[user.id] = status;
  }
  
  void setCurrentUser(User? user) {
    _currentUser = user;
  }
  
  void addGame(Game game) {
    if (!_games.containsKey(game.userId)) {
      _games[game.userId] = [];
    }
    
    _games[game.userId]!.add(game);
  }
  
  void addPlayer(Player player) {
    if (!_players.containsKey(player.userId)) {
      _players[player.userId] = [];
    }
    
    _players[player.userId]!.add(player);
  }
  
  void setSubscriptionStatus(String userId, SubscriptionStatus status) {
    _subscriptions[userId] = status;
  }
}
