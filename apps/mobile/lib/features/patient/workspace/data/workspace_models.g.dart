// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkspaceBookingLabImpl _$$WorkspaceBookingLabImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceBookingLabImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$$WorkspaceBookingLabImplToJson(
        _$WorkspaceBookingLabImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
    };

_$WorkspaceBookingTestImpl _$$WorkspaceBookingTestImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceBookingTestImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      priceEgp: (json['priceEgp'] as num).toInt(),
    );

Map<String, dynamic> _$$WorkspaceBookingTestImplToJson(
        _$WorkspaceBookingTestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priceEgp': instance.priceEgp,
    };

_$WorkspaceTimelineEntryImpl _$$WorkspaceTimelineEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceTimelineEntryImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$WorkspaceTimelineEntryImplToJson(
        _$WorkspaceTimelineEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'note': instance.note,
      'createdAt': instance.createdAt,
    };

_$WorkspaceBookingImpl _$$WorkspaceBookingImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceBookingImpl(
      id: json['id'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      bookingType: $enumDecode(_$BookingTypeEnumMap, json['bookingType']),
      scheduledAt: json['scheduledAt'] as String,
      totalPriceEgp: (json['totalPriceEgp'] as num).toInt(),
      homeAddress: json['homeAddress'] as String?,
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
      lab: WorkspaceBookingLab.fromJson(json['lab'] as Map<String, dynamic>),
      test: WorkspaceBookingTest.fromJson(json['test'] as Map<String, dynamic>),
      timeline: (json['timeline'] as List<dynamic>)
          .map(
              (e) => WorkspaceTimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorkspaceBookingImplToJson(
        _$WorkspaceBookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'bookingType': _$BookingTypeEnumMap[instance.bookingType]!,
      'scheduledAt': instance.scheduledAt,
      'totalPriceEgp': instance.totalPriceEgp,
      'homeAddress': instance.homeAddress,
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
      'lab': instance.lab,
      'test': instance.test,
      'timeline': instance.timeline,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'Pending',
  BookingStatus.confirmed: 'Confirmed',
  BookingStatus.rejected: 'Rejected',
  BookingStatus.cancelled: 'Cancelled',
  BookingStatus.completed: 'Completed',
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

_$ResultFileImpl _$$ResultFileImplFromJson(Map<String, dynamic> json) =>
    _$ResultFileImpl(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      mimeType: json['mimeType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      uploadedAt: json['uploadedAt'] as String,
    );

Map<String, dynamic> _$$ResultFileImplToJson(_$ResultFileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'uploadedAt': instance.uploadedAt,
    };

_$SummaryHighlightItemImpl _$$SummaryHighlightItemImplFromJson(
        Map<String, dynamic> json) =>
    _$SummaryHighlightItemImpl(
      key: json['key'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      kind: json['kind'] as String,
    );

Map<String, dynamic> _$$SummaryHighlightItemImplToJson(
        _$SummaryHighlightItemImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'value': instance.value,
      'kind': instance.kind,
    };

_$SummaryHighlightsImpl _$$SummaryHighlightsImplFromJson(
        Map<String, dynamic> json) =>
    _$SummaryHighlightsImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => SummaryHighlightItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SummaryHighlightsImplToJson(
        _$SummaryHighlightsImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

_$ResultSummaryImpl _$$ResultSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ResultSummaryImpl(
      summary: json['summary'] as String,
      highlights: SummaryHighlights.fromJson(
          json['highlights'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ResultSummaryImplToJson(_$ResultSummaryImpl instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'highlights': instance.highlights,
    };

_$WorkspaceResultReviewImpl _$$WorkspaceResultReviewImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceResultReviewImpl(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      status: $enumDecode(_$ReviewStatusEnumMap, json['status']),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$WorkspaceResultReviewImplToJson(
        _$WorkspaceResultReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'status': _$ReviewStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt,
    };

const _$ReviewStatusEnumMap = {
  ReviewStatus.pending: 'Pending',
  ReviewStatus.published: 'Published',
  ReviewStatus.rejected: 'Rejected',
};

_$WorkspaceResultImpl _$$WorkspaceResultImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceResultImpl(
      bookingId: json['bookingId'] as String,
      bookingStatus: $enumDecode(_$BookingStatusEnumMap, json['bookingStatus']),
      scheduledAt: json['scheduledAt'] as String,
      labName: json['labName'] as String,
      testName: json['testName'] as String,
      resultStatus: $enumDecode(_$ResultStatusEnumMap, json['resultStatus']),
      hasStructuredData: json['hasStructuredData'] as bool,
      structuredObservationCount:
          (json['structuredObservationCount'] as num).toInt(),
      file: json['file'] == null
          ? null
          : ResultFile.fromJson(json['file'] as Map<String, dynamic>),
      summary: json['summary'] == null
          ? null
          : ResultSummary.fromJson(json['summary'] as Map<String, dynamic>),
      review: json['review'] == null
          ? null
          : WorkspaceResultReview.fromJson(
              json['review'] as Map<String, dynamic>),
      canReview: json['canReview'] as bool,
    );

Map<String, dynamic> _$$WorkspaceResultImplToJson(
        _$WorkspaceResultImpl instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'bookingStatus': _$BookingStatusEnumMap[instance.bookingStatus]!,
      'scheduledAt': instance.scheduledAt,
      'labName': instance.labName,
      'testName': instance.testName,
      'resultStatus': _$ResultStatusEnumMap[instance.resultStatus]!,
      'hasStructuredData': instance.hasStructuredData,
      'structuredObservationCount': instance.structuredObservationCount,
      'file': instance.file,
      'summary': instance.summary,
      'review': instance.review,
      'canReview': instance.canReview,
    };

const _$ResultStatusEnumMap = {
  ResultStatus.pending: 'Pending',
  ResultStatus.uploaded: 'Uploaded',
  ResultStatus.delivered: 'Delivered',
};

_$WorkspaceProfileImpl _$$WorkspaceProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceProfileImpl(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      labHistorySharing:
          $enumDecode(_$LabHistorySharingEnumMap, json['labHistorySharing']),
    );

Map<String, dynamic> _$$WorkspaceProfileImplToJson(
        _$WorkspaceProfileImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'address': instance.address,
      'email': instance.email,
      'labHistorySharing':
          _$LabHistorySharingEnumMap[instance.labHistorySharing]!,
    };

const _$LabHistorySharingEnumMap = {
  LabHistorySharing.sameLabOnly: 'SAME_LAB_ONLY',
  LabHistorySharing.fullHistoryAuthorized: 'FULL_HISTORY_AUTHORIZED',
};

_$WorkspaceBookingsImpl _$$WorkspaceBookingsImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkspaceBookingsImpl(
      upcoming: (json['upcoming'] as List<dynamic>)
          .map((e) => WorkspaceBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      past: (json['past'] as List<dynamic>)
          .map((e) => WorkspaceBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WorkspaceBookingsImplToJson(
        _$WorkspaceBookingsImpl instance) =>
    <String, dynamic>{
      'upcoming': instance.upcoming,
      'past': instance.past,
    };

_$PatientWorkspaceResponseImpl _$$PatientWorkspaceResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PatientWorkspaceResponseImpl(
      profile:
          WorkspaceProfile.fromJson(json['profile'] as Map<String, dynamic>),
      bookings:
          WorkspaceBookings.fromJson(json['bookings'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>)
          .map((e) => WorkspaceResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PatientWorkspaceResponseImplToJson(
        _$PatientWorkspaceResponseImpl instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'bookings': instance.bookings,
      'results': instance.results,
    };
