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
    // Structured agentic cards (real labs/tests) the assistant surfaced.
    @Default(<ToolResult>[]) List<ToolResult> tools,
    String? createdAt,
    // True while the assistant reply is still streaming in.
    @Default(false) bool isStreaming,
  }) = _AssistantMessage;

  factory AssistantMessage.fromJson(Map<String, dynamic> json) =>
      _$AssistantMessageFromJson(json);
}

/// A lab surfaced by the `find_labs` tool.
@freezed
class AssistantLabCard with _$AssistantLabCard {
  const factory AssistantLabCard({
    required String labId,
    String? labTestId,
    required String name,
    required String address,
    String? city,
    int? priceEgp,
    double? rating,
    @Default(0) int reviews,
    @Default(false) bool homeCollection,
    String? accreditation,
    String? turnaroundTime,
  }) = _AssistantLabCard;

  factory AssistantLabCard.fromJson(Map<String, dynamic> json) =>
      _$AssistantLabCardFromJson(json);
}

/// An aggregated test surfaced by the `search_tests` tool.
@freezed
class AssistantTestCard with _$AssistantTestCard {
  const factory AssistantTestCard({
    required String name,
    required String category,
    int? minPriceEgp,
    @Default(0) int labCount,
  }) = _AssistantTestCard;

  factory AssistantTestCard.fromJson(Map<String, dynamic> json) =>
      _$AssistantTestCardFromJson(json);
}

/// Structured agentic output attached to an assistant message. Discriminated by
/// `tool`: either `find_labs` (labs populated) or `search_tests` (tests populated).
@freezed
class ToolResult with _$ToolResult {
  const factory ToolResult({
    required String tool,
    @Default('') String query,
    @Default(<AssistantLabCard>[]) List<AssistantLabCard> labs,
    @Default(<AssistantTestCard>[]) List<AssistantTestCard> tests,
  }) = _ToolResult;

  factory ToolResult.fromJson(Map<String, dynamic> json) =>
      _$ToolResultFromJson(json);
}
