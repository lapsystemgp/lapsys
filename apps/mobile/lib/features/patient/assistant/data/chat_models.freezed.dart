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
  String get content =>
      throw _privateConstructorUsedError; // Structured agentic cards (real labs/tests) the assistant surfaced.
  List<ToolResult> get tools => throw _privateConstructorUsedError;
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
      List<ToolResult> tools,
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
    Object? tools = null,
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
      tools: null == tools
          ? _value.tools
          : tools // ignore: cast_nullable_to_non_nullable
              as List<ToolResult>,
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
      List<ToolResult> tools,
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
    Object? tools = null,
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
      tools: null == tools
          ? _value._tools
          : tools // ignore: cast_nullable_to_non_nullable
              as List<ToolResult>,
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
      final List<ToolResult> tools = const <ToolResult>[],
      this.createdAt,
      this.isStreaming = false})
      : _tools = tools;

  factory _$AssistantMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantMessageImplFromJson(json);

  @override
  final String id;
  @override
  final ChatRole role;
  @override
  final String content;
// Structured agentic cards (real labs/tests) the assistant surfaced.
  final List<ToolResult> _tools;
// Structured agentic cards (real labs/tests) the assistant surfaced.
  @override
  @JsonKey()
  List<ToolResult> get tools {
    if (_tools is EqualUnmodifiableListView) return _tools;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tools);
  }

  @override
  final String? createdAt;
// True while the assistant reply is still streaming in.
  @override
  @JsonKey()
  final bool isStreaming;

  @override
  String toString() {
    return 'AssistantMessage(id: $id, role: $role, content: $content, tools: $tools, createdAt: $createdAt, isStreaming: $isStreaming)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._tools, _tools) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, role, content,
      const DeepCollectionEquality().hash(_tools), createdAt, isStreaming);

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
      final List<ToolResult> tools,
      final String? createdAt,
      final bool isStreaming}) = _$AssistantMessageImpl;

  factory _AssistantMessage.fromJson(Map<String, dynamic> json) =
      _$AssistantMessageImpl.fromJson;

  @override
  String get id;
  @override
  ChatRole get role;
  @override
  String
      get content; // Structured agentic cards (real labs/tests) the assistant surfaced.
  @override
  List<ToolResult> get tools;
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

AssistantLabCard _$AssistantLabCardFromJson(Map<String, dynamic> json) {
  return _AssistantLabCard.fromJson(json);
}

/// @nodoc
mixin _$AssistantLabCard {
  String get labId => throw _privateConstructorUsedError;
  String? get labTestId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  int? get priceEgp => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int get reviews => throw _privateConstructorUsedError;
  bool get homeCollection => throw _privateConstructorUsedError;
  String? get accreditation => throw _privateConstructorUsedError;
  String? get turnaroundTime => throw _privateConstructorUsedError;

  /// Serializes this AssistantLabCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantLabCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantLabCardCopyWith<AssistantLabCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantLabCardCopyWith<$Res> {
  factory $AssistantLabCardCopyWith(
          AssistantLabCard value, $Res Function(AssistantLabCard) then) =
      _$AssistantLabCardCopyWithImpl<$Res, AssistantLabCard>;
  @useResult
  $Res call(
      {String labId,
      String? labTestId,
      String name,
      String address,
      String? city,
      int? priceEgp,
      double? rating,
      int reviews,
      bool homeCollection,
      String? accreditation,
      String? turnaroundTime});
}

