import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/models/chat_model.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ShopChatRepository {
  final APIManager _apiManager = APIManager();

  Future<PaginatedResponse<Conversation>> fetchConversations({
    int page = 1,
    int perPage = 20,
  }) async {
    final uri = Uri.parse(ApiClient.chatConversations).replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );
    final response = await _apiManager.getWithHeaderStatus(uri.toString(), {});
    _throwIfNeeded(response);

    return _parsePaginated(
      response['body'],
      (json) => Conversation.fromJson(json),
    );
  }

  Future<Conversation> openConversation({required int shopId}) async {
    final response = await _apiManager.postJsonWithHeaderStatus(
      ApiClient.chatConversations,
      {'shop_id': shopId},
      {},
    );
    _throwIfNeeded(response);

    final data = _unwrapData(response['body']);
    if (data is Map) {
      return Conversation.fromJson(Map<String, dynamic>.from(data));
    }
    throw ChatApiException('Conversation could not be opened.');
  }

  Future<Conversation> fetchConversation(int conversationId) async {
    final response = await _apiManager.getWithHeaderStatus(
      '${ApiClient.chatConversations}/$conversationId',
      {},
    );
    _throwIfNeeded(response);

    final data = _unwrapData(response['body']);
    if (data is Map) {
      return Conversation.fromJson(Map<String, dynamic>.from(data));
    }
    throw ChatApiException('Conversation not found.');
  }

  Future<PaginatedResponse<ChatMessage>> fetchMessages({
    required int conversationId,
    int page = 1,
    int perPage = 30,
  }) async {
    final uri = Uri.parse('${ApiClient.chatConversations}/$conversationId/messages')
        .replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );
    final response = await _apiManager.getWithHeaderStatus(uri.toString(), {});
    _throwIfNeeded(response);

    return _parsePaginated(
      response['body'],
      (json) => ChatMessage.fromJson(json),
    );
  }

  Future<ChatMessage> sendMessage({
    required int conversationId,
    required ChatMessageType type,
    String? message,
    int? productId,
    int? orderId,
    int? replyToMessageId,
  }) async {
    final payload = <String, dynamic>{
      'message_type': _typePayload(type),
    };

    if ((message ?? '').trim().isNotEmpty) {
      payload['message'] = message!.trim();
    }
    if (productId != null) payload['product_id'] = productId;
    if (orderId != null) payload['order_id'] = orderId;
    if (replyToMessageId != null) {
      payload['reply_to_message_id'] = replyToMessageId;
    }

    final response = await _apiManager.postJsonWithHeaderStatus(
      '${ApiClient.chatConversations}/$conversationId/messages',
      payload,
      {},
    );
    _throwIfNeeded(response);

    final data = _unwrapData(response['body']);
    if (data is Map) {
      return ChatMessage.fromJson(Map<String, dynamic>.from(data));
    }
    throw ChatApiException('Message could not be sent.');
  }

  Future<void> markMessageRead(int messageId) async {
    final response = await _apiManager.postJsonWithHeaderStatus(
      '${ApiClient.chatMessages}$messageId/read',
      {},
      {},
    );
    _throwIfNeeded(response);
  }

  Future<void> markConversationRead(int conversationId) async {
    final response = await _apiManager.postJsonWithHeaderStatus(
      '${ApiClient.chatConversations}/$conversationId/read',
      {},
      {},
    );
    _throwIfNeeded(response);
  }

  PaginatedResponse<T> _parsePaginated<T>(
    dynamic body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final unwrapped = _unwrapData(body);
    final dataMap =
        unwrapped is Map ? Map<String, dynamic>.from(unwrapped) : null;
    final rawItems = dataMap?['data'] ??
        dataMap?['items'] ??
        dataMap?['conversations'] ??
        dataMap?['messages'] ??
        unwrapped;

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <T>[];

    return PaginatedResponse<T>(
      items: items,
      currentPage: _toInt(dataMap?['current_page'], 1),
      lastPage: _toInt(dataMap?['last_page'], 1),
      total: _toInt(dataMap?['total'], items.length),
    );
  }

  dynamic _unwrapData(dynamic body) {
    if (body is Map && body['data'] != null) {
      return body['data'];
    }
    return body;
  }

  int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _typePayload(ChatMessageType type) {
    switch (type) {
      case ChatMessageType.orderStatus:
        return 'order_status';
      case ChatMessageType.product:
        return 'product';
      case ChatMessageType.order:
        return 'order';
      case ChatMessageType.system:
        return 'system';
      case ChatMessageType.image:
        return 'image';
      case ChatMessageType.voice:
        return 'voice';
      case ChatMessageType.file:
        return 'file';
      case ChatMessageType.text:
      case ChatMessageType.unknown:
        return 'text';
    }
  }

  void _throwIfNeeded(Map<String, dynamic> response) {
    final statusCode = response['status_code'] as int? ?? 500;
    if (statusCode >= 200 && statusCode < 300) return;

    final body = response['body'];
    if (statusCode == 401) {
      Get.offAllNamed(Routes.LOGIN);
      throw ChatApiException('Please login again to continue.');
    }
    if (statusCode == 403) {
      throw ChatApiException('You do not have permission.');
    }
    if (statusCode == 404) {
      throw ChatApiException('Conversation not found or access denied.');
    }
    if (statusCode == 422) {
      throw ChatApiException(_validationMessage(body));
    }
    if (statusCode >= 500) {
      throw ChatApiException('Something went wrong. Please try again.');
    }

    throw ChatApiException(_messageFromBody(body) ?? 'Chat request failed.');
  }

  String _validationMessage(dynamic body) {
    if (body is Map && body['errors'] is Map) {
      final Iterable<String> messages = (body['errors'] as Map).values.expand((value) {
        if (value is List) return value.map((item) => item.toString());
        return <String>[value.toString()];
      }).where((message) => message.trim().isNotEmpty);
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return _messageFromBody(body) ?? 'Please check the chat form and try again.';
  }

  String? _messageFromBody(dynamic body) {
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    return null;
  }
}

class ChatApiException implements Exception {
  ChatApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
