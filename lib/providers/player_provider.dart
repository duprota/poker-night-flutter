import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Modelo para representar um jogador
class Player {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? photoUrl;
  
  Player({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.photoUrl,
  });
  
  // Criar um Player a partir de um Map (para uso com Supabase)
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      photoUrl: map['photo_url'],
    );
  }
  
  // Converter Player para Map (para uso com Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'photo_url': photoUrl,
    };
  }
}

// Estado para o provider de jogadores
class PlayersState {
  final List<Player> players;
  final bool isLoading;
  final String? errorMessage;
  
  PlayersState({
    this.players = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  
  PlayersState copyWith({
    List<Player>? players,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlayersState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Notifier para gerenciar o estado dos jogadores
class PlayersNotifier extends StateNotifier<PlayersState> {
  PlayersNotifier() : super(PlayersState());
  
  // Obter o cliente Supabase
  final supabase = Supabase.instance.client;
  
  // Carregar todos os jogadores
  Future<void> loadPlayers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await supabase
          .from('players')
          .select()
          .order('name');
      
      final players = (response as List)
          .map((player) => Player.fromMap(player))
          .toList();
      
      state = state.copyWith(players: players, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar jogadores: ${e.toString()}',
      );
    }
  }
  
  // Adicionar um novo jogador
  Future<void> addPlayer(Player player) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await supabase.from('players').insert(player.toMap());
      
      await loadPlayers(); // Recarregar a lista de jogadores
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
      
      await supabase
          .from('players')
          .update(player.toMap())
          .eq('id', player.id);
      
      await loadPlayers(); // Recarregar a lista de jogadores
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar jogador: ${e.toString()}',
      );
    }
  }
  
  // Excluir um jogador
  Future<void> deletePlayer(String playerId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await supabase
          .from('players')
          .delete()
          .eq('id', playerId);
      
      await loadPlayers(); // Recarregar a lista de jogadores
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao excluir jogador: ${e.toString()}',
      );
    }
  }
}

// Provider para acessar o estado dos jogadores
final playersProvider = StateNotifierProvider<PlayersNotifier, PlayersState>((ref) {
  return PlayersNotifier();
});
