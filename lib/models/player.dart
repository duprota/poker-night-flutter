import 'package:uuid/uuid.dart';

/// Modelo para representar um jogador de poker
class Player {
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? stats;
  
  Player({
    String? id,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.email,
    this.phone,
    this.stats,
  }) : id = id ?? const Uuid().v4();
  
  /// Criar um Player a partir de um JSON (para uso com Supabase)
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      photoUrl: json['photo_url'],
      email: json['email'],
      phone: json['phone'],
      stats: json['stats'],
    );
  }
  
  /// Converter Player para JSON (para uso com Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'photo_url': photoUrl,
      'email': email,
      'phone': phone,
      'stats': stats,
    };
  }
  
  /// Criar uma cópia do objeto com alterações
  Player copyWith({
    String? id,
    String? userId,
    String? name,
    String? photoUrl,
    String? email,
    String? phone,
    Map<String, dynamic>? stats,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      stats: stats ?? this.stats,
    );
  }
}
