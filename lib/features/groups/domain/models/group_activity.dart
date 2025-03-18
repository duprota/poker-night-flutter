import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_activity.freezed.dart';
part 'group_activity.g.dart';

/// Enum que define os possíveis tipos de atividade em um grupo
enum ActivityType {
  memberJoined,
  memberLeft,
  gameScheduled,
  gameCompleted,
  groupUpdated
}

/// Modelo que representa uma atividade ocorrida em um grupo
@freezed
class GroupActivity with _$GroupActivity {
  const factory GroupActivity({
    required String id,
    required String groupId,
    required String actorId,
    required ActivityType type,
    required DateTime timestamp,
    @Default({}) Map<String, dynamic> metadata,
  }) = _GroupActivity;

  factory GroupActivity.fromJson(Map<String, dynamic> json) => _$GroupActivityFromJson(json);
}
