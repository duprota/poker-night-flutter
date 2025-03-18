import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// Modelo que representa um grupo de jogadores de poker
@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String description,
    required String ownerId,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    @Default(false) bool isPrivate,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
