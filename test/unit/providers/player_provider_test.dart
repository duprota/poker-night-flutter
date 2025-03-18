import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/providers/player_provider.dart';
import 'package:poker_night/models/player.dart';
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
    when(() => mockSupabaseClient.from('players'))
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

  group('PlayerProvider Tests', () {
    test('Estado inicial deve estar vazio e não carregando', () {
      // Obter o estado inicial
      final playerState = container.read(playerProvider);
      
      // Verificar se o estado inicial está vazio e não carregando
      expect(playerState.players, isEmpty);
      expect(playerState.isLoading, false);
      expect(playerState.error, null);
    });

    test('loadPlayers deve atualizar o estado corretamente quando bem-sucedido', () async {
      // Configurar o mock para retornar dados de jogadores
      final mockPlayers = [
        {
          'id': '1',
          'name': 'João Silva',
          'email': 'joao@example.com',
          'phone': '11999999999',
          'user_id': 'user-123',
          'created_at': '2025-03-15T10:00:00.000Z',
          'updated_at': '2025-03-15T10:00:00.000Z',
        },
        {
          'id': '2',
          'name': 'Maria Souza',
          'email': 'maria@example.com',
          'phone': '11988888888',
          'user_id': 'user-123',
          'created_at': '2025-03-16T10:00:00.000Z',
          'updated_at': '2025-03-16T10:00:00.000Z',
        },
      ];
      
      when(() => mockPostgrestFilterBuilder.eq('user_id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.order('name', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenAnswer((_) async => PostgrestResponse(
            data: mockPlayers,
            count: mockPlayers.length,
            status: 200,
            error: null,
            statusText: 'OK'
          ));
      
      // Executar o método de carregamento de jogadores
      await container.read(playerProvider.notifier).loadPlayers('user-123');
      
      // Verificar se o estado foi atualizado corretamente
      final playerState = container.read(playerProvider);
      expect(playerState.players.length, 2);
      expect(playerState.players[0].id, '1');
      expect(playerState.players[0].name, 'João Silva');
      expect(playerState.players[1].id, '2');
      expect(playerState.players[1].name, 'Maria Souza');
      expect(playerState.isLoading, false);
      expect(playerState.error, null);
    });

    test('loadPlayers deve atualizar o estado corretamente quando falhar', () async {
      // Configurar o mock para lançar uma exceção
      when(() => mockPostgrestFilterBuilder.eq('user_id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.order('name', ascending: any(named: 'ascending')))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.execute())
          .thenThrow(Exception('Failed to load players'));
      
      // Executar o método de carregamento de jogadores
      await container.read(playerProvider.notifier).loadPlayers('user-123');
      
      // Verificar se o estado foi atualizado corretamente
      final playerState = container.read(playerProvider);
      expect(playerState.players, isEmpty);
      expect(playerState.isLoading, false);
      expect(playerState.error, 'Failed to load players');
    });

    test('createPlayer deve adicionar um jogador ao estado quando bem-sucedido', () async {
      // Configurar o mock para retornar sucesso ao criar um jogador
      when(() => mockPostgrestBuilder.insert(any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.select())
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.single())
          .thenAnswer((_) async => {
            'id': '3',
            'name': 'Pedro Santos',
            'email': 'pedro@example.com',
            'phone': '11977777777',
            'user_id': 'user-123',
            'created_at': '2025-03-17T10:00:00.000Z',
            'updated_at': '2025-03-17T10:00:00.000Z',
          });
      
      // Criar um novo jogador
      final newPlayer = Player(
        id: '',
        name: 'Pedro Santos',
        email: 'pedro@example.com',
        phone: '11977777777',
        userId: 'user-123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Executar o método de criação de jogador
      await container.read(playerProvider.notifier).createPlayer(newPlayer);
      
      // Verificar se o estado foi atualizado corretamente
      final playerState = container.read(playerProvider);
      expect(playerState.players.length, 1);
      expect(playerState.players[0].id, '3');
      expect(playerState.players[0].name, 'Pedro Santos');
      expect(playerState.isLoading, false);
      expect(playerState.error, null);
    });

    test('updatePlayer deve atualizar um jogador no estado quando bem-sucedido', () async {
      // Adicionar um jogador ao estado inicial
      final initialPlayer = Player(
        id: '1',
        name: 'João Silva',
        email: 'joao@example.com',
        phone: '11999999999',
        userId: 'user-123',
        createdAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
        updatedAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
      );
      
      // Definir o estado inicial manualmente
      container.read(playerProvider.notifier).updateState(
        PlayerState(players: [initialPlayer], isLoading: false, error: null)
      );
      
      // Configurar o mock para retornar sucesso ao atualizar um jogador
      when(() => mockPostgrestBuilder.update(any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.eq('id', any()))
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.select())
          .thenReturn(mockPostgrestFilterBuilder);
      when(() => mockPostgrestFilterBuilder.single())
          .thenAnswer((_) async => {
            'id': '1',
            'name': 'João Silva Atualizado',
            'email': 'joao.novo@example.com',
            'phone': '11999999999',
            'user_id': 'user-123',
            'created_at': '2025-03-15T10:00:00.000Z',
            'updated_at': '2025-03-17T10:00:00.000Z',
          });
      
      // Criar um jogador atualizado
      final updatedPlayer = Player(
        id: '1',
        name: 'João Silva Atualizado',
        email: 'joao.novo@example.com',
        phone: '11999999999',
        userId: 'user-123',
        createdAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
        updatedAt: DateTime.now(),
      );
      
      // Executar o método de atualização de jogador
      await container.read(playerProvider.notifier).updatePlayer(updatedPlayer);
      
      // Verificar se o estado foi atualizado corretamente
      final playerState = container.read(playerProvider);
      expect(playerState.players.length, 1);
      expect(playerState.players[0].id, '1');
      expect(playerState.players[0].name, 'João Silva Atualizado');
      expect(playerState.players[0].email, 'joao.novo@example.com');
      expect(playerState.isLoading, false);
      expect(playerState.error, null);
    });

    test('deletePlayer deve remover um jogador do estado quando bem-sucedido', () async {
      // Adicionar um jogador ao estado inicial
      final initialPlayer = Player(
        id: '1',
        name: 'João Silva',
        email: 'joao@example.com',
        phone: '11999999999',
        userId: 'user-123',
        createdAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
        updatedAt: DateTime.parse('2025-03-15T10:00:00.000Z'),
      );
      
      // Definir o estado inicial manualmente
      container.read(playerProvider.notifier).updateState(
        PlayerState(players: [initialPlayer], isLoading: false, error: null)
      );
      
      // Configurar o mock para retornar sucesso ao excluir um jogador
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
      
      // Executar o método de exclusão de jogador
      await container.read(playerProvider.notifier).deletePlayer('1');
      
      // Verificar se o estado foi atualizado corretamente
      final playerState = container.read(playerProvider);
      expect(playerState.players, isEmpty);
      expect(playerState.isLoading, false);
      expect(playerState.error, null);
    });
  });
}
