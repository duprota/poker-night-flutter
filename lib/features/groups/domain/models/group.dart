import 'package:equatable/equatable.dart';

/// Modelo que representa um grupo de jogadores de poker
class Group extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;
  final bool isPrivate;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
    this.avatarUrl,
    this.isPrivate = false,
  });

  /// Cria uma instância de Group a partir de um mapa JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
    );
  }

  /// Converte a instância em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'avatar_url': avatarUrl,
      'is_private': isPrivate,
    };
  }

  /// Cria uma cópia da instância com os valores atualizados
  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    bool? isPrivate,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        createdAt,
        updatedAt,
        avatarUrl,
        isPrivate,
      ];
}
