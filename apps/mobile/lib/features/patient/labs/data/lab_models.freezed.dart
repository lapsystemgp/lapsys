// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PublicLabCard _$PublicLabCardFromJson(Map<String, dynamic> json) {
  return _PublicLabCard.fromJson(json);
}

/// @nodoc
mixin _$PublicLabCard {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get accreditation => throw _privateConstructorUsedError;
  String? get turnaroundTime => throw _privateConstructorUsedError;
  bool get homeCollection => throw _privateConstructorUsedError;
  bool get homeTestKit => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int get reviews => throw _privateConstructorUsedError;
  double? get distanceKm => throw _privateConstructorUsedError;
  int get testsAvailable => throw _privateConstructorUsedError;
  int? get startingFromEgp => throw _privateConstructorUsedError;
  int? get priceForQueryEgp => throw _privateConstructorUsedError;
  String? get imageEmoji => throw _privateConstructorUsedError;

  /// Serializes this PublicLabCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicLabCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicLabCardCopyWith<PublicLabCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicLabCardCopyWith<$Res> {
  factory $PublicLabCardCopyWith(
          PublicLabCard value, $Res Function(PublicLabCard) then) =
      _$PublicLabCardCopyWithImpl<$Res, PublicLabCard>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      String? city,
      String? phone,
      String? contactEmail,
      String? accreditation,
      String? turnaroundTime,
      bool homeCollection,
      bool homeTestKit,
      double? rating,
      int reviews,
      double? distanceKm,
      int testsAvailable,
      int? startingFromEgp,
      int? priceForQueryEgp,
      String? imageEmoji});
}

/// @nodoc
class _$PublicLabCardCopyWithImpl<$Res, $Val extends PublicLabCard>
    implements $PublicLabCardCopyWith<$Res> {
  _$PublicLabCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicLabCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = freezed,
    Object? phone = freezed,
    Object? contactEmail = freezed,
    Object? accreditation = freezed,
    Object? turnaroundTime = freezed,
    Object? homeCollection = null,
    Object? homeTestKit = null,
    Object? rating = freezed,
    Object? reviews = null,
    Object? distanceKm = freezed,
    Object? testsAvailable = null,
    Object? startingFromEgp = freezed,
    Object? priceForQueryEgp = freezed,
    Object? imageEmoji = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      accreditation: freezed == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      homeCollection: null == homeCollection
          ? _value.homeCollection
          : homeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      homeTestKit: null == homeTestKit
          ? _value.homeTestKit
          : homeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as int,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      testsAvailable: null == testsAvailable
          ? _value.testsAvailable
          : testsAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      startingFromEgp: freezed == startingFromEgp
          ? _value.startingFromEgp
          : startingFromEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      priceForQueryEgp: freezed == priceForQueryEgp
          ? _value.priceForQueryEgp
          : priceForQueryEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      imageEmoji: freezed == imageEmoji
          ? _value.imageEmoji
          : imageEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicLabCardImplCopyWith<$Res>
    implements $PublicLabCardCopyWith<$Res> {
  factory _$$PublicLabCardImplCopyWith(
          _$PublicLabCardImpl value, $Res Function(_$PublicLabCardImpl) then) =
      __$$PublicLabCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      String? city,
      String? phone,
      String? contactEmail,
      String? accreditation,
      String? turnaroundTime,
      bool homeCollection,
      bool homeTestKit,
      double? rating,
      int reviews,
      double? distanceKm,
      int testsAvailable,
      int? startingFromEgp,
      int? priceForQueryEgp,
      String? imageEmoji});
}

/// @nodoc
class __$$PublicLabCardImplCopyWithImpl<$Res>
    extends _$PublicLabCardCopyWithImpl<$Res, _$PublicLabCardImpl>
    implements _$$PublicLabCardImplCopyWith<$Res> {
  __$$PublicLabCardImplCopyWithImpl(
      _$PublicLabCardImpl _value, $Res Function(_$PublicLabCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicLabCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = freezed,
    Object? phone = freezed,
    Object? contactEmail = freezed,
    Object? accreditation = freezed,
    Object? turnaroundTime = freezed,
    Object? homeCollection = null,
    Object? homeTestKit = null,
    Object? rating = freezed,
    Object? reviews = null,
    Object? distanceKm = freezed,
    Object? testsAvailable = null,
    Object? startingFromEgp = freezed,
    Object? priceForQueryEgp = freezed,
    Object? imageEmoji = freezed,
  }) {
    return _then(_$PublicLabCardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      accreditation: freezed == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      homeCollection: null == homeCollection
          ? _value.homeCollection
          : homeCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      homeTestKit: null == homeTestKit
          ? _value.homeTestKit
          : homeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as int,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      testsAvailable: null == testsAvailable
          ? _value.testsAvailable
          : testsAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      startingFromEgp: freezed == startingFromEgp
          ? _value.startingFromEgp
          : startingFromEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      priceForQueryEgp: freezed == priceForQueryEgp
          ? _value.priceForQueryEgp
          : priceForQueryEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      imageEmoji: freezed == imageEmoji
          ? _value.imageEmoji
          : imageEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicLabCardImpl implements _PublicLabCard {
  const _$PublicLabCardImpl(
      {required this.id,
      required this.name,
      required this.address,
      this.city,
      this.phone,
      this.contactEmail,
      this.accreditation,
      this.turnaroundTime,
      required this.homeCollection,
      required this.homeTestKit,
      this.rating,
      required this.reviews,
      this.distanceKm,
      required this.testsAvailable,
      this.startingFromEgp,
      this.priceForQueryEgp,
      this.imageEmoji});

  factory _$PublicLabCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicLabCardImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String? city;
  @override
  final String? phone;
  @override
  final String? contactEmail;
  @override
  final String? accreditation;
  @override
  final String? turnaroundTime;
  @override
  final bool homeCollection;
  @override
  final bool homeTestKit;
  @override
  final double? rating;
  @override
  final int reviews;
  @override
  final double? distanceKm;
  @override
  final int testsAvailable;
  @override
  final int? startingFromEgp;
  @override
  final int? priceForQueryEgp;
  @override
  final String? imageEmoji;

  @override
  String toString() {
    return 'PublicLabCard(id: $id, name: $name, address: $address, city: $city, phone: $phone, contactEmail: $contactEmail, accreditation: $accreditation, turnaroundTime: $turnaroundTime, homeCollection: $homeCollection, homeTestKit: $homeTestKit, rating: $rating, reviews: $reviews, distanceKm: $distanceKm, testsAvailable: $testsAvailable, startingFromEgp: $startingFromEgp, priceForQueryEgp: $priceForQueryEgp, imageEmoji: $imageEmoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicLabCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.accreditation, accreditation) ||
                other.accreditation == accreditation) &&
            (identical(other.turnaroundTime, turnaroundTime) ||
                other.turnaroundTime == turnaroundTime) &&
            (identical(other.homeCollection, homeCollection) ||
                other.homeCollection == homeCollection) &&
            (identical(other.homeTestKit, homeTestKit) ||
                other.homeTestKit == homeTestKit) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviews, reviews) || other.reviews == reviews) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.testsAvailable, testsAvailable) ||
                other.testsAvailable == testsAvailable) &&
            (identical(other.startingFromEgp, startingFromEgp) ||
                other.startingFromEgp == startingFromEgp) &&
            (identical(other.priceForQueryEgp, priceForQueryEgp) ||
                other.priceForQueryEgp == priceForQueryEgp) &&
            (identical(other.imageEmoji, imageEmoji) ||
                other.imageEmoji == imageEmoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      address,
      city,
      phone,
      contactEmail,
      accreditation,
      turnaroundTime,
      homeCollection,
      homeTestKit,
      rating,
      reviews,
      distanceKm,
      testsAvailable,
      startingFromEgp,
      priceForQueryEgp,
      imageEmoji);

  /// Create a copy of PublicLabCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicLabCardImplCopyWith<_$PublicLabCardImpl> get copyWith =>
      __$$PublicLabCardImplCopyWithImpl<_$PublicLabCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicLabCardImplToJson(
      this,
    );
  }
}

