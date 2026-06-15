// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AssistantConversation _$AssistantConversationFromJson(
    Map<String, dynamic> json) {
  return _AssistantConversation.fromJson(json);
}

/// @nodoc
mixin _$AssistantConversation {
  String get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AssistantConversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantConversationCopyWith<AssistantConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantConversationCopyWith<$Res> {
  factory $AssistantConversationCopyWith(AssistantConversation value,
          $Res Function(AssistantConversation) then) =
      _$AssistantConversationCopyWithImpl<$Res, AssistantConversation>;
  @useResult
  $Res call({String id, String? title, String updatedAt});
}

/// @nodoc
class _$AssistantConversationCopyWithImpl<$Res,
        $Val extends AssistantConversation>
    implements $AssistantConversationCopyWith<$Res> {
  _$AssistantConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssistantConversationImplCopyWith<$Res>
    implements $AssistantConversationCopyWith<$Res> {
  factory _$$AssistantConversationImplCopyWith(
          _$AssistantConversationImpl value,
          $Res Function(_$AssistantConversationImpl) then) =
      __$$AssistantConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? title, String updatedAt});
}

/// @nodoc
class __$$AssistantConversationImplCopyWithImpl<$Res>
    extends _$AssistantConversationCopyWithImpl<$Res,
        _$AssistantConversationImpl>
    implements _$$AssistantConversationImplCopyWith<$Res> {
  __$$AssistantConversationImplCopyWithImpl(_$AssistantConversationImpl _value,
      $Res Function(_$AssistantConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_$AssistantConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantConversationImpl implements _AssistantConversation {
  const _$AssistantConversationImpl(
      {required this.id, this.title, required this.updatedAt});

  factory _$AssistantConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String? title;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'AssistantConversation(id: $id, title: $title, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, updatedAt);

  /// Create a copy of AssistantConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantConversationImplCopyWith<_$AssistantConversationImpl>
      get copyWith => __$$AssistantConversationImplCopyWithImpl<
          _$AssistantConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantConversationImplToJson(
      this,
    );
  }
}

abstract class _AssistantConversation implements AssistantConversation {
  const factory _AssistantConversation(
      {required final String id,
      final String? title,
      required final String updatedAt}) = _$AssistantConversationImpl;

  factory _AssistantConversation.fromJson(Map<String, dynamic> json) =
      _$AssistantConversationImpl.fromJson;

  @override
  String get id;
  @override
  String? get title;
  @override
  String get updatedAt;

  /// Create a copy of AssistantConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantConversationImplCopyWith<_$AssistantConversationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AssistantMessage _$AssistantMessageFromJson(Map<String, dynamic> json) {
  return _AssistantMessage.fromJson(json);
}

/// @nodoc
mixin _$AssistantMessage {
  String get id => throw _privateConstructorUsedError;
  ChatRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get createdAt =>
      throw _privateConstructorUsedError; // True while the assistant reply is still streaming in.
  bool get isStreaming => throw _privateConstructorUsedError;

  /// Serializes this AssistantMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantMessageCopyWith<AssistantMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantMessageCopyWith<$Res> {
  factory $AssistantMessageCopyWith(
          AssistantMessage value, $Res Function(AssistantMessage) then) =
      _$AssistantMessageCopyWithImpl<$Res, AssistantMessage>;
  @useResult
  $Res call(
      {String id,
      ChatRole role,
      String content,
      String? createdAt,
      bool isStreaming});
}

/// @nodoc
class _$AssistantMessageCopyWithImpl<$Res, $Val extends AssistantMessage>
    implements $AssistantMessageCopyWith<$Res> {
  _$AssistantMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = freezed,
    Object? isStreaming = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as ChatRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssistantMessageImplCopyWith<$Res>
    implements $AssistantMessageCopyWith<$Res> {
  factory _$$AssistantMessageImplCopyWith(_$AssistantMessageImpl value,
          $Res Function(_$AssistantMessageImpl) then) =
      __$$AssistantMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ChatRole role,
      String content,
      String? createdAt,
      bool isStreaming});
}

/// @nodoc
class __$$AssistantMessageImplCopyWithImpl<$Res>
    extends _$AssistantMessageCopyWithImpl<$Res, _$AssistantMessageImpl>
    implements _$$AssistantMessageImplCopyWith<$Res> {
  __$$AssistantMessageImplCopyWithImpl(_$AssistantMessageImpl _value,
      $Res Function(_$AssistantMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = freezed,
    Object? isStreaming = null,
  }) {
    return _then(_$AssistantMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as ChatRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantMessageImpl implements _AssistantMessage {
  const _$AssistantMessageImpl(
      {required this.id,
      required this.role,
      required this.content,
      this.createdAt,
      this.isStreaming = false});

  factory _$AssistantMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantMessageImplFromJson(json);

  @override
  final String id;
  @override
  final ChatRole role;
  @override
  final String content;
  @override
  final String? createdAt;
// True while the assistant reply is still streaming in.
  @override
  @JsonKey()
  final bool isStreaming;

  @override
  String toString() {
    return 'AssistantMessage(id: $id, role: $role, content: $content, createdAt: $createdAt, isStreaming: $isStreaming)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, role, content, createdAt, isStreaming);

  /// Create a copy of AssistantMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantMessageImplCopyWith<_$AssistantMessageImpl> get copyWith =>
      __$$AssistantMessageImplCopyWithImpl<_$AssistantMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantMessageImplToJson(
      this,
    );
  }
}

abstract class _AssistantMessage implements AssistantMessage {
  const factory _AssistantMessage(
      {required final String id,
      required final ChatRole role,
      required final String content,
      final String? createdAt,
      final bool isStreaming}) = _$AssistantMessageImpl;

  factory _AssistantMessage.fromJson(Map<String, dynamic> json) =
      _$AssistantMessageImpl.fromJson;

  @override
  String get id;
  @override
  ChatRole get role;
  @override
  String get content;
  @override
  String?
      get createdAt; // True while the assistant reply is still streaming in.
  @override
  bool get isStreaming;

  /// Create a copy of AssistantMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantMessageImplCopyWith<_$AssistantMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
