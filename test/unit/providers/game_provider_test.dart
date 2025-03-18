import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/game_provider.dart';
import 'package:poker_night/models/game.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import '../../mocks/supabase_mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestBuilder mockPostgrestBuilder;
  late MockPostgrestFilterBuilder mockPostgrestFilterBuilder;
  late ProviderContainer container;

  setUp(() {
    // Configurar os mocks
    mockSupabaseClient = SupabaseMocks.createMockSupabaseClient();
    mockPostgrestBuilder = MockPostgrestBuilder();
    mockPostgrestFilterBuilder = MockPostgrestFilterBuilder();
    
    // Configurar o comportamento do mockSupabaseClient
    when(() => mockSupabaseClient.from('games'))
        .thenReturn(mockPostgrestBuilder);
    when(() => mockPostgrestBuilder.select())
        .thenReturn(mockPostgrestFilterBuilder);
    
    // Substituir a implementação do SupabaseService.client
    SupabaseService.client = mockSupabaseClient;
    
    // Criar o container do Riverpod
    container = ProviderContainer();
  });

  tearDown(() {
    // Limpar o container após cada teste
    container.dispose();
  });

  group('GameProvider Tests', () {
    test('Estado inicial deve estar vazio e não carregando', () {
      // Obter o estado inicial
      final gameState = container.read(gameProvider);
      
      // Verificar se o estado inicial está vazio e não carregando
      expect(gameState.games, isEmpty);
      expect(gameState.isLoading, false);
      expect(gameState.error, null);
    });

    test('loadGames deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar dados de jogos
      final mockGames = [
        {
          'id': '1',
          'name': 'Jogo 1',
          'date': '2025-03-17T19:00:00.000Z',
          'location': 'Casa do João',
          'buy_in': 50.0,
          'user_id': 'user-123',
          'created_at': '2025-03-15T10:00:00.000Z',
          'updated_at': '2025-03-15T10:00:00.000Z',
        },
        {
          'id': '2',
          'name': 'Jogo 2',
          'date': '2025-03-24T19:00:00.000Z',
          'location': 'Casa do Pedro',
          'buy_in': 100.0,
          'user_id': 'user-123',
          'created_at': '2025-03-16T10:00:00.000Z',
          'updated_at': '2025-03-16T10:00:00.000Z',
        },
      ];
      
      when(() => mockPostgrestFilterBuilder.eq('user_id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.order('date', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenAnswer((_) async => PostgrestResponse(
            data: mockGames,
            count: mockGames.length,
            status: 200,
            error: null,
            statusText: 'OK'
          ));
      
      // Executar o método de carregamento de jogos
      await container.read(gameProvider.notifier).loadGames('user-123');
      
      // Verificar se o estado foi atualizado corretamente
      final gameState = container.read(gameProvider);
      expect(gameState.games.length, 2);
      expect(gameState.games[0].id, '1');
      expect(gameState.games[0].name, 'Jogo 1');
      expect(gameState.games[1].id, '2');
      expect(gameState.games[1].name, 'Jogo 2');
      expect(gameState.isLoading, false);
      expect(gameState.error, null);
    });

    test('loadGames deve atualizar o estado corretamente quando falhar', () async {
      // Configurar o mock para lançar uma exceção
      when(() => mockPostgrestFilterBuilder.eq('user_id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.order('date', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenThrow(Exception('Failed to load games'));
      
      // Executar o método de carregamento de jogos
      await container.read(gameProvider.notifier).loadGames('user-123');
      
      // Verificar se o estado foi atualizado corretamente
      final gameState = container.read(gameProvider);
      expect(gameState.games, isEmpty);
      expect(gameState.isLoading, false);
      expect(gameState.error, 'Failed to load games');
    });

    test('createGame deve adicionar um jogo ao estado quando bem-sucedido', () async {
      // Configurar o mock para retornar sucesso ao criar um jogo
      when(() => mockPostgrestBuilder.insert(any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.select())
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.single())
          .thenAnswer((_) async => {
            'id': '3',
            'name': 'Novo Jogo',
            'date': '2025-03-30T19:00:00.000Z',
            'location': 'Casa do Carlos',
            'buy_in': 75.0,
            'user_id': 'user-123',
            'created_at': '2025-03-17T10:00:00.000Z',
            'updated_at': '2025-03-17T10:00:00.000Z',
          });
      
      // Criar um novo jogo
      final newGame = Game(
        id: '',
        name: 'Novo Jogo',
        date: DateTime.parse('2025-03-30T19:00:00.000Z'),
        location: 'Casa do Carlos',
        buyIn: 75.0,
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Executar o método de criação de jogo
      await container.read(gameProvider.notifier).createGame(newGame);
      
      // Verificar se o estado foi atualizado corretamente
      final gameState = container.read(gameProvider);
      expect(gameState.games.length, 1);
      expect(gameState.games[0].id, '3');
      expect(gameState.games[0].name, 'Novo Jogo');
      expect(gameState.isLoading, false);
      expect(gameState.error, null);
    });

    test('updateGame deve atualizar um jogo no estado quando bem-sucedido', () async {
      // Adicionar um jogo ao estado inicial
      final initialGame = Game(
        id: '1',
        name: 'Jogo 1',
        date: DateTime.parse('2025-03-17T19:00:00.000Z'),
        location: 'Casa do João',
        buyIn: 50.0,
        userId: 'user-123',
        createdAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
        updatedAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
      );
      
      // Definir o estado inicial manualmente
      container.read(gameProvider.notifier).updateState(
        GameState(games: [initialGame], isLoading: false, error: null)
      );
      
      // Configurar o mock para retornar sucesso ao atualizar um jogo
      when(() => mockPostgrestBuilder.update(any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.eq('id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.select())
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.single())
          .thenAnswer((_) async => {
            'id': '1',
            'name': 'Jogo 1 Atualizado',
            'date': '2025-03-17T20:00:00.000Z',
            'location': 'Casa do João',
            'buy_in': 60.0,
            'user_id': 'user-123',
            'created_at': '2025-03-15T10:00:00.000Z',
            'updated_at': '2025-03-17T10:00:00.000Z',
          });
      
      // Criar um jogo atualizado
      final updatedGame = Game(
        id: '1',
        name: 'Jogo 1 Atualizado',
        date: DateTime.parse('2025-03-17T20:00:00.000Z'),
        location: 'Casa do João',
        buyIn: 60.0,
        userId: 'user-123',
        createdAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
        updatedAt: DateTime.now(),
      );
      
      // Executar o método de atualização de jogo
      await container.read(gameProvider.notifier).updateGame(updatedGame);
      
      // Verificar se o estado foi atualizado corretamente
      final gameState = container.read(gameProvider);
      expect(gameState.games.length, 1);
      expect(gameState.games[0].id, '1');
      expect(gameState.games[0].name, 'Jogo 1 Atualizado');
      expect(gameState.games[0].buyIn, 60.0);
      expect(gameState.isLoading, false);
      expect(gameState.error, null);
    });

    test('deleteGame deve remover um jogo do estado quando bem-sucedido', () async {
      // Adicionar um jogo ao estado inicial
      final initialGame = Game(
        id: '1',
        name: 'Jogo 1',
        date: DateTime.parse('2025-03-17T19:00:00.000Z'),
        location: 'Casa do João',
        buyIn: 50.0,
        userId: 'user-123',
        createdAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
        updatedAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
      );
      
      // Definir o estado inicial manualmente
      container.read(gameProvider.notifier).updateState(
        GameState(games: [initialGame], isLoading: false, error: null)
      );
      
      // Configurar o mock para retornar sucesso ao excluir um jogo
      when(() => mockPostgrestBuilder.delete())
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.eq('id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenAnswer((_) async => PostgrestResponse(
            data: null,
            count: null,
            status: 204,
            error: null,
            statusText: 'No Content'
          ));
      
      // Executar o método de exclusão de jogo
      await container.read(gameProvider.notifier).deleteGame('1');
      
      // Verificar se o estado foi atualizado corretamente
      final gameState = container.read(gameProvider);
      expect(gameState.games, isEmpty);
      expect(gameState.isLoading, false);
      expect(gameState.error, null);
    });
  });
}
