// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_workspace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabInfoImpl _$$LabInfoImplFromJson(Map<String, dynamic> json) =>
    _$LabInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      homeCollection: json['homeCollection'] as bool,
      homeTestKit: json['homeTestKit'] as bool,
    );

Map<String, dynamic> _$$LabInfoImplToJson(_$LabInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'homeCollection': instance.homeCollection,
      'homeTestKit': instance.homeTestKit,
    };

_$LabBookingPatientImpl _$$LabBookingPatientImplFromJson(
        Map<String, dynamic> json) =>
    _$LabBookingPatientImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$LabBookingPatientImplToJson(
        _$LabBookingPatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
    };

_$LabBookingLabImpl _$$LabBookingLabImplFromJson(Map<String, dynamic> json) =>
    _$LabBookingLabImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      homeCollection: json['homeCollection'] as bool,
      homeTestKit: json['homeTestKit'] as bool,
    );

Map<String, dynamic> _$$LabBookingLabImplToJson(_$LabBookingLabImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'homeCollection': instance.homeCollection,
      'homeTestKit': instance.homeTestKit,
    };

_$LabBookingTestImpl _$$LabBookingTestImplFromJson(Map<String, dynamic> json) =>
    _$LabBookingTestImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      priceEgp: (json['priceEgp'] as num).toInt(),
    );

Map<String, dynamic> _$$LabBookingTestImplToJson(
        _$LabBookingTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priceEgp': instance.priceEgp,
    };

_$LabBookingSlotImpl _$$LabBookingSlotImplFromJson(Map<String, dynamic> json) =>
    _$LabBookingSlotImpl(
      id: json['id'] as String,
      startsAt: json['startsAt'] as String,
      endsAt: json['endsAt'] as String,
    );

Map<String, dynamic> _$$LabBookingSlotImplToJson(
        _$LabBookingSlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startsAt': instance.startsAt,
      'endsAt': instance.endsAt,
    };

_$LabBookingTimelineEntryImpl _$$LabBookingTimelineEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LabBookingTimelineEntryImpl(
      id: json['id'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      note: json['note'] as String?,
      actorUserId: json['actorUserId'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$LabBookingTimelineEntryImplToJson(
        _$LabBookingTimelineEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'note': instance.note,
      'actorUserId': instance.actorUserId,
      'createdAt': instance.createdAt,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'Pending',
  BookingStatus.confirmed: 'Confirmed',
  BookingStatus.rejected: 'Rejected',
  BookingStatus.cancelled: 'Cancelled',
  BookingStatus.completed: 'Completed',
};

_$LabBookingItemImpl _$$LabBookingItemImplFromJson(Map<String, dynamic> json) =>
    _$LabBookingItemImpl(
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
      createdAt: json['createdAt'] as String,
      patient:
          LabBookingPatient.fromJson(json['patient'] as Map<String, dynamic>),
      lab: LabBookingLab.fromJson(json['lab'] as Map<String, dynamic>),
      test: LabBookingTest.fromJson(json['test'] as Map<String, dynamic>),
      slot: json['slot'] == null
          ? null
          : LabBookingSlot.fromJson(json['slot'] as Map<String, dynamic>),
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) =>
              LabBookingTimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LabBookingItemImplToJson(
        _$LabBookingItemImpl instance) =>
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
      'patient': instance.patient,
      'lab': instance.lab,
      'test': instance.test,
      'slot': instance.slot,
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

_$LabTestImpl _$$LabTestImplFromJson(Map<String, dynamic> json) =>
    _$LabTestImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      priceEgp: (json['priceEgp'] as num).toInt(),
      description: json['description'] as String? ?? '',
      preparation: json['preparation'] as String? ?? '',
      turnaroundTime: json['turnaroundTime'] as String? ?? '',
      parametersCount: (json['parametersCount'] as num?)?.toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$LabTestImplToJson(_$LabTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'priceEgp': instance.priceEgp,
      'description': instance.description,
      'preparation': instance.preparation,
      'turnaroundTime': instance.turnaroundTime,
      'parametersCount': instance.parametersCount,
      'isActive': instance.isActive,
    };

_$LabScheduleSlotImpl _$$LabScheduleSlotImplFromJson(
        Map<String, dynamic> json) =>
    _$LabScheduleSlotImpl(
      id: json['id'] as String,
      startsAt: json['startsAt'] as String,
      endsAt: json['endsAt'] as String,
      capacity: (json['capacity'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$LabScheduleSlotImplToJson(
        _$LabScheduleSlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startsAt': instance.startsAt,
      'endsAt': instance.endsAt,
      'capacity': instance.capacity,
      'isActive': instance.isActive,
    };

_$LabTopTestImpl _$$LabTopTestImplFromJson(Map<String, dynamic> json) =>
    _$LabTopTestImpl(
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$LabTopTestImplToJson(_$LabTopTestImpl instance) =>
    <String, dynamic>{
      'testId': instance.testId,
      'testName': instance.testName,
      'count': instance.count,
    };

_$LabAnalyticsImpl _$$LabAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$LabAnalyticsImpl(
      totalBookings: (json['totalBookings'] as num).toInt(),
      completedBookings: (json['completedBookings'] as num).toInt(),
      pendingResults: (json['pendingResults'] as num).toInt(),
      revenueEstimateEgp: (json['revenueEstimateEgp'] as num).toInt(),
      capacityUsagePercent: (json['capacityUsagePercent'] as num).toDouble(),
      topTests: (json['topTests'] as List<dynamic>)
          .map((e) => LabTopTest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LabAnalyticsImplToJson(_$LabAnalyticsImpl instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'completedBookings': instance.completedBookings,
      'pendingResults': instance.pendingResults,
      'revenueEstimateEgp': instance.revenueEstimateEgp,
      'capacityUsagePercent': instance.capacityUsagePercent,
      'topTests': instance.topTests,
    };

_$LabWorkspaceResponseImpl _$$LabWorkspaceResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$LabWorkspaceResponseImpl(
      lab: LabInfo.fromJson(json['lab'] as Map<String, dynamic>),
      bookings: (json['bookings'] as List<dynamic>)
          .map((e) => LabBookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      tests: (json['tests'] as List<dynamic>)
          .map((e) => LabTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedule: (json['schedule'] as List<dynamic>)
          .map((e) => LabScheduleSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      analytics:
          LabAnalytics.fromJson(json['analytics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LabWorkspaceResponseImplToJson(
        _$LabWorkspaceResponseImpl instance) =>
    <String, dynamic>{
      'lab': instance.lab,
      'bookings': instance.bookings,
      'tests': instance.tests,
      'schedule': instance.schedule,
      'analytics': instance.analytics,
    };
