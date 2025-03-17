import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Modelo para representar um jogo de poker
class Game {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final double buyIn;
  final List<String> playerIds;
  
  Game({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.buyIn,
    required this.playerIds,
  });
  
  // Criar um Game a partir de um Map (para uso com Supabase)
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      buyIn: map['buy_in'].toDouble(),
      playerIds: List<String>.from(map['player_ids'] ?? []),
    );
  }
  
  // Converter Game para Map (para uso com Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'buy_in': buyIn,
      'player_ids': playerIds,
    };
  }
}

// Estado para o provider de jogos
class GamesState {
  final List<Game> games;
  final bool isLoading;
  final String? errorMessage;
  
  GamesState({
    this.games = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  
  GamesState copyWith({
    List<Game>? games,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GamesState(
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Notifier para gerenciar o estado dos jogos
class GamesNotifier extends StateNotifier<GamesState> {
  GamesNotifier() : super(GamesState());
  
  // Obter o cliente Supabase
  final supabase = Supabase.instance.client;
  
  // Carregar todos os jogos
  Future<void> loadGames() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await supabase
          .from('games')
          .select()
          .order('date', ascending: false);
      
      final games = (response as List)
          .map((game) => Game.fromMap(game))
          .toList();
      
      state = state.copyWith(games: games, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar jogos: ${e.toString()}',
      );
    }
  }
  
  // Adicionar um novo jogo
  Future<void> addGame(Game game) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await supabase.from('games').insert(game.toMap());
      
      await loadGames(); // Recarregar a lista de jogos
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao adicionar jogo: ${e.toString()}',
      );
    }
  }
  
  // Atualizar um jogo existente
  Future<void> updateGame(Game game) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await supabase
          .from('games')
          .update(game.toMap())
          .eq('id', game.id);
      
      await loadGames(); // Recarregar a lista de jogos
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar jogo: ${e.toString()}',
      );
    }
  }
  
  // Excluir um jogo
  Future<void> deleteGame(String gameId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await supabase
          .from('games')
          .delete()
          .eq('id', gameId);
      
      await loadGames(); // Recarregar a lista de jogos
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao excluir jogo: ${e.toString()}',
      );
    }
  }
}

// Provider para acessar o estado dos jogos
final gamesProvider = StateNotifierProvider<GamesNotifier, GamesState>((ref) {
  return GamesNotifier();
});
