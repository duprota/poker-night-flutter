import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:poker_night/features/groups/domain/models/group_member.dart';

part 'group_invitation.freezed.dart';
part 'group_invitation.g.dart';

enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
}

@freezed
class GroupInvitation with _$GroupInvitation {
  const factory GroupInvitation({
    required String id,
    required String groupId,
    required String createdBy,
    String? email,
    required String token,
    @Default(GroupMemberRole.player) GroupMemberRole role,
    @Default(InvitationStatus.pending) InvitationStatus status,
    required DateTime expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GroupInvitation;

  factory GroupInvitation.fromJson(Map<String, dynamic> json) => _$GroupInvitationFromJson(json);
}
