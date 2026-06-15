import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

enum ChatRole { user, assistant }

@freezed
class AssistantConversation with _$AssistantConversation {
  const factory AssistantConversation({
    required String id,
    String? title,
    required String updatedAt,
  }) = _AssistantConversation;

  factory AssistantConversation.fromJson(Map<String, dynamic> json) =>
      _$AssistantConversationFromJson(json);
}

@freezed
class AssistantMessage with _$AssistantMessage {
  const factory AssistantMessage({
    required String id,
    required ChatRole role,
    required String content,
    String? createdAt,
    // True while the assistant reply is still streaming in.
    @Default(false) bool isStreaming,
  }) = _AssistantMessage;

  factory AssistantMessage.fromJson(Map<String, dynamic> json) =>
      _$AssistantMessageFromJson(json);
}
