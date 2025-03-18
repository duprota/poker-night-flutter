import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/models/game.dart';
import 'package:poker_night/models/player.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../mocks/supabase_mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGotrueClient mockGotrueClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockSupabaseFilterBuilder mockFilterBuilder;
  late MockUser mockUser;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGotrueClient = MockGotrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockSupabaseFilterBuilder();
    mockUser = MockUser();

    // Configurar o mock do Supabase
    when(() => mockSupabaseClient.auth).thenReturn(mockGotrueClient);
    when(() => mockGotrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');

    // Substituir o cliente Supabase real pelo mock
    SupabaseService.overrideClientForTesting(mockSupabaseClient);
  });

  tearDown(() {
    // Restaurar o cliente Supabase real
    SupabaseService.resetClient();
  });

  group('SupabaseService - Authentication', () {
    test('isAuthenticated deve retornar true quando o usuário está autenticado', () {
      // Arrange
      when(() => mockGotrueClient.currentUser).thenReturn(mockUser);

      // Act
      final result = SupabaseService.isAuthenticated;

      // Assert
      expect(result, true);
    });

    test('isAuthenticated deve retornar false quando o usuário não está autenticado', () {
      // Arrange
      when(() => mockGotrueClient.currentUser).thenReturn(null);

      // Act
      final result = SupabaseService.isAuthenticated;

      // Assert
      expect(result, false);
    });

    test('signInWithEmail deve chamar o método correto do Supabase', () async {
      // Arrange
      final authResponse = MockAuthResponse();
      when(() => mockGotrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => authResponse);

      // Act
      final result = await SupabaseService.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, authResponse);
      verify(() => mockGotrueClient.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('signOut deve chamar o método correto do Supabase', () async {
      // Arrange
      when(() => mockGotrueClient.signOut()).thenAnswer((_) async {});

      // Act
      await SupabaseService.signOut();

      // Assert
      verify(() => mockGotrueClient.signOut()).called(1);
    });
  });

  group('SupabaseService - Subscription', () {
    test('getUserSubscriptionStatus deve retornar o status correto', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenAnswer((_) async => {
        'user_id': 'test-user-id',
        'status': 'premium',
      });

      // Act
      final result = await SupabaseService.getUserSubscriptionStatus('test-user-id');

      // Assert
      expect(result, SubscriptionStatus.premium);
      verify(() => mockSupabaseClient.from('user_subscriptions')).called(1);
    });

    test('getUserSubscriptionStatus deve retornar free quando não encontrar assinatura', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenThrow(Exception('Not found'));

      // Act
      final result = await SupabaseService.getUserSubscriptionStatus('test-user-id');

      // Assert
      expect(result, SubscriptionStatus.free);
    });
  });

  group('SupabaseService - Games', () {
    test('getGames deve retornar a lista de jogos correta', () async {
      // Arrange
      final mockResponse = PostgrestResponse(
        data: [
          {
            'id': 'game-1',
            'user_id': 'test-user-id',
            'name': 'Friday Night Poker',
            'date': '2025-03-15T20:00:00.000Z',
            'location': 'My House',
            'buy_in': 50.0,
            'player_ids': ['player-1', 'player-2'],
          },
          {
            'id': 'game-2',
            'user_id': 'test-user-id',
            'name': 'Saturday Night Poker',
            'date': '2025-03-16T20:00:00.000Z',
            'location': 'John\'s House',
            'buy_in': 100.0,
            'player_ids': ['player-1', 'player-3'],
          },
        ],
        count: 2,
        status: 200,
        statusText: 'OK',
      );

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq(any(), any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => mockResponse);

      // Act
      final result = await SupabaseService.getGames('test-user-id');

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'game-1');
      expect(result[0].name, 'Friday Night Poker');
      expect(result[1].id, 'game-2');
      expect(result[1].name, 'Saturday Night Poker');
      verify(() => mockSupabaseClient.from('games')).called(1);
    });

    test('createGame deve criar um jogo corretamente', () async {
      // Arrange
      final game = Game(
        userId: 'test-user-id',
        name: 'New Game',
        date: DateTime.parse('2025-03-20T20:00:00.000Z'),
        location: 'My House',
        buyIn: 50.0,
      );

      final mockResponse = PostgrestResponse(
        data: [game.toJson()],
        count: 1,
        status: 201,
        statusText: 'Created',
      );

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.single()).thenAnswer((_) async => game.toJson());

      // Act
      final result = await SupabaseService.createGame(game);

      // Assert
      expect(result.name, 'New Game');
      expect(result.userId, 'test-user-id');
      verify(() => mockSupabaseClient.from('games')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });
  });

  group('SupabaseService - Players', () {
    test('getPlayers deve retornar a lista de jogadores correta', () async {
      // Arrange
      final mockResponse = PostgrestResponse(
        data: [
          {
            'id': 'player-1',
            'user_id': 'test-user-id',
            'name': 'John Doe',
            'email': 'john@example.com',
            'phone': '123456789',
            'photo_url': 'https://example.com/john.jpg',
          },
          {
            'id': 'player-2',
            'user_id': 'test-user-id',
            'name': 'Jane Smith',
            'email': 'jane@example.com',
            'phone': '987654321',
            'photo_url': null,
          },
        ],
        count: 2,
        status: 200,
        statusText: 'OK',
      );

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq(any(), any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => mockResponse);

      // Act
      final result = await SupabaseService.getPlayers('test-user-id');

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'player-1');
      expect(result[0].name, 'John Doe');
      expect(result[1].id, 'player-2');
      expect(result[1].name, 'Jane Smith');
      verify(() => mockSupabaseClient.from('players')).called(1);
    });

    test('createPlayer deve criar um jogador corretamente', () async {
      // Arrange
      final player = Player(
        userId: 'test-user-id',
        name: 'New Player',
        email: 'new@example.com',
        phone: '555555555',
      );

      final mockResponse = PostgrestResponse(
        data: [player.toJson()],
        count: 1,
        status: 201,
        statusText: 'Created',
      );

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.single()).thenAnswer((_) async => player.toJson());

      // Act
      final result = await SupabaseService.createPlayer(player);

      // Assert
      expect(result.name, 'New Player');
      expect(result.userId, 'test-user-id');
      verify(() => mockSupabaseClient.from('players')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });
  });

  group('SupabaseService - Feature Toggles', () {
    test('getFeatureToggles deve retornar a lista de feature toggles correta', () async {
      // Arrange
      final mockResponse = PostgrestResponse(
        data: [
          {
            'id': 1,
            'feature': 'createGame',
            'enabled': true,
            'subscription_level': 'free',
          },
          {
            'id': 2,
            'feature': 'statistics',
            'enabled': true,
            'subscription_level': 'premium',
          },
          {
            'id': 3,
            'feature': 'exportData',
            'enabled': true,
            'subscription_level': 'pro',
          },
        ],
        count: 3,
        status: 200,
        statusText: 'OK',
      );

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.execute()).thenAnswer((_) async => mockResponse);

      // Act
      final result = await SupabaseService.getFeatureToggles();

      // Assert
      expect(result.length, 3);
      expect(result[0]['feature'], 'createGame');
      expect(result[0]['enabled'], true);
      expect(result[0]['subscription_level'], 'free');
      expect(result[1]['feature'], 'statistics');
      expect(result[1]['subscription_level'], 'premium');
      verify(() => mockSupabaseClient.from('feature_toggles')).called(1);
    });
  });
}
