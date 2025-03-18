import 'package:uuid/uuid.dart';

/// Modelo para representar um jogo de poker
class Game {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final String location;
  final double buyIn;
  final List<String> playerIds;
  
  Game({
    String? id,
    required this.userId,
    required this.name,
    required this.date,
    required this.location,
    required this.buyIn,
    this.playerIds = const [],
  }) : id = id ?? const Uuid().v4();
  
  /// Criar um Game a partir de um JSON (para uso com Supabase)
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      buyIn: json['buy_in'].toDouble(),
      playerIds: json['player_ids'] != null 
          ? List<String>.from(json['player_ids']) 
          : [],
    );
  }
  
  /// Converter Game para JSON (para uso com Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'buy_in': buyIn,
      'player_ids': playerIds,
    };
  }
  
  /// Criar uma cópia do objeto com alterações
  Game copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? date,
    String? location,
    double? buyIn,
    List<String>? playerIds,
  }) {
    return Game(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      buyIn: buyIn ?? this.buyIn,
      playerIds: playerIds ?? this.playerIds,
    );
  }
}
