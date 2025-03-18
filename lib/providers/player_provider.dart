import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/models/player.dart';

// Estado para o provider de jogadores
class PlayerState {
  final List<Player> players;
  final bool isLoading;
  final String? errorMessage;
  
  PlayerState({
    this.players = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  
  PlayerState copyWith({
    List<Player>? players,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlayerState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Notifier para gerenciar o estado dos jogadores
class PlayerProvider extends StateNotifier<PlayerState> {
  PlayerProvider() : super(PlayerState());
  
  // Carregar todos os jogadores
  Future<void> loadPlayers(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final players = await SupabaseService.getPlayers(userId);
      
      state = state.copyWith(players: players, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar jogadores: ${e.toString()}',
      );
    }
  }
  
  // Adicionar um novo jogador
  Future<void> createPlayer(Player player) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await SupabaseService.createPlayer(player);
      
      await loadPlayers(player.userId); // Recarregar a lista de jogadores
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao adicionar jogador: ${e.toString()}',
      );
    }
  }
  
  // Atualizar um jogador existente
  Future<void> updatePlayer(Player player) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await SupabaseService.updatePlayer(player);
      
      await loadPlayers(player.userId); // Recarregar a lista de jogadores
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar jogador: ${e.toString()}',
      );
    }
  }
  
  // Excluir um jogador
  Future<void> deletePlayer(String playerId, String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await SupabaseService.deletePlayer(playerId);
      
      await loadPlayers(userId); // Recarregar a lista de jogadores
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao excluir jogador: ${e.toString()}',
      );
    }
  }
  
  // Obter contagem de jogadores para um usuário
  Future<int> countPlayers(String userId) async {
    try {
      return await SupabaseService.countPlayers(userId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao contar jogadores: ${e.toString()}',
      );
      return 0;
    }
  }
  
  // Obter estatísticas de um jogador
  Future<Map<String, dynamic>> getPlayerStatistics(String playerId) async {
    try {
      return await SupabaseService.getPlayerStatistics(playerId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao obter estatísticas do jogador: ${e.toString()}',
      );
      return {
        'games_played': 0,
        'profit_loss': 0.0,
        'win_rate': 0.0,
      };
    }
  }
}

// Provider para acessar o estado dos jogadores
final playerProvider = StateNotifierProvider<PlayerProvider, PlayerState>((ref) {
  return PlayerProvider();
});
