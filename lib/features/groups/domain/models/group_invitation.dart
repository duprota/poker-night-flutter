import 'package:equatable/equatable.dart';

/// Enum que define os possíveis status de um convite para grupo
enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired
}

/// Modelo que representa um convite para participar de um grupo
class GroupInvitation extends Equatable {
  final String id;
  final String groupId;
  final String inviterId;
  final String inviteeId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InvitationStatus status;

  const GroupInvitation({
    required this.id,
    required this.groupId,
    required this.inviterId,
    required this.inviteeId,
    required this.createdAt,
    required this.expiresAt,
    this.status = InvitationStatus.pending,
  });

  /// Cria uma instância de GroupInvitation a partir de um mapa JSON
  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      inviterId: json['inviter_id'] as String,
      inviteeId: json['invitee_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
    );
  }

  /// Converte a instância em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  /// Cria uma cópia da instância com os valores atualizados
  GroupInvitation copyWith({
    String? id,
    String? groupId,
    String? inviterId,
    String? inviteeId,
    DateTime? createdAt,
    DateTime? expiresAt,
    InvitationStatus? status,
  }) {
    return GroupInvitation(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        inviterId,
        inviteeId,
        createdAt,
        expiresAt,
        status,
      ];
}
