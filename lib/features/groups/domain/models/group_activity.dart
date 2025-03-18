import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'group_activity.freezed.dart';
part 'group_activity.g.dart';

enum GroupActivityType {
  groupCreated,
  memberAdded,
  memberRemoved,
  roleChanged,
  gameCreated,
  gameUpdated,
  gameDeleted,
  invitationSent,
  invitationAccepted,
}

@freezed
class GroupActivity with _$GroupActivity {
  const factory GroupActivity({
    required String id,
    required String groupId,
    String? userId,
    required GroupActivityType activityType,
    Map<String, dynamic>? details,
    required DateTime createdAt,
  }) = _GroupActivity;

  factory GroupActivity.fromJson(Map<String, dynamic> json) => _$GroupActivityFromJson(json);
}
