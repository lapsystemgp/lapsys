// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssistantConversationImpl _$$AssistantConversationImplFromJson(
        Map<String, dynamic> json) =>
    _$AssistantConversationImpl(
      id: json['id'] as String,
      title: json['title'] as String?,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$AssistantConversationImplToJson(
        _$AssistantConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'updatedAt': instance.updatedAt,
    };

_$AssistantMessageImpl _$$AssistantMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$AssistantMessageImpl(
      id: json['id'] as String,
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      content: json['content'] as String,
      tools: (json['tools'] as List<dynamic>?)
              ?.map((e) => ToolResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ToolResult>[],
      createdAt: json['createdAt'] as String?,
      isStreaming: json['isStreaming'] as bool? ?? false,
    );

Map<String, dynamic> _$$AssistantMessageImplToJson(
        _$AssistantMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'tools': instance.tools,
      'createdAt': instance.createdAt,
      'isStreaming': instance.isStreaming,
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.assistant: 'assistant',
};

_$AssistantLabCardImpl _$$AssistantLabCardImplFromJson(
        Map<String, dynamic> json) =>
    _$AssistantLabCardImpl(
      labId: json['labId'] as String,
      labTestId: json['labTestId'] as String?,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      priceEgp: (json['priceEgp'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      homeCollection: json['homeCollection'] as bool? ?? false,
      accreditation: json['accreditation'] as String?,
      turnaroundTime: json['turnaroundTime'] as String?,
    );

Map<String, dynamic> _$$AssistantLabCardImplToJson(
        _$AssistantLabCardImpl instance) =>
    <String, dynamic>{
      'labId': instance.labId,
      'labTestId': instance.labTestId,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'priceEgp': instance.priceEgp,
      'rating': instance.rating,
      'reviews': instance.reviews,
      'homeCollection': instance.homeCollection,
      'accreditation': instance.accreditation,
      'turnaroundTime': instance.turnaroundTime,
    };

_$AssistantTestCardImpl _$$AssistantTestCardImplFromJson(
        Map<String, dynamic> json) =>
    _$AssistantTestCardImpl(
      name: json['name'] as String,
      category: json['category'] as String,
      minPriceEgp: (json['minPriceEgp'] as num?)?.toInt(),
      labCount: (json['labCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AssistantTestCardImplToJson(
        _$AssistantTestCardImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'minPriceEgp': instance.minPriceEgp,
      'labCount': instance.labCount,
    };

_$ToolResultImpl _$$ToolResultImplFromJson(Map<String, dynamic> json) =>
    _$ToolResultImpl(
      tool: json['tool'] as String,
      query: json['query'] as String? ?? '',
      labs: (json['labs'] as List<dynamic>?)
              ?.map((e) => AssistantLabCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AssistantLabCard>[],
      tests: (json['tests'] as List<dynamic>?)
              ?.map(
                  (e) => AssistantTestCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AssistantTestCard>[],
    );

Map<String, dynamic> _$$ToolResultImplToJson(_$ToolResultImpl instance) =>
    <String, dynamic>{
      'tool': instance.tool,
      'query': instance.query,
      'labs': instance.labs,
      'tests': instance.tests,
    };
