// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingSlotImpl _$$BookingSlotImplFromJson(Map<String, dynamic> json) =>
    _$BookingSlotImpl(
      id: json['id'] as String,
      startsAt: json['startsAt'] as String,
      endsAt: json['endsAt'] as String,
    );

Map<String, dynamic> _$$BookingSlotImplToJson(_$BookingSlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startsAt': instance.startsAt,
      'endsAt': instance.endsAt,
    };

_$BookingAvailabilityResponseImpl _$$BookingAvailabilityResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingAvailabilityResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => BookingSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BookingAvailabilityResponseImplToJson(
        _$BookingAvailabilityResponseImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

_$BookingItemLabImpl _$$BookingItemLabImplFromJson(Map<String, dynamic> json) =>
    _$BookingItemLabImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      homeCollection: json['homeCollection'] as bool,
      homeTestKit: json['homeTestKit'] as bool,
    );

Map<String, dynamic> _$$BookingItemLabImplToJson(
        _$BookingItemLabImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'homeCollection': instance.homeCollection,
      'homeTestKit': instance.homeTestKit,
    };

_$BookingItemTestImpl _$$BookingItemTestImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingItemTestImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      priceEgp: (json['priceEgp'] as num).toInt(),
    );

Map<String, dynamic> _$$BookingItemTestImplToJson(
        _$BookingItemTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priceEgp': instance.priceEgp,
    };

_$BookingTimelineEntryImpl _$$BookingTimelineEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingTimelineEntryImpl(
      id: json['id'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$BookingTimelineEntryImplToJson(
        _$BookingTimelineEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'note': instance.note,
      'createdAt': instance.createdAt,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'Pending',
  BookingStatus.confirmed: 'Confirmed',
  BookingStatus.rejected: 'Rejected',
  BookingStatus.cancelled: 'Cancelled',
  BookingStatus.completed: 'Completed',
};

_$BookingItemImpl _$$BookingItemImplFromJson(Map<String, dynamic> json) =>
    _$BookingItemImpl(
      id: json['id'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      bookingType: $enumDecode(_$BookingTypeEnumMap, json['bookingType']),
      scheduledAt: json['scheduledAt'] as String,
      homeAddress: json['homeAddress'] as String?,
      totalPriceEgp: (json['totalPriceEgp'] as num).toInt(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
      paymentReference: json['paymentReference'] as String?,
      paymentPaidAt: json['paymentPaidAt'] as String?,
      paymentFailedAt: json['paymentFailedAt'] as String?,
      paymentFailureReason: json['paymentFailureReason'] as String?,
      kitStatus: $enumDecodeNullable(_$KitStatusEnumMap, json['kitStatus']),
      kitTrackingNumber: json['kitTrackingNumber'] as String?,
      kitShippedAt: json['kitShippedAt'] as String?,
      kitDeliveredAt: json['kitDeliveredAt'] as String?,
      sampleReceivedAt: json['sampleReceivedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      lab: BookingItemLab.fromJson(json['lab'] as Map<String, dynamic>),
      test: BookingItemTest.fromJson(json['test'] as Map<String, dynamic>),
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) => BookingTimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BookingItemImplToJson(_$BookingItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'bookingType': _$BookingTypeEnumMap[instance.bookingType]!,
      'scheduledAt': instance.scheduledAt,
      'homeAddress': instance.homeAddress,
      'totalPriceEgp': instance.totalPriceEgp,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'paymentReference': instance.paymentReference,
      'paymentPaidAt': instance.paymentPaidAt,
      'paymentFailedAt': instance.paymentFailedAt,
      'paymentFailureReason': instance.paymentFailureReason,
      'kitStatus': _$KitStatusEnumMap[instance.kitStatus],
      'kitTrackingNumber': instance.kitTrackingNumber,
      'kitShippedAt': instance.kitShippedAt,
      'kitDeliveredAt': instance.kitDeliveredAt,
      'sampleReceivedAt': instance.sampleReceivedAt,
      'createdAt': instance.createdAt,
      'lab': instance.lab,
      'test': instance.test,
      'timeline': instance.timeline,
    };

const _$BookingTypeEnumMap = {
  BookingType.labVisit: 'LabVisit',
  BookingType.homeCollection: 'HomeCollection',
  BookingType.homeTestKit: 'HomeTestKit',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.online: 'Online',
  PaymentMethod.cashHomeCollection: 'CashHomeCollection',
  PaymentMethod.cashLabVisit: 'CashLabVisit',
  PaymentMethod.cashOnDelivery: 'CashOnDelivery',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'Pending',
  PaymentStatus.paid: 'Paid',
  PaymentStatus.failed: 'Failed',
  PaymentStatus.refunded: 'Refunded',
};

const _$KitStatusEnumMap = {
  KitStatus.awaitingShipment: 'AwaitingShipment',
  KitStatus.shipped: 'Shipped',
  KitStatus.delivered: 'Delivered',
  KitStatus.sampleReceived: 'SampleReceived',
};

_$BookingListResponseImpl _$$BookingListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingListResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BookingListResponseImplToJson(
        _$BookingListResponseImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
