enum ChatMessageType {
  text,
  product,
  order,
  orderStatus,
  system,
  image,
  voice,
  file,
  unknown,
}

enum ChatSenderType {
  customer,
  shop,
  system,
  unknown,
}

class PaginatedResponse<T> {
  PaginatedResponse({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}

class Conversation {
  Conversation({
    required this.id,
    this.shopId,
    this.customerId,
    this.shop,
    this.customer,
    this.lastMessage,
    this.unreadCount = 0,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int? shopId;
  final int? customerId;
  final ConversationShop? shop;
  final ConversationCustomer? customer;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get title => customer?.name ?? shop?.name ?? 'Customer';
  String? get imageUrl => customer?.avatar ?? shop?.logo;
  String get preview => lastMessage?.previewText ?? 'No messages yet';

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final shopMap = _asMap(json['shop'] ?? json['store']);
    final customerMap = _asMap(json['customer'] ?? json['user']);
    final messageMap = _asMap(json['last_message'] ?? json['latest_message']);

    return Conversation(
      id: _toInt(json['id']),
      shopId: _toNullableInt(json['shop_id'] ?? json['store_id']),
      customerId: _toNullableInt(json['customer_id'] ?? json['user_id']),
      shop: shopMap == null ? null : ConversationShop.fromJson(shopMap),
      customer: customerMap == null
          ? null
          : ConversationCustomer.fromJson(customerMap),
      lastMessage: messageMap == null ? null : ChatMessage.fromJson(messageMap),
      unreadCount: _toInt(json['unread_count'] ?? json['unread_messages_count']),
      status: json['status']?.toString(),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }
}

class ConversationShop {
  ConversationShop({
    this.id,
    this.name,
    this.slug,
    this.logo,
  });

  final int? id;
  final String? name;
  final String? slug;
  final String? logo;

  factory ConversationShop.fromJson(Map<String, dynamic> json) {
    return ConversationShop(
      id: _toNullableInt(json['id']),
      name: _firstString(json, ['shop_name', 'name', 'store_name']),
      slug: _firstString(json, ['slug', 'shop_slug', 'store_slug']),
      logo: _firstString(json, ['logo', 'image', 'avatar']),
    );
  }
}

class ConversationCustomer {
  ConversationCustomer({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;

  factory ConversationCustomer.fromJson(Map<String, dynamic> json) {
    return ConversationCustomer(
      id: _toNullableInt(json['id']),
      name: _firstString(json, ['name', 'full_name', 'customer_name']),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: _firstString(json, ['avatar', 'photo', 'image', 'profile_photo']),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    this.conversationId,
    this.senderId,
    this.senderType = ChatSenderType.unknown,
    this.type = ChatMessageType.text,
    this.message,
    this.fileUrl,
    this.product,
    this.order,
    this.replyTo,
    this.sender,
    this.isRead = false,
    this.isDelivered = false,
    this.isSeen = false,
    this.createdAt,
    this.updatedAt,
    this.isPending = false,
    this.isFailed = false,
  });

  final int id;
  final int? conversationId;
  final int? senderId;
  final ChatSenderType senderType;
  final ChatMessageType type;
  final String? message;
  final String? fileUrl;
  final ChatProduct? product;
  final ChatOrder? order;
  final ReplyPreview? replyTo;
  final ChatSender? sender;
  final bool isRead;
  final bool isDelivered;
  final bool isSeen;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPending;
  final bool isFailed;

  String get previewText {
    if ((message ?? '').trim().isNotEmpty) return message!.trim();
    switch (type) {
      case ChatMessageType.product:
        return product?.name ?? 'Product shared';
      case ChatMessageType.order:
        return order?.orderNumber ?? 'Order shared';
      case ChatMessageType.orderStatus:
        return 'Order status update';
      case ChatMessageType.system:
        return message ?? 'System message';
      case ChatMessageType.image:
        return 'Image';
      case ChatMessageType.voice:
        return 'Voice message';
      case ChatMessageType.file:
        return 'File';
      case ChatMessageType.text:
      case ChatMessageType.unknown:
        return 'Message';
    }
  }

  ChatMessage copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    ChatSenderType? senderType,
    ChatMessageType? type,
    String? message,
    String? fileUrl,
    ChatProduct? product,
    ChatOrder? order,
    ReplyPreview? replyTo,
    ChatSender? sender,
    bool? isRead,
    bool? isDelivered,
    bool? isSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPending,
    bool? isFailed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      type: type ?? this.type,
      message: message ?? this.message,
      fileUrl: fileUrl ?? this.fileUrl,
      product: product ?? this.product,
      order: order ?? this.order,
      replyTo: replyTo ?? this.replyTo,
      sender: sender ?? this.sender,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final productMap = _asMap(json['product']);
    final orderMap = _asMap(json['order']);
    final replyMap = _asMap(json['reply_to'] ?? json['reply']);
    final senderMap = _asMap(json['sender']);

    return ChatMessage(
      id: _toInt(json['id']),
      conversationId: _toNullableInt(json['conversation_id']),
      senderId: _toNullableInt(json['sender_id']),
      senderType: _senderType(json['sender_type']),
      type: _messageType(json['message_type'] ?? json['type']),
      message: json['message']?.toString() ?? json['body']?.toString(),
      fileUrl: _firstString(json, ['file_url', 'file_path', 'attachment_url']),
      product: productMap == null ? null : ChatProduct.fromJson(productMap),
      order: orderMap == null ? null : ChatOrder.fromJson(orderMap),
      replyTo: replyMap == null ? null : ReplyPreview.fromJson(replyMap),
      sender: senderMap == null ? null : ChatSender.fromJson(senderMap),
      isRead: _toBool(json['is_read']) ||
          _toBool(json['is_seen']) ||
          json['read_at'] != null ||
          json['seen_at'] != null,
      isDelivered: _toBool(json['is_delivered']) || json['delivered_at'] != null,
      isSeen: _toBool(json['is_seen']) || json['seen_at'] != null,
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }
}

class ChatSender {
  ChatSender({
    this.id,
    this.name,
    this.avatar,
    this.type = ChatSenderType.unknown,
  });

  final int? id;
  final String? name;
  final String? avatar;
  final ChatSenderType type;

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: _toNullableInt(json['id']),
      name: _firstString(json, ['name', 'full_name', 'shop_name']),
      avatar: _firstString(json, ['avatar', 'logo', 'image']),
      type: _senderType(json['type'] ?? json['sender_type']),
    );
  }
}

class ChatProduct {
  ChatProduct({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.price,
  });

  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final String? price;

  factory ChatProduct.fromJson(Map<String, dynamic> json) {
    return ChatProduct(
      id: _toNullableInt(json['id'] ?? json['product_id']),
      name: _firstString(json, ['name', 'product_name', 'title']),
      slug: json['slug']?.toString(),
      image: _firstString(json, ['thumbnail', 'image', 'cover_image']),
      price: (json['price'] ?? json['unit_price'] ?? json['selling_price'])
          ?.toString(),
    );
  }
}

class ChatOrder {
  ChatOrder({
    this.id,
    this.orderNumber,
    this.status,
    this.total,
  });

  final int? id;
  final String? orderNumber;
  final String? status;
  final String? total;

  factory ChatOrder.fromJson(Map<String, dynamic> json) {
    return ChatOrder(
      id: _toNullableInt(json['id'] ?? json['order_id']),
      orderNumber:
          _firstString(json, ['order_number', 'invoice_no', 'code']) ??
              (json['id'] != null ? 'Order #${json['id']}' : null),
      status: json['status']?.toString(),
      total: (json['total'] ?? json['grand_total'] ?? json['amount'])
          ?.toString(),
    );
  }
}

class ReplyPreview {
  ReplyPreview({
    this.id,
    this.message,
    this.senderName,
    this.type = ChatMessageType.unknown,
  });

  final int? id;
  final String? message;
  final String? senderName;
  final ChatMessageType type;

  factory ReplyPreview.fromJson(Map<String, dynamic> json) {
    return ReplyPreview(
      id: _toNullableInt(json['id']),
      message: json['message']?.toString() ?? json['body']?.toString(),
      senderName: _firstString(json, ['sender_name', 'name']),
      type: _messageType(json['message_type'] ?? json['type']),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

int _toInt(dynamic value) => _toNullableInt(value) ?? 0;

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;

  final text = value?.toString().toLowerCase().trim();
  return text == '1' || text == 'true' || text == 'yes';
}

ChatMessageType _messageType(dynamic value) {
  final normalized = value?.toString().toLowerCase().replaceAll('-', '_');
  switch (normalized) {
    case 'text':
      return ChatMessageType.text;
    case 'product':
      return ChatMessageType.product;
    case 'order':
      return ChatMessageType.order;
    case 'order_status':
    case 'orderstatus':
      return ChatMessageType.orderStatus;
    case 'system':
      return ChatMessageType.system;
    case 'image':
      return ChatMessageType.image;
    case 'voice':
    case 'audio':
      return ChatMessageType.voice;
    case 'file':
    case 'attachment':
      return ChatMessageType.file;
    default:
      return ChatMessageType.unknown;
  }
}

ChatSenderType _senderType(dynamic value) {
  final normalized = value?.toString().toLowerCase();
  switch (normalized) {
    case 'customer':
    case 'user':
      return ChatSenderType.customer;
    case 'shop':
    case 'seller':
    case 'store':
      return ChatSenderType.shop;
    case 'system':
      return ChatSenderType.system;
    default:
      return ChatSenderType.unknown;
  }
}
