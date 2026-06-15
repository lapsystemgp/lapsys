// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PublicLabCardImpl _$$PublicLabCardImplFromJson(Map<String, dynamic> json) =>
    _$PublicLabCardImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      accreditation: json['accreditation'] as String?,
      turnaroundTime: json['turnaroundTime'] as String?,
      homeCollection: json['homeCollection'] as bool,
      homeTestKit: json['homeTestKit'] as bool,
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: (json['reviews'] as num).toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      testsAvailable: (json['testsAvailable'] as num).toInt(),
      startingFromEgp: (json['startingFromEgp'] as num?)?.toInt(),
      priceForQueryEgp: (json['priceForQueryEgp'] as num?)?.toInt(),
      imageEmoji: json['imageEmoji'] as String?,
    );

Map<String, dynamic> _$$PublicLabCardImplToJson(_$PublicLabCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'phone': instance.phone,
      'contactEmail': instance.contactEmail,
      'accreditation': instance.accreditation,
      'turnaroundTime': instance.turnaroundTime,
      'homeCollection': instance.homeCollection,
      'homeTestKit': instance.homeTestKit,
      'rating': instance.rating,
      'reviews': instance.reviews,
      'distanceKm': instance.distanceKm,
      'testsAvailable': instance.testsAvailable,
      'startingFromEgp': instance.startingFromEgp,
      'priceForQueryEgp': instance.priceForQueryEgp,
      'imageEmoji': instance.imageEmoji,
    };

_$PublicLabListResponseImpl _$$PublicLabListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PublicLabListResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => PublicLabCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PublicLabListResponseImplToJson(
        _$PublicLabListResponseImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

_$PublicReviewImpl _$$PublicReviewImplFromJson(Map<String, dynamic> json) =>
    _$PublicReviewImpl(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String,
      patientName: json['patientName'] as String,
    );

Map<String, dynamic> _$$PublicReviewImplToJson(_$PublicReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt,
      'patientName': instance.patientName,
    };

_$PublicLabTestImpl _$$PublicLabTestImplFromJson(Map<String, dynamic> json) =>
    _$PublicLabTestImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      priceEgp: (json['priceEgp'] as num).toInt(),
      description: json['description'] as String?,
      preparation: json['preparation'] as String?,
      turnaroundTime: json['turnaroundTime'] as String?,
      parametersCount: (json['parametersCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PublicLabTestImplToJson(_$PublicLabTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'priceEgp': instance.priceEgp,
      'description': instance.description,
      'preparation': instance.preparation,
      'turnaroundTime': instance.turnaroundTime,
      'parametersCount': instance.parametersCount,
    };

_$PublicLabDetailResponseImpl _$$PublicLabDetailResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PublicLabDetailResponseImpl(
      lab: PublicLabCard.fromJson(json['lab'] as Map<String, dynamic>),
      tests: (json['tests'] as List<dynamic>)
          .map((e) => PublicLabTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      reviewItems: (json['reviewItems'] as List<dynamic>)
          .map((e) => PublicReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PublicLabDetailResponseImplToJson(
        _$PublicLabDetailResponseImpl instance) =>
    <String, dynamic>{
      'lab': instance.lab,
      'tests': instance.tests,
      'pagination': instance.pagination,
      'reviewItems': instance.reviewItems,
    };

_$PublicTestCardImpl _$$PublicTestCardImplFromJson(Map<String, dynamic> json) =>
    _$PublicTestCardImpl(
      name: json['name'] as String,
      category: json['category'] as String,
      minPriceEgp: (json['minPriceEgp'] as num?)?.toInt(),
      labCount: (json['labCount'] as num).toInt(),
    );

Map<String, dynamic> _$$PublicTestCardImplToJson(
        _$PublicTestCardImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'minPriceEgp': instance.minPriceEgp,
      'labCount': instance.labCount,
    };

_$PublicTestListResponseImpl _$$PublicTestListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PublicTestListResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => PublicTestCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PublicTestListResponseImplToJson(
        _$PublicTestListResponseImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

_$TestOfferLabImpl _$$TestOfferLabImplFromJson(Map<String, dynamic> json) =>
    _$TestOfferLabImpl(
      labTestId: json['labTestId'] as String,
      labId: json['labId'] as String,
      labName: json['labName'] as String,
      address: json['address'] as String,
      priceEgp: (json['priceEgp'] as num).toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: (json['reviews'] as num).toInt(),
      homeCollection: json['homeCollection'] as bool,
      homeTestKit: json['homeTestKit'] as bool,
      accreditation: json['accreditation'] as String?,
      turnaroundTime: json['turnaroundTime'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TestOfferLabImplToJson(_$TestOfferLabImpl instance) =>
    <String, dynamic>{
      'labTestId': instance.labTestId,
      'labId': instance.labId,
      'labName': instance.labName,
      'address': instance.address,
      'priceEgp': instance.priceEgp,
      'rating': instance.rating,
      'reviews': instance.reviews,
      'homeCollection': instance.homeCollection,
      'homeTestKit': instance.homeTestKit,
      'accreditation': instance.accreditation,
      'turnaroundTime': instance.turnaroundTime,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$TestOffersResponseImpl _$$TestOffersResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TestOffersResponseImpl(
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      preparation: json['preparation'] as String?,
      turnaroundTime: json['turnaroundTime'] as String?,
      parametersCount: (json['parametersCount'] as num?)?.toInt(),
      labs: (json['labs'] as List<dynamic>)
          .map((e) => TestOfferLab.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TestOffersResponseImplToJson(
        _$TestOffersResponseImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'preparation': instance.preparation,
      'turnaroundTime': instance.turnaroundTime,
      'parametersCount': instance.parametersCount,
      'labs': instance.labs,
    };
