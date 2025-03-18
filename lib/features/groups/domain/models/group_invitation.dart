import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_invitation.freezed.dart';
part 'group_invitation.g.dart';

/// Enum que define os possíveis status de um convite para grupo
enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired
}

/// Modelo que representa um convite para participar de um grupo
@freezed
class GroupInvitation with _$GroupInvitation {
  const factory GroupInvitation({
    required String id,
    required String groupId,
    required String inviterId,
    required String inviteeId,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(InvitationStatus.pending) InvitationStatus status,
  }) = _GroupInvitation;

  factory GroupInvitation.fromJson(Map<String, dynamic> json) => _$GroupInvitationFromJson(json);
}