abstract class _PublicLabCard implements PublicLabCard {
  const factory _PublicLabCard(
      {required final String id,
      required final String name,
      required final String address,
      final String? city,
      final String? phone,
      final String? contactEmail,
      final String? accreditation,
      final String? turnaroundTime,
      required final bool homeCollection,
      required final bool homeTestKit,
      final double? rating,
      required final int reviews,
      final double? distanceKm,
      required final int testsAvailable,
      final int? startingFromEgp,
      final int? priceForQueryEgp,
      final String? imageEmoji}) = _$PublicLabCardImpl;

  factory _PublicLabCard.fromJson(Map<String, dynamic> json) =
      _$PublicLabCardImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  String? get city;
  @override
  String? get phone;
  @override
  String? get contactEmail;
  @override
  String? get accreditation;
  @override
  String? get turnaroundTime;
  @override
  bool get homeCollection;
  @override
  bool get homeTestKit;
  @override
  double? get rating;
  @override
  int get reviews;
  @override
  double? get distanceKm;
  @override
  int get testsAvailable;
  @override
  int? get startingFromEgp;
  @override
  int? get priceForQueryEgp;
  @override
  String? get imageEmoji;

  /// Create a copy of PublicLabCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicLabCardImplCopyWith<_$PublicLabCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PublicLabListResponse _$PublicLabListResponseFromJson(
    Map<String, dynamic> json) {
  return _PublicLabListResponse.fromJson(json);
}

