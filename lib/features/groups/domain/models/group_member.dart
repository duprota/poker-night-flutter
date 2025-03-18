import 'package:equatable/equatable.dart';

/// Enum que define os possíveis papéis de um membro em um grupo
enum MemberRole {
  owner,
  admin,
  member
}

/// Modelo que representa a associação de um jogador a um grupo
class GroupMember extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;
  final DateTime? lastActive;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    this.role = MemberRole.member,
    required this.joinedAt,
    this.lastActive,
  });

  /// Cria uma instância de GroupMember a partir de um mapa JSON
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: MemberRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
    );
  }

  /// Converte a instância em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role.toString().split('.').last,
      'joined_at': joinedAt.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
    };
  }

  /// Cria uma cópia da instância com os valores atualizados
  GroupMember copyWith({
    String? id,
    String? groupId,
    String? userId,
    MemberRole? role,
    DateTime? joinedAt,
    DateTime? lastActive,
  }) {
    return GroupMember(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        role,
        joinedAt,
        lastActive,
      ];
}
