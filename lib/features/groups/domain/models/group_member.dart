import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';
part 'group_member.g.dart';

/// Enum que define os possíveis papéis de um membro em um grupo
enum MemberRole {
  owner,
  admin,
  member
}

/// Modelo que representa a associação de um jogador a um grupo
@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String id,
    required String groupId,
    required String userId,
    @Default(MemberRole.member) MemberRole role,
    required DateTime joinedAt,
    DateTime? lastActive,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
}
