// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupInvitationImpl _$$GroupInvitationImplFromJson(
  Map<String, dynamic> json,
) => _$GroupInvitationImpl(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  createdBy: json['createdBy'] as String,
  email: json['email'] as String?,
  token: json['token'] as String,
  role:
      $enumDecodeNullable(_$GroupMemberRoleEnumMap, json['role']) ??
      GroupMemberRole.player,
  status:
      $enumDecodeNullable(_$InvitationStatusEnumMap, json['status']) ??
      InvitationStatus.pending,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$GroupInvitationImplToJson(
  _$GroupInvitationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'createdBy': instance.createdBy,
  'email': instance.email,
  'token': instance.token,
  'role': _$GroupMemberRoleEnumMap[instance.role]!,
  'status': _$InvitationStatusEnumMap[instance.status]!,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$GroupMemberRoleEnumMap = {
  GroupMemberRole.admin: 'admin',
  GroupMemberRole.dealer: 'dealer',
  GroupMemberRole.player: 'player',
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.rejected: 'rejected',
  InvitationStatus.expired: 'expired',
};
