// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupInvitation _$GroupInvitationFromJson(Map<String, dynamic> json) {
  return _GroupInvitation.fromJson(json);
}

/// @nodoc
mixin _$GroupInvitation {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  GroupMemberRole get role => throw _privateConstructorUsedError;
  InvitationStatus get status => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this GroupInvitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupInvitationCopyWith<GroupInvitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupInvitationCopyWith<$Res> {
  factory $GroupInvitationCopyWith(
    GroupInvitation value,
    $Res Function(GroupInvitation) then,
  ) = _$GroupInvitationCopyWithImpl<$Res, GroupInvitation>;
  @useResult
  $Res call({
    String id,
    String groupId,
    String createdBy,
    String? email,
    String token,
    GroupMemberRole role,
    InvitationStatus status,
    DateTime expiresAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$GroupInvitationCopyWithImpl<$Res, $Val extends GroupInvitation>
    implements $GroupInvitationCopyWith<$Res> {
  _$GroupInvitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? createdBy = null,
    Object? email = freezed,
    Object? token = null,
    Object? role = null,
    Object? status = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            groupId:
                null == groupId
                    ? _value.groupId
                    : groupId // ignore: cast_nullable_to_non_nullable
                        as String,
            createdBy:
                null == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            token:
                null == token
                    ? _value.token
                    : token // ignore: cast_nullable_to_non_nullable
                        as String,
            role:
                null == role
                    ? _value.role
                    : role // ignore: cast_nullable_to_non_nullable
                        as GroupMemberRole,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as InvitationStatus,
            expiresAt:
                null == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupInvitationImplCopyWith<$Res>
    implements $GroupInvitationCopyWith<$Res> {
  factory _$$GroupInvitationImplCopyWith(
    _$GroupInvitationImpl value,
    $Res Function(_$GroupInvitationImpl) then,
  ) = __$$GroupInvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String groupId,
    String createdBy,
    String? email,
    String token,
    GroupMemberRole role,
    InvitationStatus status,
    DateTime expiresAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$GroupInvitationImplCopyWithImpl<$Res>
    extends _$GroupInvitationCopyWithImpl<$Res, _$GroupInvitationImpl>
    implements _$$GroupInvitationImplCopyWith<$Res> {
  __$$GroupInvitationImplCopyWithImpl(
    _$GroupInvitationImpl _value,
    $Res Function(_$GroupInvitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? createdBy = null,
    Object? email = freezed,
    Object? token = null,
    Object? role = null,
    Object? status = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$GroupInvitationImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        groupId:
            null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                    as String,
        createdBy:
            null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        token:
            null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                    as String,
        role:
            null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                    as GroupMemberRole,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as InvitationStatus,
        expiresAt:
            null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupInvitationImpl
    with DiagnosticableTreeMixin
    implements _GroupInvitation {
  const _$GroupInvitationImpl({
    required this.id,
    required this.groupId,
    required this.createdBy,
    this.email,
    required this.token,
    this.role = GroupMemberRole.player,
    this.status = InvitationStatus.pending,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$GroupInvitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupInvitationImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String createdBy;
  @override
  final String? email;
  @override
  final String token;
  @override
  @JsonKey()
  final GroupMemberRole role;
  @override
  @JsonKey()
  final InvitationStatus status;
  @override
  final DateTime expiresAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GroupInvitation(id: $id, groupId: $groupId, createdBy: $createdBy, email: $email, token: $token, role: $role, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GroupInvitation'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('groupId', groupId))
      ..add(DiagnosticsProperty('createdBy', createdBy))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('token', token))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('expiresAt', expiresAt))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupInvitationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    createdBy,
    email,
    token,
    role,
    status,
    expiresAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupInvitationImplCopyWith<_$GroupInvitationImpl> get copyWith =>
      __$$GroupInvitationImplCopyWithImpl<_$GroupInvitationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupInvitationImplToJson(this);
  }
}

abstract class _GroupInvitation implements GroupInvitation {
  const factory _GroupInvitation({
    required final String id,
    required final String groupId,
    required final String createdBy,
    final String? email,
    required final String token,
    final GroupMemberRole role,
    final InvitationStatus status,
    required final DateTime expiresAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$GroupInvitationImpl;

  factory _GroupInvitation.fromJson(Map<String, dynamic> json) =
      _$GroupInvitationImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get createdBy;
  @override
  String? get email;
  @override
  String get token;
  @override
  GroupMemberRole get role;
  @override
  InvitationStatus get status;
  @override
  DateTime get expiresAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupInvitationImplCopyWith<_$GroupInvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
