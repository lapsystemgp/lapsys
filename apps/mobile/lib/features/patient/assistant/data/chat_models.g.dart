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
      createdAt: json['createdAt'] as String?,
      isStreaming: json['isStreaming'] as bool? ?? false,
    );

Map<String, dynamic> _$$AssistantMessageImplToJson(
        _$AssistantMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'createdAt': instance.createdAt,
      'isStreaming': instance.isStreaming,
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.assistant: 'assistant',
};
