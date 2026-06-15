import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import 'chat_models.dart';

/// A single parsed Server-Sent Event from the `/chat/messages` stream.
typedef ChatStreamEvent = Map<String, dynamic>;

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<List<AssistantConversation>> listConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');
      final data = response.data as List<dynamic>;
      return data
          .map((e) =>
              AssistantConversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<AssistantMessage>> getMessages(String conversationId) async {
    try {
      final response =
          await _dio.get('/chat/conversations/$conversationId/messages');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => AssistantMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Sends [text] and yields parsed SSE events as they arrive:
  ///   {type: 'meta', conversationId}
  ///   {type: 'delta', text}
  ///   {type: 'done', messageId}
  ///   {type: 'error', message}
  Stream<ChatStreamEvent> sendMessage({
    required String text,
    String? conversationId,
  }) async* {
    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/chat/messages',
        data: {
          'text': text,
          if (conversationId != null) 'conversationId': conversationId,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // The model can take a while to produce a full reply.
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }

    final stream = response.data!.stream;
    var buffer = '';
    await for (final Uint8List chunk in stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);

      // SSE events are separated by a blank line.
      var sep = buffer.indexOf('\n\n');
      while (sep != -1) {
        final rawEvent = buffer.substring(0, sep);
        buffer = buffer.substring(sep + 2);
        final event = _parseEvent(rawEvent);
        if (event != null) yield event;
        sep = buffer.indexOf('\n\n');
      }
    }
  }

  ChatStreamEvent? _parseEvent(String rawEvent) {
    // An event may span multiple `data:` lines; concatenate their payloads.
    final dataLines = rawEvent
        .split('\n')
        .where((l) => l.startsWith('data:'))
        .map((l) => l.substring(5).trimLeft())
        .toList();
    if (dataLines.isEmpty) return null;
    final payload = dataLines.join('\n');
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(dioClientProvider)),
);
