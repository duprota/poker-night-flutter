// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  createdBy: json['createdBy'] as String,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 8,
  isPublic: json['isPublic'] as bool? ?? false,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdBy': instance.createdBy,
      'maxPlayers': instance.maxPlayers,
      'isPublic': instance.isPublic,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
