import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    String? description,
    required String createdBy,
    @Default(8) int maxPlayers,
    @Default(false) bool isPublic,
    String? avatarUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
