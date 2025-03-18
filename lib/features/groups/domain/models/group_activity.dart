import 'package:equatable/equatable.dart';

/// Enum que define os possíveis tipos de atividade em um grupo
enum ActivityType {
  memberJoined,
  memberLeft,
  gameScheduled,
  gameCompleted,
  groupUpdated
}

/// Modelo que representa uma atividade ocorrida em um grupo
class GroupActivity extends Equatable {
  final String id;
  final String groupId;
  final String actorId;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const GroupActivity({
    required this.id,
    required this.groupId,
    required this.actorId,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });

  /// Cria uma instância de GroupActivity a partir de um mapa JSON
  factory GroupActivity.fromJson(Map<String, dynamic> json) {
    return GroupActivity(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      actorId: json['actor_id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.groupUpdated,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  /// Converte a instância em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'actor_id': actorId,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Cria uma cópia da instância com os valores atualizados
  GroupActivity copyWith({
    String? id,
    String? groupId,
    String? actorId,
    ActivityType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return GroupActivity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      actorId: actorId ?? this.actorId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        actorId,
        type,
        timestamp,
        metadata,
      ];
}