/// @nodoc
mixin _$PublicLabListResponse {
  List<PublicLabCard> get items => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this PublicLabListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicLabListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicLabListResponseCopyWith<PublicLabListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicLabListResponseCopyWith<$Res> {
  factory $PublicLabListResponseCopyWith(PublicLabListResponse value,
          $Res Function(PublicLabListResponse) then) =
      _$PublicLabListResponseCopyWithImpl<$Res, PublicLabListResponse>;
  @useResult
  $Res call({List<PublicLabCard> items, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$PublicLabListResponseCopyWithImpl<$Res,
        $Val extends PublicLabListResponse>
    implements $PublicLabListResponseCopyWith<$Res> {
  _$PublicLabListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicLabListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? pagination = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PublicLabCard>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ) as $Val);
  }

  /// Create a copy of PublicLabListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res> get pagination {
    return $PaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PublicLabListResponseImplCopyWith<$Res>
    implements $PublicLabListResponseCopyWith<$Res> {
  factory _$$PublicLabListResponseImplCopyWith(
          _$PublicLabListResponseImpl value,
          $Res Function(_$PublicLabListResponseImpl) then) =
      __$$PublicLabListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PublicLabCard> items, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$PublicLabListResponseImplCopyWithImpl<$Res>
    extends _$PublicLabListResponseCopyWithImpl<$Res,
        _$PublicLabListResponseImpl>
    implements _$$PublicLabListResponseImplCopyWith<$Res> {
  __$$PublicLabListResponseImplCopyWithImpl(_$PublicLabListResponseImpl _value,
      $Res Function(_$PublicLabListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicLabListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? pagination = null,
  }) {
    return _then(_$PublicLabListResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PublicLabCard>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicLabListResponseImpl implements _PublicLabListResponse {
  const _$PublicLabListResponseImpl(
      {required final List<PublicLabCard> items, required this.pagination})
      : _items = items;

  factory _$PublicLabListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicLabListResponseImplFromJson(json);

  final List<PublicLabCard> _items;
  @override
  List<PublicLabCard> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'PublicLabListResponse(items: $items, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicLabListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), pagination);

  /// Create a copy of PublicLabListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicLabListResponseImplCopyWith<_$PublicLabListResponseImpl>
      get copyWith => __$$PublicLabListResponseImplCopyWithImpl<
          _$PublicLabListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicLabListResponseImplToJson(
      this,
    );
  }
}

abstract class _PublicLabListResponse implements PublicLabListResponse {
  const factory _PublicLabListResponse(
      {required final List<PublicLabCard> items,
      required final Pagination pagination}) = _$PublicLabListResponseImpl;

  factory _PublicLabListResponse.fromJson(Map<String, dynamic> json) =
      _$PublicLabListResponseImpl.fromJson;

  @override
  List<PublicLabCard> get items;
  @override
  Pagination get pagination;

  /// Create a copy of PublicLabListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicLabListResponseImplCopyWith<_$PublicLabListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PublicReview _$PublicReviewFromJson(Map<String, dynamic> json) {
  return _PublicReview.fromJson(json);
}

/// @nodoc
mixin _$PublicReview {
  String get id => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;

  /// Serializes this PublicReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicReviewCopyWith<PublicReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicReviewCopyWith<$Res> {
  factory $PublicReviewCopyWith(
          PublicReview value, $Res Function(PublicReview) then) =
      _$PublicReviewCopyWithImpl<$Res, PublicReview>;
  @useResult
  $Res call(
      {String id,
      int rating,
      String? comment,
      String createdAt,
      String patientName});
}

/// @nodoc
class _$PublicReviewCopyWithImpl<$Res, $Val extends PublicReview>
    implements $PublicReviewCopyWith<$Res> {
  _$PublicReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? patientName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicReviewImplCopyWith<$Res>
    implements $PublicReviewCopyWith<$Res> {
  factory _$$PublicReviewImplCopyWith(
          _$PublicReviewImpl value, $Res Function(_$PublicReviewImpl) then) =
      __$$PublicReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int rating,
      String? comment,
      String createdAt,
      String patientName});
}

/// @nodoc
class __$$PublicReviewImplCopyWithImpl<$Res>
    extends _$PublicReviewCopyWithImpl<$Res, _$PublicReviewImpl>
    implements _$$PublicReviewImplCopyWith<$Res> {
  __$$PublicReviewImplCopyWithImpl(
      _$PublicReviewImpl _value, $Res Function(_$PublicReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? patientName = null,
  }) {
    return _then(_$PublicReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicReviewImpl implements _PublicReview {
  const _$PublicReviewImpl(
      {required this.id,
      required this.rating,
      this.comment,
      required this.createdAt,
      required this.patientName});

  factory _$PublicReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicReviewImplFromJson(json);

  @override
  final String id;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  final String createdAt;
  @override
  final String patientName;

  @override
  String toString() {
    return 'PublicReview(id: $id, rating: $rating, comment: $comment, createdAt: $createdAt, patientName: $patientName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, rating, comment, createdAt, patientName);

  /// Create a copy of PublicReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicReviewImplCopyWith<_$PublicReviewImpl> get copyWith =>
      __$$PublicReviewImplCopyWithImpl<_$PublicReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicReviewImplToJson(
      this,
    );
  }
}

abstract class _PublicReview implements PublicReview {
  const factory _PublicReview(
      {required final String id,
      required final int rating,
      final String? comment,
      required final String createdAt,
      required final String patientName}) = _$PublicReviewImpl;

  factory _PublicReview.fromJson(Map<String, dynamic> json) =
      _$PublicReviewImpl.fromJson;

  @override
  String get id;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  String get createdAt;
  @override
  String get patientName;

  /// Create a copy of PublicReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicReviewImplCopyWith<_$PublicReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PublicLabTest _$PublicLabTestFromJson(Map<String, dynamic> json) {
  return _PublicLabTest.fromJson(json);
}

/// @nodoc
mixin _$PublicLabTest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get preparation => throw _privateConstructorUsedError;
  String? get turnaroundTime => throw _privateConstructorUsedError;
  int? get parametersCount => throw _privateConstructorUsedError;

  /// Serializes this PublicLabTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicLabTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicLabTestCopyWith<PublicLabTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicLabTestCopyWith<$Res> {
  factory $PublicLabTestCopyWith(
          PublicLabTest value, $Res Function(PublicLabTest) then) =
      _$PublicLabTestCopyWithImpl<$Res, PublicLabTest>;
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      int priceEgp,
      String? description,
      String? preparation,
      String? turnaroundTime,
      int? parametersCount});
}

/// @nodoc
class _$PublicLabTestCopyWithImpl<$Res, $Val extends PublicLabTest>
    implements $PublicLabTestCopyWith<$Res> {
  _$PublicLabTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicLabTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? priceEgp = null,
    Object? description = freezed,
    Object? preparation = freezed,
    Object? turnaroundTime = freezed,
    Object? parametersCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      preparation: freezed == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      parametersCount: freezed == parametersCount
          ? _value.parametersCount
          : parametersCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicLabTestImplCopyWith<$Res>
    implements $PublicLabTestCopyWith<$Res> {
  factory _$$PublicLabTestImplCopyWith(
          _$PublicLabTestImpl value, $Res Function(_$PublicLabTestImpl) then) =
      __$$PublicLabTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      int priceEgp,
      String? description,
      String? preparation,
      String? turnaroundTime,
      int? parametersCount});
}

/// @nodoc
class __$$PublicLabTestImplCopyWithImpl<$Res>
    extends _$PublicLabTestCopyWithImpl<$Res, _$PublicLabTestImpl>
    implements _$$PublicLabTestImplCopyWith<$Res> {
  __$$PublicLabTestImplCopyWithImpl(
      _$PublicLabTestImpl _value, $Res Function(_$PublicLabTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicLabTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? priceEgp = null,
    Object? description = freezed,
    Object? preparation = freezed,
    Object? turnaroundTime = freezed,
    Object? parametersCount = freezed,
  }) {
    return _then(_$PublicLabTestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      preparation: freezed == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      parametersCount: freezed == parametersCount
          ? _value.parametersCount
          : parametersCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicLabTestImpl implements _PublicLabTest {
  const _$PublicLabTestImpl(
      {required this.id,
      required this.name,
      required this.category,
      required this.priceEgp,
      this.description,
      this.preparation,
      this.turnaroundTime,
      this.parametersCount});

  factory _$PublicLabTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicLabTestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  @override
  final int priceEgp;
  @override
  final String? description;
  @override
  final String? preparation;
  @override
  final String? turnaroundTime;
  @override
  final int? parametersCount;

  @override
  String toString() {
    return 'PublicLabTest(id: $id, name: $name, category: $category, priceEgp: $priceEgp, description: $description, preparation: $preparation, turnaroundTime: $turnaroundTime, parametersCount: $parametersCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicLabTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.preparation, preparation) ||
                other.preparation == preparation) &&
            (identical(other.turnaroundTime, turnaroundTime) ||
                other.turnaroundTime == turnaroundTime) &&
            (identical(other.parametersCount, parametersCount) ||
                other.parametersCount == parametersCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, category, priceEgp,
      description, preparation, turnaroundTime, parametersCount);

  /// Create a copy of PublicLabTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicLabTestImplCopyWith<_$PublicLabTestImpl> get copyWith =>
      __$$PublicLabTestImplCopyWithImpl<_$PublicLabTestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicLabTestImplToJson(
      this,
    );
  }
}

abstract class _PublicLabTest implements PublicLabTest {
  const factory _PublicLabTest(
      {required final String id,
      required final String name,
      required final String category,
      required final int priceEgp,
      final String? description,
      final String? preparation,
      final String? turnaroundTime,
      final int? parametersCount}) = _$PublicLabTestImpl;

  factory _PublicLabTest.fromJson(Map<String, dynamic> json) =
      _$PublicLabTestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category;
  @override
  int get priceEgp;
  @override
  String? get description;
  @override
  String? get preparation;
  @override
  String? get turnaroundTime;
  @override
  int? get parametersCount;

  /// Create a copy of PublicLabTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicLabTestImplCopyWith<_$PublicLabTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PublicLabDetailResponse _$PublicLabDetailResponseFromJson(
    Map<String, dynamic> json) {
  return _PublicLabDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$PublicLabDetailResponse {
  PublicLabCard get lab => throw _privateConstructorUsedError;
  List<PublicLabTest> get tests => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;
  List<PublicReview> get reviewItems => throw _privateConstructorUsedError;

  /// Serializes this PublicLabDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicLabDetailResponseCopyWith<PublicLabDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicLabDetailResponseCopyWith<$Res> {
  factory $PublicLabDetailResponseCopyWith(PublicLabDetailResponse value,
          $Res Function(PublicLabDetailResponse) then) =
      _$PublicLabDetailResponseCopyWithImpl<$Res, PublicLabDetailResponse>;
  @useResult
  $Res call(
      {PublicLabCard lab,
      List<PublicLabTest> tests,
      Pagination pagination,
      List<PublicReview> reviewItems});

  $PublicLabCardCopyWith<$Res> get lab;
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$PublicLabDetailResponseCopyWithImpl<$Res,
        $Val extends PublicLabDetailResponse>
    implements $PublicLabDetailResponseCopyWith<$Res> {
  _$PublicLabDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lab = null,
    Object? tests = null,
    Object? pagination = null,
    Object? reviewItems = null,
  }) {
    return _then(_value.copyWith(
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as PublicLabCard,
      tests: null == tests
          ? _value.tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<PublicLabTest>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
      reviewItems: null == reviewItems
          ? _value.reviewItems
          : reviewItems // ignore: cast_nullable_to_non_nullable
              as List<PublicReview>,
    ) as $Val);
  }

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublicLabCardCopyWith<$Res> get lab {
    return $PublicLabCardCopyWith<$Res>(_value.lab, (value) {
      return _then(_value.copyWith(lab: value) as $Val);
    });
  }

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res> get pagination {
    return $PaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PublicLabDetailResponseImplCopyWith<$Res>
    implements $PublicLabDetailResponseCopyWith<$Res> {
  factory _$$PublicLabDetailResponseImplCopyWith(
          _$PublicLabDetailResponseImpl value,
          $Res Function(_$PublicLabDetailResponseImpl) then) =
      __$$PublicLabDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PublicLabCard lab,
      List<PublicLabTest> tests,
      Pagination pagination,
      List<PublicReview> reviewItems});

  @override
  $PublicLabCardCopyWith<$Res> get lab;
  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$PublicLabDetailResponseImplCopyWithImpl<$Res>
    extends _$PublicLabDetailResponseCopyWithImpl<$Res,
        _$PublicLabDetailResponseImpl>
    implements _$$PublicLabDetailResponseImplCopyWith<$Res> {
  __$$PublicLabDetailResponseImplCopyWithImpl(
      _$PublicLabDetailResponseImpl _value,
      $Res Function(_$PublicLabDetailResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lab = null,
    Object? tests = null,
    Object? pagination = null,
    Object? reviewItems = null,
  }) {
    return _then(_$PublicLabDetailResponseImpl(
      lab: null == lab
          ? _value.lab
          : lab // ignore: cast_nullable_to_non_nullable
              as PublicLabCard,
      tests: null == tests
          ? _value._tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<PublicLabTest>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
      reviewItems: null == reviewItems
          ? _value._reviewItems
          : reviewItems // ignore: cast_nullable_to_non_nullable
              as List<PublicReview>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicLabDetailResponseImpl implements _PublicLabDetailResponse {
  const _$PublicLabDetailResponseImpl(
      {required this.lab,
      required final List<PublicLabTest> tests,
      required this.pagination,
      required final List<PublicReview> reviewItems})
      : _tests = tests,
        _reviewItems = reviewItems;

  factory _$PublicLabDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicLabDetailResponseImplFromJson(json);

  @override
  final PublicLabCard lab;
  final List<PublicLabTest> _tests;
  @override
  List<PublicLabTest> get tests {
    if (_tests is EqualUnmodifiableListView) return _tests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tests);
  }

  @override
  final Pagination pagination;
  final List<PublicReview> _reviewItems;
  @override
  List<PublicReview> get reviewItems {
    if (_reviewItems is EqualUnmodifiableListView) return _reviewItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviewItems);
  }

  @override
  String toString() {
    return 'PublicLabDetailResponse(lab: $lab, tests: $tests, pagination: $pagination, reviewItems: $reviewItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicLabDetailResponseImpl &&
            (identical(other.lab, lab) || other.lab == lab) &&
            const DeepCollectionEquality().equals(other._tests, _tests) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination) &&
            const DeepCollectionEquality()
                .equals(other._reviewItems, _reviewItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      lab,
      const DeepCollectionEquality().hash(_tests),
      pagination,
      const DeepCollectionEquality().hash(_reviewItems));

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicLabDetailResponseImplCopyWith<_$PublicLabDetailResponseImpl>
      get copyWith => __$$PublicLabDetailResponseImplCopyWithImpl<
          _$PublicLabDetailResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicLabDetailResponseImplToJson(
      this,
    );
  }
}

abstract class _PublicLabDetailResponse implements PublicLabDetailResponse {
  const factory _PublicLabDetailResponse(
          {required final PublicLabCard lab,
          required final List<PublicLabTest> tests,
          required final Pagination pagination,
          required final List<PublicReview> reviewItems}) =
      _$PublicLabDetailResponseImpl;

  factory _PublicLabDetailResponse.fromJson(Map<String, dynamic> json) =
      _$PublicLabDetailResponseImpl.fromJson;

  @override
  PublicLabCard get lab;
  @override
  List<PublicLabTest> get tests;
  @override
  Pagination get pagination;
  @override
  List<PublicReview> get reviewItems;

  /// Create a copy of PublicLabDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicLabDetailResponseImplCopyWith<_$PublicLabDetailResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PublicTestCard _$PublicTestCardFromJson(Map<String, dynamic> json) {
  return _PublicTestCard.fromJson(json);
}

/// @nodoc
mixin _$PublicTestCard {
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int? get minPriceEgp => throw _privateConstructorUsedError;
  int get labCount => throw _privateConstructorUsedError;

  /// Serializes this PublicTestCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicTestCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicTestCardCopyWith<PublicTestCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicTestCardCopyWith<$Res> {
  factory $PublicTestCardCopyWith(
          PublicTestCard value, $Res Function(PublicTestCard) then) =
      _$PublicTestCardCopyWithImpl<$Res, PublicTestCard>;
  @useResult
  $Res call({String name, String category, int? minPriceEgp, int labCount});
}

/// @nodoc
class _$PublicTestCardCopyWithImpl<$Res, $Val extends PublicTestCard>
    implements $PublicTestCardCopyWith<$Res> {
  _$PublicTestCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicTestCard
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
abstract class _$$PublicTestCardImplCopyWith<$Res>
    implements $PublicTestCardCopyWith<$Res> {
  factory _$$PublicTestCardImplCopyWith(_$PublicTestCardImpl value,
          $Res Function(_$PublicTestCardImpl) then) =
      __$$PublicTestCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String category, int? minPriceEgp, int labCount});
}

/// @nodoc
class __$$PublicTestCardImplCopyWithImpl<$Res>
    extends _$PublicTestCardCopyWithImpl<$Res, _$PublicTestCardImpl>
    implements _$$PublicTestCardImplCopyWith<$Res> {
  __$$PublicTestCardImplCopyWithImpl(
      _$PublicTestCardImpl _value, $Res Function(_$PublicTestCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicTestCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? minPriceEgp = freezed,
    Object? labCount = null,
  }) {
    return _then(_$PublicTestCardImpl(
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
class _$PublicTestCardImpl implements _PublicTestCard {
  const _$PublicTestCardImpl(
      {required this.name,
      required this.category,
      this.minPriceEgp,
      required this.labCount});

  factory _$PublicTestCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicTestCardImplFromJson(json);

  @override
  final String name;
  @override
  final String category;
  @override
  final int? minPriceEgp;
  @override
  final int labCount;

  @override
  String toString() {
    return 'PublicTestCard(name: $name, category: $category, minPriceEgp: $minPriceEgp, labCount: $labCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicTestCardImpl &&
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

  /// Create a copy of PublicTestCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicTestCardImplCopyWith<_$PublicTestCardImpl> get copyWith =>
      __$$PublicTestCardImplCopyWithImpl<_$PublicTestCardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicTestCardImplToJson(
      this,
    );
  }
}

abstract class _PublicTestCard implements PublicTestCard {
  const factory _PublicTestCard(
      {required final String name,
      required final String category,
      final int? minPriceEgp,
      required final int labCount}) = _$PublicTestCardImpl;

  factory _PublicTestCard.fromJson(Map<String, dynamic> json) =
      _$PublicTestCardImpl.fromJson;

  @override
  String get name;
  @override
  String get category;
  @override
  int? get minPriceEgp;
  @override
  int get labCount;

  /// Create a copy of PublicTestCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicTestCardImplCopyWith<_$PublicTestCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PublicTestListResponse _$PublicTestListResponseFromJson(
    Map<String, dynamic> json) {
  return _PublicTestListResponse.fromJson(json);
}

/// @nodoc
mixin _$PublicTestListResponse {
  List<PublicTestCard> get items => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this PublicTestListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicTestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicTestListResponseCopyWith<PublicTestListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicTestListResponseCopyWith<$Res> {
  factory $PublicTestListResponseCopyWith(PublicTestListResponse value,
          $Res Function(PublicTestListResponse) then) =
      _$PublicTestListResponseCopyWithImpl<$Res, PublicTestListResponse>;
  @useResult
  $Res call({List<PublicTestCard> items, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$PublicTestListResponseCopyWithImpl<$Res,
        $Val extends PublicTestListResponse>
    implements $PublicTestListResponseCopyWith<$Res> {
  _$PublicTestListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicTestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? pagination = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PublicTestCard>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ) as $Val);
  }

  /// Create a copy of PublicTestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res> get pagination {
    return $PaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PublicTestListResponseImplCopyWith<$Res>
    implements $PublicTestListResponseCopyWith<$Res> {
  factory _$$PublicTestListResponseImplCopyWith(
          _$PublicTestListResponseImpl value,
          $Res Function(_$PublicTestListResponseImpl) then) =
      __$$PublicTestListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PublicTestCard> items, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$PublicTestListResponseImplCopyWithImpl<$Res>
    extends _$PublicTestListResponseCopyWithImpl<$Res,
        _$PublicTestListResponseImpl>
    implements _$$PublicTestListResponseImplCopyWith<$Res> {
  __$$PublicTestListResponseImplCopyWithImpl(
      _$PublicTestListResponseImpl _value,
      $Res Function(_$PublicTestListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicTestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? pagination = null,
  }) {
    return _then(_$PublicTestListResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PublicTestCard>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicTestListResponseImpl implements _PublicTestListResponse {
  const _$PublicTestListResponseImpl(
      {required final List<PublicTestCard> items, required this.pagination})
      : _items = items;

  factory _$PublicTestListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicTestListResponseImplFromJson(json);

  final List<PublicTestCard> _items;
  @override
  List<PublicTestCard> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'PublicTestListResponse(items: $items, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicTestListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), pagination);

  /// Create a copy of PublicTestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicTestListResponseImplCopyWith<_$PublicTestListResponseImpl>
      get copyWith => __$$PublicTestListResponseImplCopyWithImpl<
          _$PublicTestListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicTestListResponseImplToJson(
      this,
    );
  }
}

abstract class _PublicTestListResponse implements PublicTestListResponse {
  const factory _PublicTestListResponse(
      {required final List<PublicTestCard> items,
      required final Pagination pagination}) = _$PublicTestListResponseImpl;

  factory _PublicTestListResponse.fromJson(Map<String, dynamic> json) =
      _$PublicTestListResponseImpl.fromJson;

  @override
  List<PublicTestCard> get items;
  @override
  Pagination get pagination;

  /// Create a copy of PublicTestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicTestListResponseImplCopyWith<_$PublicTestListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TestOfferLab _$TestOfferLabFromJson(Map<String, dynamic> json) {
  return _TestOfferLab.fromJson(json);
}

/// @nodoc
mixin _$TestOfferLab {
  String get labTestId => throw _privateConstructorUsedError;
  String get labId => throw _privateConstructorUsedError;
  String get labName => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  int get priceEgp => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int get reviews => throw _privateConstructorUsedError;
  bool get homeCollection => throw _privateConstructorUsedError;
  bool get homeTestKit => throw _privateConstructorUsedError;
  String? get accreditation => throw _privateConstructorUsedError;
  String? get turnaroundTime => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this TestOfferLab to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestOfferLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestOfferLabCopyWith<TestOfferLab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestOfferLabCopyWith<$Res> {
  factory $TestOfferLabCopyWith(
          TestOfferLab value, $Res Function(TestOfferLab) then) =
      _$TestOfferLabCopyWithImpl<$Res, TestOfferLab>;
  @useResult
  $Res call(
      {String labTestId,
      String labId,
      String labName,
      String address,
      int priceEgp,
      double? rating,
      int reviews,
      bool homeCollection,
      bool homeTestKit,
      String? accreditation,
      String? turnaroundTime,
      double? latitude,
      double? longitude});
}

/// @nodoc
class _$TestOfferLabCopyWithImpl<$Res, $Val extends TestOfferLab>
    implements $TestOfferLabCopyWith<$Res> {
  _$TestOfferLabCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestOfferLab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labTestId = null,
    Object? labId = null,
    Object? labName = null,
    Object? address = null,
    Object? priceEgp = null,
    Object? rating = freezed,
    Object? reviews = null,
    Object? homeCollection = null,
    Object? homeTestKit = null,
    Object? accreditation = freezed,
    Object? turnaroundTime = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_value.copyWith(
      labTestId: null == labTestId
          ? _value.labTestId
          : labTestId // ignore: cast_nullable_to_non_nullable
              as String,
      labId: null == labId
          ? _value.labId
          : labId // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
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
      homeTestKit: null == homeTestKit
          ? _value.homeTestKit
          : homeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
      accreditation: freezed == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestOfferLabImplCopyWith<$Res>
    implements $TestOfferLabCopyWith<$Res> {
  factory _$$TestOfferLabImplCopyWith(
          _$TestOfferLabImpl value, $Res Function(_$TestOfferLabImpl) then) =
      __$$TestOfferLabImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String labTestId,
      String labId,
      String labName,
      String address,
      int priceEgp,
      double? rating,
      int reviews,
      bool homeCollection,
      bool homeTestKit,
      String? accreditation,
      String? turnaroundTime,
      double? latitude,
      double? longitude});
}

/// @nodoc
class __$$TestOfferLabImplCopyWithImpl<$Res>
    extends _$TestOfferLabCopyWithImpl<$Res, _$TestOfferLabImpl>
    implements _$$TestOfferLabImplCopyWith<$Res> {
  __$$TestOfferLabImplCopyWithImpl(
      _$TestOfferLabImpl _value, $Res Function(_$TestOfferLabImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestOfferLab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labTestId = null,
    Object? labId = null,
    Object? labName = null,
    Object? address = null,
    Object? priceEgp = null,
    Object? rating = freezed,
    Object? reviews = null,
    Object? homeCollection = null,
    Object? homeTestKit = null,
    Object? accreditation = freezed,
    Object? turnaroundTime = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_$TestOfferLabImpl(
      labTestId: null == labTestId
          ? _value.labTestId
          : labTestId // ignore: cast_nullable_to_non_nullable
              as String,
      labId: null == labId
          ? _value.labId
          : labId // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      priceEgp: null == priceEgp
          ? _value.priceEgp
          : priceEgp // ignore: cast_nullable_to_non_nullable
              as int,
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
      homeTestKit: null == homeTestKit
          ? _value.homeTestKit
          : homeTestKit // ignore: cast_nullable_to_non_nullable
              as bool,
      accreditation: freezed == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestOfferLabImpl implements _TestOfferLab {
  const _$TestOfferLabImpl(
      {required this.labTestId,
      required this.labId,
      required this.labName,
      required this.address,
      required this.priceEgp,
      this.rating,
      required this.reviews,
      required this.homeCollection,
      required this.homeTestKit,
      this.accreditation,
      this.turnaroundTime,
      this.latitude,
      this.longitude});

  factory _$TestOfferLabImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestOfferLabImplFromJson(json);

  @override
  final String labTestId;
  @override
  final String labId;
  @override
  final String labName;
  @override
  final String address;
  @override
  final int priceEgp;
  @override
  final double? rating;
  @override
  final int reviews;
  @override
  final bool homeCollection;
  @override
  final bool homeTestKit;
  @override
  final String? accreditation;
  @override
  final String? turnaroundTime;
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'TestOfferLab(labTestId: $labTestId, labId: $labId, labName: $labName, address: $address, priceEgp: $priceEgp, rating: $rating, reviews: $reviews, homeCollection: $homeCollection, homeTestKit: $homeTestKit, accreditation: $accreditation, turnaroundTime: $turnaroundTime, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestOfferLabImpl &&
            (identical(other.labTestId, labTestId) ||
                other.labTestId == labTestId) &&
            (identical(other.labId, labId) || other.labId == labId) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.priceEgp, priceEgp) ||
                other.priceEgp == priceEgp) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviews, reviews) || other.reviews == reviews) &&
            (identical(other.homeCollection, homeCollection) ||
                other.homeCollection == homeCollection) &&
            (identical(other.homeTestKit, homeTestKit) ||
                other.homeTestKit == homeTestKit) &&
            (identical(other.accreditation, accreditation) ||
                other.accreditation == accreditation) &&
            (identical(other.turnaroundTime, turnaroundTime) ||
                other.turnaroundTime == turnaroundTime) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      labTestId,
      labId,
      labName,
      address,
      priceEgp,
      rating,
      reviews,
      homeCollection,
      homeTestKit,
      accreditation,
      turnaroundTime,
      latitude,
      longitude);

  /// Create a copy of TestOfferLab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestOfferLabImplCopyWith<_$TestOfferLabImpl> get copyWith =>
      __$$TestOfferLabImplCopyWithImpl<_$TestOfferLabImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestOfferLabImplToJson(
      this,
    );
  }
}

abstract class _TestOfferLab implements TestOfferLab {
  const factory _TestOfferLab(
      {required final String labTestId,
      required final String labId,
      required final String labName,
      required final String address,
      required final int priceEgp,
      final double? rating,
      required final int reviews,
      required final bool homeCollection,
      required final bool homeTestKit,
      final String? accreditation,
      final String? turnaroundTime,
      final double? latitude,
      final double? longitude}) = _$TestOfferLabImpl;

  factory _TestOfferLab.fromJson(Map<String, dynamic> json) =
      _$TestOfferLabImpl.fromJson;

  @override
  String get labTestId;
  @override
  String get labId;
  @override
  String get labName;
  @override
  String get address;
  @override
  int get priceEgp;
  @override
  double? get rating;
  @override
  int get reviews;
  @override
  bool get homeCollection;
  @override
  bool get homeTestKit;
  @override
  String? get accreditation;
  @override
  String? get turnaroundTime;
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of TestOfferLab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestOfferLabImplCopyWith<_$TestOfferLabImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TestOffersResponse _$TestOffersResponseFromJson(Map<String, dynamic> json) {
  return _TestOffersResponse.fromJson(json);
}

/// @nodoc
mixin _$TestOffersResponse {
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get preparation => throw _privateConstructorUsedError;
  String? get turnaroundTime => throw _privateConstructorUsedError;
  int? get parametersCount => throw _privateConstructorUsedError;
  List<TestOfferLab> get labs => throw _privateConstructorUsedError;

  /// Serializes this TestOffersResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestOffersResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestOffersResponseCopyWith<TestOffersResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestOffersResponseCopyWith<$Res> {
  factory $TestOffersResponseCopyWith(
          TestOffersResponse value, $Res Function(TestOffersResponse) then) =
      _$TestOffersResponseCopyWithImpl<$Res, TestOffersResponse>;
  @useResult
  $Res call(
      {String name,
      String category,
      String? description,
      String? preparation,
      String? turnaroundTime,
      int? parametersCount,
      List<TestOfferLab> labs});
}

/// @nodoc
class _$TestOffersResponseCopyWithImpl<$Res, $Val extends TestOffersResponse>
    implements $TestOffersResponseCopyWith<$Res> {
  _$TestOffersResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestOffersResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? description = freezed,
    Object? preparation = freezed,
    Object? turnaroundTime = freezed,
    Object? parametersCount = freezed,
    Object? labs = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      preparation: freezed == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      parametersCount: freezed == parametersCount
          ? _value.parametersCount
          : parametersCount // ignore: cast_nullable_to_non_nullable
              as int?,
      labs: null == labs
          ? _value.labs
          : labs // ignore: cast_nullable_to_non_nullable
              as List<TestOfferLab>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestOffersResponseImplCopyWith<$Res>
    implements $TestOffersResponseCopyWith<$Res> {
  factory _$$TestOffersResponseImplCopyWith(_$TestOffersResponseImpl value,
          $Res Function(_$TestOffersResponseImpl) then) =
      __$$TestOffersResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String category,
      String? description,
      String? preparation,
      String? turnaroundTime,
      int? parametersCount,
      List<TestOfferLab> labs});
}

/// @nodoc
class __$$TestOffersResponseImplCopyWithImpl<$Res>
    extends _$TestOffersResponseCopyWithImpl<$Res, _$TestOffersResponseImpl>
    implements _$$TestOffersResponseImplCopyWith<$Res> {
  __$$TestOffersResponseImplCopyWithImpl(_$TestOffersResponseImpl _value,
      $Res Function(_$TestOffersResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestOffersResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? description = freezed,
    Object? preparation = freezed,
    Object? turnaroundTime = freezed,
    Object? parametersCount = freezed,
    Object? labs = null,
  }) {
    return _then(_$TestOffersResponseImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      preparation: freezed == preparation
          ? _value.preparation
          : preparation // ignore: cast_nullable_to_non_nullable
              as String?,
      turnaroundTime: freezed == turnaroundTime
          ? _value.turnaroundTime
          : turnaroundTime // ignore: cast_nullable_to_non_nullable
              as String?,
      parametersCount: freezed == parametersCount
          ? _value.parametersCount
          : parametersCount // ignore: cast_nullable_to_non_nullable
              as int?,
      labs: null == labs
          ? _value._labs
          : labs // ignore: cast_nullable_to_non_nullable
              as List<TestOfferLab>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestOffersResponseImpl implements _TestOffersResponse {
  const _$TestOffersResponseImpl(
      {required this.name,
      required this.category,
      this.description,
      this.preparation,
      this.turnaroundTime,
      this.parametersCount,
      required final List<TestOfferLab> labs})
      : _labs = labs;

  factory _$TestOffersResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestOffersResponseImplFromJson(json);

  @override
  final String name;
  @override
  final String category;
  @override
  final String? description;
  @override
  final String? preparation;
  @override
  final String? turnaroundTime;
  @override
  final int? parametersCount;
  final List<TestOfferLab> _labs;
  @override
  List<TestOfferLab> get labs {
    if (_labs is EqualUnmodifiableListView) return _labs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labs);
  }

  @override
  String toString() {
    return 'TestOffersResponse(name: $name, category: $category, description: $description, preparation: $preparation, turnaroundTime: $turnaroundTime, parametersCount: $parametersCount, labs: $labs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestOffersResponseImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.preparation, preparation) ||
                other.preparation == preparation) &&
            (identical(other.turnaroundTime, turnaroundTime) ||
                other.turnaroundTime == turnaroundTime) &&
            (identical(other.parametersCount, parametersCount) ||
                other.parametersCount == parametersCount) &&
            const DeepCollectionEquality().equals(other._labs, _labs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      category,
      description,
      preparation,
      turnaroundTime,
      parametersCount,
      const DeepCollectionEquality().hash(_labs));

  /// Create a copy of TestOffersResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestOffersResponseImplCopyWith<_$TestOffersResponseImpl> get copyWith =>
      __$$TestOffersResponseImplCopyWithImpl<_$TestOffersResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestOffersResponseImplToJson(
      this,
    );
  }
}

abstract class _TestOffersResponse implements TestOffersResponse {
  const factory _TestOffersResponse(
      {required final String name,
      required final String category,
      final String? description,
      final String? preparation,
      final String? turnaroundTime,
      final int? parametersCount,
      required final List<TestOfferLab> labs}) = _$TestOffersResponseImpl;

  factory _TestOffersResponse.fromJson(Map<String, dynamic> json) =
      _$TestOffersResponseImpl.fromJson;

  @override
  String get name;
  @override
  String get category;
  @override
  String? get description;
  @override
  String? get preparation;
  @override
  String? get turnaroundTime;
  @override
  int? get parametersCount;
  @override
  List<TestOfferLab> get labs;

  /// Create a copy of TestOffersResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestOffersResponseImplCopyWith<_$TestOffersResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LabsFilter {
  String? get q => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get sort => throw _privateConstructorUsedError;
  int? get maxPriceEgp => throw _privateConstructorUsedError;
  bool get homeCollectionOnly => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  double? get userLat => throw _privateConstructorUsedError;
  double? get userLng => throw _privateConstructorUsedError;

  /// Create a copy of LabsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabsFilterCopyWith<LabsFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabsFilterCopyWith<$Res> {
  factory $LabsFilterCopyWith(
          LabsFilter value, $Res Function(LabsFilter) then) =
      _$LabsFilterCopyWithImpl<$Res, LabsFilter>;
  @useResult
  $Res call(
      {String? q,
      String? city,
      String? sort,
      int? maxPriceEgp,
      bool homeCollectionOnly,
      int page,
      double? userLat,
      double? userLng});
}

/// @nodoc
class _$LabsFilterCopyWithImpl<$Res, $Val extends LabsFilter>
    implements $LabsFilterCopyWith<$Res> {
  _$LabsFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? q = freezed,
    Object? city = freezed,
    Object? sort = freezed,
    Object? maxPriceEgp = freezed,
    Object? homeCollectionOnly = null,
    Object? page = null,
    Object? userLat = freezed,
    Object? userLng = freezed,
  }) {
    return _then(_value.copyWith(
      q: freezed == q
          ? _value.q
          : q // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      sort: freezed == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as String?,
      maxPriceEgp: freezed == maxPriceEgp
          ? _value.maxPriceEgp
          : maxPriceEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      homeCollectionOnly: null == homeCollectionOnly
          ? _value.homeCollectionOnly
          : homeCollectionOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      userLat: freezed == userLat
          ? _value.userLat
          : userLat // ignore: cast_nullable_to_non_nullable
              as double?,
      userLng: freezed == userLng
          ? _value.userLng
          : userLng // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabsFilterImplCopyWith<$Res>
    implements $LabsFilterCopyWith<$Res> {
  factory _$$LabsFilterImplCopyWith(
          _$LabsFilterImpl value, $Res Function(_$LabsFilterImpl) then) =
      __$$LabsFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? q,
      String? city,
      String? sort,
      int? maxPriceEgp,
      bool homeCollectionOnly,
      int page,
      double? userLat,
      double? userLng});
}

/// @nodoc
class __$$LabsFilterImplCopyWithImpl<$Res>
    extends _$LabsFilterCopyWithImpl<$Res, _$LabsFilterImpl>
    implements _$$LabsFilterImplCopyWith<$Res> {
  __$$LabsFilterImplCopyWithImpl(
      _$LabsFilterImpl _value, $Res Function(_$LabsFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? q = freezed,
    Object? city = freezed,
    Object? sort = freezed,
    Object? maxPriceEgp = freezed,
    Object? homeCollectionOnly = null,
    Object? page = null,
    Object? userLat = freezed,
    Object? userLng = freezed,
  }) {
    return _then(_$LabsFilterImpl(
      q: freezed == q
          ? _value.q
          : q // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      sort: freezed == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as String?,
      maxPriceEgp: freezed == maxPriceEgp
          ? _value.maxPriceEgp
          : maxPriceEgp // ignore: cast_nullable_to_non_nullable
              as int?,
      homeCollectionOnly: null == homeCollectionOnly
          ? _value.homeCollectionOnly
          : homeCollectionOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      userLat: freezed == userLat
          ? _value.userLat
          : userLat // ignore: cast_nullable_to_non_nullable
              as double?,
      userLng: freezed == userLng
          ? _value.userLng
          : userLng // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$LabsFilterImpl implements _LabsFilter {
  const _$LabsFilterImpl(
      {this.q,
      this.city,
      this.sort,
      this.maxPriceEgp,
      this.homeCollectionOnly = false,
      this.page = 1,
      this.userLat,
      this.userLng});

  @override
  final String? q;
  @override
  final String? city;
  @override
  final String? sort;
  @override
  final int? maxPriceEgp;
  @override
  @JsonKey()
  final bool homeCollectionOnly;
  @override
  @JsonKey()
  final int page;
  @override
  final double? userLat;
  @override
  final double? userLng;

  @override
  String toString() {
    return 'LabsFilter(q: $q, city: $city, sort: $sort, maxPriceEgp: $maxPriceEgp, homeCollectionOnly: $homeCollectionOnly, page: $page, userLat: $userLat, userLng: $userLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabsFilterImpl &&
            (identical(other.q, q) || other.q == q) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.maxPriceEgp, maxPriceEgp) ||
                other.maxPriceEgp == maxPriceEgp) &&
            (identical(other.homeCollectionOnly, homeCollectionOnly) ||
                other.homeCollectionOnly == homeCollectionOnly) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.userLat, userLat) || other.userLat == userLat) &&
            (identical(other.userLng, userLng) || other.userLng == userLng));
  }

  @override
  int get hashCode => Object.hash(runtimeType, q, city, sort, maxPriceEgp,
      homeCollectionOnly, page, userLat, userLng);

  /// Create a copy of LabsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabsFilterImplCopyWith<_$LabsFilterImpl> get copyWith =>
      __$$LabsFilterImplCopyWithImpl<_$LabsFilterImpl>(this, _$identity);
}

abstract class _LabsFilter implements LabsFilter {
  const factory _LabsFilter(
      {final String? q,
      final String? city,
      final String? sort,
      final int? maxPriceEgp,
      final bool homeCollectionOnly,
      final int page,
      final double? userLat,
      final double? userLng}) = _$LabsFilterImpl;

  @override
  String? get q;
  @override
  String? get city;
  @override
  String? get sort;
  @override
  int? get maxPriceEgp;
  @override
  bool get homeCollectionOnly;
  @override
  int get page;
  @override
  double? get userLat;
  @override
  double? get userLng;

  /// Create a copy of LabsFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabsFilterImplCopyWith<_$LabsFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
