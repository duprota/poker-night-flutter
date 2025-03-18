// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupActivity _$GroupActivityFromJson(Map<String, dynamic> json) {
  return _GroupActivity.fromJson(json);
}

/// @nodoc
mixin _$GroupActivity {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  GroupActivityType get activityType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GroupActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupActivityCopyWith<GroupActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupActivityCopyWith<$Res> {
  factory $GroupActivityCopyWith(
    GroupActivity value,
    $Res Function(GroupActivity) then,
  ) = _$GroupActivityCopyWithImpl<$Res, GroupActivity>;
  @useResult
  $Res call({
    String id,
    String groupId,
    String? userId,
    GroupActivityType activityType,
    Map<String, dynamic>? details,
    DateTime createdAt,
  });
}

/// @nodoc
class _$GroupActivityCopyWithImpl<$Res, $Val extends GroupActivity>
    implements $GroupActivityCopyWith<$Res> {
  _$GroupActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = freezed,
    Object? activityType = null,
    Object? details = freezed,
    Object? createdAt = null,
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
            userId:
                freezed == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String?,
            activityType:
                null == activityType
                    ? _value.activityType
                    : activityType // ignore: cast_nullable_to_non_nullable
                        as GroupActivityType,
            details:
                freezed == details
                    ? _value.details
                    : details // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupActivityImplCopyWith<$Res>
    implements $GroupActivityCopyWith<$Res> {
  factory _$$GroupActivityImplCopyWith(
    _$GroupActivityImpl value,
    $Res Function(_$GroupActivityImpl) then,
  ) = __$$GroupActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String groupId,
    String? userId,
    GroupActivityType activityType,
    Map<String, dynamic>? details,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$GroupActivityImplCopyWithImpl<$Res>
    extends _$GroupActivityCopyWithImpl<$Res, _$GroupActivityImpl>
    implements _$$GroupActivityImplCopyWith<$Res> {
  __$$GroupActivityImplCopyWithImpl(
    _$GroupActivityImpl _value,
    $Res Function(_$GroupActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = freezed,
    Object? activityType = null,
    Object? details = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$GroupActivityImpl(
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
        userId:
            freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String?,
        activityType:
            null == activityType
                ? _value.activityType
                : activityType // ignore: cast_nullable_to_non_nullable
                    as GroupActivityType,
        details:
            freezed == details
                ? _value._details
                : details // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupActivityImpl
    with DiagnosticableTreeMixin
    implements _GroupActivity {
  const _$GroupActivityImpl({
    required this.id,
    required this.groupId,
    this.userId,
    required this.activityType,
    final Map<String, dynamic>? details,
    required this.createdAt,
  }) : _details = details;

  factory _$GroupActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String? userId;
  @override
  final GroupActivityType activityType;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GroupActivity(id: $id, groupId: $groupId, userId: $userId, activityType: $activityType, details: $details, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GroupActivity'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('groupId', groupId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('activityType', activityType))
      ..add(DiagnosticsProperty('details', details))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    userId,
    activityType,
    const DeepCollectionEquality().hash(_details),
    createdAt,
  );

  /// Create a copy of GroupActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupActivityImplCopyWith<_$GroupActivityImpl> get copyWith =>
      __$$GroupActivityImplCopyWithImpl<_$GroupActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupActivityImplToJson(this);
  }
}

abstract class _GroupActivity implements GroupActivity {
  const factory _GroupActivity({
    required final String id,
    required final String groupId,
    final String? userId,
    required final GroupActivityType activityType,
    final Map<String, dynamic>? details,
    required final DateTime createdAt,
  }) = _$GroupActivityImpl;

  factory _GroupActivity.fromJson(Map<String, dynamic> json) =
      _$GroupActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String? get userId;
  @override
  GroupActivityType get activityType;
  @override
  Map<String, dynamic>? get details;
  @override
  DateTime get createdAt;

  /// Create a copy of GroupActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupActivityImplCopyWith<_$GroupActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
