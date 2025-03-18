// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupActivityImpl _$$GroupActivityImplFromJson(Map<String, dynamic> json) =>
    _$GroupActivityImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String?,
      activityType: $enumDecode(
        _$GroupActivityTypeEnumMap,
        json['activityType'],
      ),
      details: json['details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GroupActivityImplToJson(_$GroupActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'activityType': _$GroupActivityTypeEnumMap[instance.activityType]!,
      'details': instance.details,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$GroupActivityTypeEnumMap = {
  GroupActivityType.groupCreated: 'groupCreated',
  GroupActivityType.memberAdded: 'memberAdded',
  GroupActivityType.memberRemoved: 'memberRemoved',
  GroupActivityType.roleChanged: 'roleChanged',
  GroupActivityType.gameCreated: 'gameCreated',
  GroupActivityType.gameUpdated: 'gameUpdated',
  GroupActivityType.gameDeleted: 'gameDeleted',
  GroupActivityType.invitationSent: 'invitationSent',
  GroupActivityType.invitationAccepted: 'invitationAccepted',
};