/// @nodoc
class _$AssistantLabCardCopyWithImpl<$Res, $Val extends AssistantLabCard>
    implements $AssistantLabCardCopyWith<$Res> {
  _$AssistantLabCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantLabCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labId = null,
    Object? labTestId = freezed,
    Object? name = null,
    Object? address = null,
    Object? city = freezed,
    Object? priceEgp = freezed,
    Object? rating = freezed,
    Object? reviews = null,
    Object? homeCollection = null,
    Object? accreditation = freezed,
    Object? turnaroundTime = freezed,
  }) {
    return _then(_value.copyWith(
      labId: null == labId
          ? _value.labId
          : labId // ignore: cast_nullable_to_non_nullable
              as String,
      labTestId: freezed == labTestId
          ? _value.labTestId
          : labTestId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      priceEgp: freezed == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as int,
      homeCollection: null == homeCollection
          ? _value.homeCollection
          : homeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      accreditation: freezed == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssistantLabCardImplCopyWith<$Res>
    implements $AssistantLabCardCopyWith<$Res> {
  factory _$$AssistantLabCardImplCopyWith(_$AssistantLabCardImpl value,
          $Res Function(_$AssistantLabCardImpl) then) =
      __$$AssistantLabCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String labId,
      String? labTestId,
      String name,
      String address,
      String? city,
      int? priceEgp,
      double? rating,
      int reviews,
      bool homeCollection,
      String? accreditation,
      String? turnaroundTime});
}

/// @nodoc
class __$$AssistantLabCardImplCopyWithImpl<$Res>
    extends _$AssistantLabCardCopyWithImpl<$Res, _$AssistantLabCardImpl>
    implements _$$AssistantLabCardImplCopyWith<$Res> {
  __$$AssistantLabCardImplCopyWithImpl(_$AssistantLabCardImpl _value,
      $Res Function(_$AssistantLabCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantLabCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labId = null,
    Object? labTestId = freezed,
    Object? name = null,
    Object? address = null,
    Object? city = freezed,
    Object? priceEgp = freezed,
    Object? rating = freezed,
    Object? reviews = null,
    Object? homeCollection = null,
    Object? accreditation = freezed,
    Object? turnaroundTime = freezed,
  }) {
    return _then(_$AssistantLabCardImpl(
      labId: null == labId
          ? _value.labId
          : labId // ignore: cast_nullable_to_non_nullable
              as String,
      labTestId: freezed == labTestId
          ? _value.labTestId
          : labTestId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      priceEgp: freezed == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as int,
      homeCollection: null == homeCollection
          ? _value.homeCollection
          : homeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      accreditation: freezed == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantLabCardImpl implements _AssistantLabCard {
  const _$AssistantLabCardImpl(
      {required this.labId,
      this.labTestId,
      required this.name,
      required this.address,
      this.city,
      this.priceEgp,
      this.rating,
      this.reviews = 0,
      this.homeCollection = false,
      this.accreditation,
      this.turnaroundTime});

  factory _$AssistantLabCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantLabCardImplFromJson(json);

  @override
  final String labId;
  @override
  final String? labTestId;
  @override
  final String name;
  @override
  final String address;
  @override
  final String? city;
  @override
  final int? priceEgp;
  @override
  final double? rating;
  @override
  @JsonKey()
  final int reviews;
  @override
  @JsonKey()
  final bool homeCollection;
  @override
  final String? accreditation;
  @override
  final String? turnaroundTime;

  @override
  String toString() {
    return 'AssistantLabCard(labId: $labId, labTestId: $labTestId, name: $name, address: $address, city: $city, priceEgp: $priceEgp, rating: $rating, reviews: $reviews, homeCollection: $homeCollection, accreditation: $accreditation, turnaroundTime: $turnaroundTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantLabCardImpl &&
            (identical(other.labId, labId) || other.labId == labId) &&
            (identical(other.labTestId, labTestId) ||
                other.labTestId == labTestId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviews, reviews) || other.reviews == reviews) &&
            (identical(other.homeCollection, homeCollection) ||
                other.homeCollection == homeCollection) &&
            (identical(other.accreditation, accreditation) ||
                other.accreditation == accreditation) &&
            (identical(other.turnaroundTime, turnaroundTime) ||
                other.turnaroundTime == turnaroundTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      labId,
      labTestId,
      name,
      address,
      city,
      priceEgp,
      rating,
      reviews,
      homeCollection,
      accreditation,
      turnaroundTime);

  /// Create a copy of AssistantLabCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantLabCardImplCopyWith<_$AssistantLabCardImpl> get copyWith =>
      __$$AssistantLabCardImplCopyWithImpl<_$AssistantLabCardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantLabCardImplToJson(
      this,
    );
  }
}

abstract class _AssistantLabCard implements AssistantLabCard {
  const factory _AssistantLabCard(
      {required final String labId,
      final String? labTestId,
      required final String name,
      required final String address,
      final String? city,
      final int? priceEgp,
      final double? rating,
      final int reviews,
      final bool homeCollection,
      final String? accreditation,
      final String? turnaroundTime}) = _$AssistantLabCardImpl;

  factory _AssistantLabCard.fromJson(Map<String, dynamic> json) =
      _$AssistantLabCardImpl.fromJson;

  @override
  String get labId;
  @override
  String? get labTestId;
  @override
  String get name;
  @override
  String get address;
  @override
  String? get city;
  @override
  int? get priceEgp;
  @override
  double? get rating;
  @override
  int get reviews;
  @override
  bool get homeCollection;
  @override
  String? get accreditation;
  @override
  String? get turnaroundTime;

  /// Create a copy of AssistantLabCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantLabCardImplCopyWith<_$AssistantLabCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssistantTestCard _$AssistantTestCardFromJson(Map<String, dynamic> json) {
  return _AssistantTestCard.fromJson(json);
}

/// @nodoc
mixin _$AssistantTestCard {
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int? get minPriceEgp => throw _privateConstructorUsedError;
  int get labCount => throw _privateConstructorUsedError;

  /// Serializes this AssistantTestCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantTestCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantTestCardCopyWith<AssistantTestCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantTestCardCopyWith<$Res> {
  factory $AssistantTestCardCopyWith(
          AssistantTestCard value, $Res Function(AssistantTestCard) then) =
      _$AssistantTestCardCopyWithImpl<$Res, AssistantTestCard>;
  @useResult
  $Res call({String name, String category, int? minPriceEgp, int labCount});
}

/// @nodoc
class _$AssistantTestCardCopyWithImpl<$Res, $Val extends AssistantTestCard>
    implements $AssistantTestCardCopyWith<$Res> {
  _$AssistantTestCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantTestCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? minPriceEgp = freezed,
    Object? labCount = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      minPriceEgp: freezed == minPriceEgp
          ? _value.minPriceEgp
          : minPriceEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      labCount: null == labCount
          ? _value.labCount
          : labCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssistantTestCardImplCopyWith<$Res>
    implements $AssistantTestCardCopyWith<$Res> {
  factory _$$AssistantTestCardImplCopyWith(_$AssistantTestCardImpl value,
          $Res Function(_$AssistantTestCardImpl) then) =
      __$$AssistantTestCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String category, int? minPriceEgp, int labCount});
}

/// @nodoc
class __$$AssistantTestCardImplCopyWithImpl<$Res>
    extends _$AssistantTestCardCopyWithImpl<$Res, _$AssistantTestCardImpl>
    implements _$$AssistantTestCardImplCopyWith<$Res> {
  __$$AssistantTestCardImplCopyWithImpl(_$AssistantTestCardImpl _value,
      $Res Function(_$AssistantTestCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantTestCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? minPriceEgp = freezed,
    Object? labCount = null,
  }) {
    return _then(_$AssistantTestCardImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      minPriceEgp: freezed == minPriceEgp
          ? _value.minPriceEgp
          : minPriceEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      labCount: null == labCount
          ? _value.labCount
          : labCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantTestCardImpl implements _AssistantTestCard {
  const _$AssistantTestCardImpl(
      {required this.name,
      required this.category,
      this.minPriceEgp,
      this.labCount = 0});

  factory _$AssistantTestCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantTestCardImplFromJson(json);

  @override
  final String name;
  @override
  final String category;
  @override
  final int? minPriceEgp;
  @override
  @JsonKey()
  final int labCount;

  @override
  String toString() {
    return 'AssistantTestCard(name: $name, category: $category, minPriceEgp: $minPriceEgp, labCount: $labCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantTestCardImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.minPriceEgp, minPriceEgp) ||
                other.minPriceEgp == minPriceEgp) &&
            (identical(other.labCount, labCount) ||
                other.labCount == labCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, category, minPriceEgp, labCount);

  /// Create a copy of AssistantTestCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantTestCardImplCopyWith<_$AssistantTestCardImpl> get copyWith =>
      __$$AssistantTestCardImplCopyWithImpl<_$AssistantTestCardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantTestCardImplToJson(
      this,
    );
  }
}

abstract class _AssistantTestCard implements AssistantTestCard {
  const factory _AssistantTestCard(
      {required final String name,
      required final String category,
      final int? minPriceEgp,
      final int labCount}) = _$AssistantTestCardImpl;

  factory _AssistantTestCard.fromJson(Map<String, dynamic> json) =
      _$AssistantTestCardImpl.fromJson;

  @override
  String get name;
  @override
  String get category;
  @override
  int? get minPriceEgp;
  @override
  int get labCount;

  /// Create a copy of AssistantTestCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantTestCardImplCopyWith<_$AssistantTestCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ToolResult _$ToolResultFromJson(Map<String, dynamic> json) {
  return _ToolResult.fromJson(json);
}

/// @nodoc
mixin _$ToolResult {
  String get tool => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  List<AssistantLabCard> get labs => throw _privateConstructorUsedError;
  List<AssistantTestCard> get tests => throw _privateConstructorUsedError;

  /// Serializes this ToolResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolResultCopyWith<ToolResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolResultCopyWith<$Res> {
  factory $ToolResultCopyWith(
          ToolResult value, $Res Function(ToolResult) then) =
      _$ToolResultCopyWithImpl<$Res, ToolResult>;
  @useResult
  $Res call(
      {String tool,
      String query,
      List<AssistantLabCard> labs,
      List<AssistantTestCard> tests});
}

/// @nodoc
class _$ToolResultCopyWithImpl<$Res, $Val extends ToolResult>
    implements $ToolResultCopyWith<$Res> {
  _$ToolResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tool = null,
    Object? query = null,
    Object? labs = null,
    Object? tests = null,
  }) {
    return _then(_value.copyWith(
      tool: null == tool
          ? _value.tool
          : tool // ignore: cast_nullable_to_non_nullable
              as String,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      labs: null == labs
          ? _value.labs
          : labs // ignore: cast_nullable_to_non_nullable
              as List<AssistantLabCard>,
      tests: null == tests
          ? _value.tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<AssistantTestCard>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToolResultImplCopyWith<$Res>
    implements $ToolResultCopyWith<$Res> {
  factory _$$ToolResultImplCopyWith(
          _$ToolResultImpl value, $Res Function(_$ToolResultImpl) then) =
      __$$ToolResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tool,
      String query,
      List<AssistantLabCard> labs,
      List<AssistantTestCard> tests});
}

/// @nodoc
class __$$ToolResultImplCopyWithImpl<$Res>
    extends _$ToolResultCopyWithImpl<$Res, _$ToolResultImpl>
    implements _$$ToolResultImplCopyWith<$Res> {
  __$$ToolResultImplCopyWithImpl(
      _$ToolResultImpl _value, $Res Function(_$ToolResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToolResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tool = null,
    Object? query = null,
    Object? labs = null,
    Object? tests = null,
  }) {
    return _then(_$ToolResultImpl(
      tool: null == tool
          ? _value.tool
          : tool // ignore: cast_nullable_to_non_nullable
              as String,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      labs: null == labs
          ? _value._labs
          : labs // ignore: cast_nullable_to_non_nullable
              as List<AssistantLabCard>,
      tests: null == tests
          ? _value._tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<AssistantTestCard>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolResultImpl implements _ToolResult {
  const _$ToolResultImpl(
      {required this.tool,
      this.query = '',
      final List<AssistantLabCard> labs = const <AssistantLabCard>[],
      final List<AssistantTestCard> tests = const <AssistantTestCard>[]})
      : _labs = labs,
        _tests = tests;

  factory _$ToolResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolResultImplFromJson(json);

  @override
  final String tool;
  @override
  @JsonKey()
  final String query;
  final List<AssistantLabCard> _labs;
  @override
  @JsonKey()
  List<AssistantLabCard> get labs {
    if (_labs is EqualUnmodifiableListView) return _labs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labs);
  }

  final List<AssistantTestCard> _tests;
  @override
  @JsonKey()
  List<AssistantTestCard> get tests {
    if (_tests is EqualUnmodifiableListView) return _tests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tests);
  }

  @override
  String toString() {
    return 'ToolResult(tool: $tool, query: $query, labs: $labs, tests: $tests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolResultImpl &&
            (identical(other.tool, tool) || other.tool == tool) &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._labs, _labs) &&
            const DeepCollectionEquality().equals(other._tests, _tests));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tool,
      query,
      const DeepCollectionEquality().hash(_labs),
      const DeepCollectionEquality().hash(_tests));

  /// Create a copy of ToolResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolResultImplCopyWith<_$ToolResultImpl> get copyWith =>
      __$$ToolResultImplCopyWithImpl<_$ToolResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolResultImplToJson(
      this,
    );
  }
}

abstract class _ToolResult implements ToolResult {
  const factory _ToolResult(
      {required final String tool,
      final String query,
      final List<AssistantLabCard> labs,
      final List<AssistantTestCard> tests}) = _$ToolResultImpl;

  factory _ToolResult.fromJson(Map<String, dynamic> json) =
      _$ToolResultImpl.fromJson;

  @override
  String get tool;
  @override
  String get query;
  @override
  List<AssistantLabCard> get labs;
  @override
  List<AssistantTestCard> get tests;

  /// Create a copy of ToolResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolResultImplCopyWith<_$ToolResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
