import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'group_member.freezed.dart';
part 'group_member.g.dart';

enum GroupMemberRole {
  admin,
  dealer,
  player,
}

@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String id,
    required String groupId,
    required String userId,
    @Default(GroupMemberRole.player) GroupMemberRole role,
    required DateTime joinedAt,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
}
