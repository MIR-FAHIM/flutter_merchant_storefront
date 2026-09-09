import 'package:ecom_delivery_flutter/app/models/chat_model.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/repositories/shop_chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopChatController extends GetxController {
  ShopChatController({ShopChatRepository? repository})
      : _repository = repository ?? ShopChatRepository();

  final ShopChatRepository _repository;

  final conversations = <Conversation>[].obs;
  final messages = <ChatMessage>[].obs;
  final selectedConversation = Rxn<Conversation>();
  final isConversationLoading = false.obs;
  final isMessagesLoading = false.obs;
  final isOlderMessagesLoading = false.obs;
  final isSending = false.obs;
  final conversationError = ''.obs;
  final messageError = ''.obs;
  final replyTo = Rxn<ChatMessage>();

  final composerController = TextEditingController();
  final messageScrollController = ScrollController();
  final Set<int> _readMessageIds = <int>{};
  final Set<int> _readMessageRequests = <int>{};
  final Set<int> _conversationReadRequests = <int>{};

  int _conversationPage = 1;
  int _conversationLastPage = 1;
  int _messagePage = 1;
  int _messageLastPage = 1;

  bool get canLoadOlderMessages => _messagePage < _messageLastPage;

  @override
  void onInit() {
    super.onInit();
    loadConversations(refresh: true);
    messageScrollController.addListener(_handleMessageScroll);
  }

  @override
  void onClose() {
    composerController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }

  Future<void> loadConversations({bool refresh = false}) async {
    if (isConversationLoading.value) return;
    if (refresh) {
      _conversationPage = 1;
      _conversationLastPage = 1;
    } else if (_conversationPage > _conversationLastPage) {
      return;
    }

    isConversationLoading.value = true;
    conversationError.value = '';

    try {
      final result = await _repository.fetchConversations(page: _conversationPage);
      if (refresh) conversations.clear();
      conversations.addAll(result.items);
      _conversationPage = result.currentPage + 1;
      _conversationLastPage = result.lastPage;
    } catch (e) {
      conversationError.value = e.toString();
    } finally {
      isConversationLoading.value = false;
    }
  }

  Future<void> refreshConversations() => loadConversations(refresh: true);

  Future<void> loadThreadFromArguments() async {
    final args = Get.arguments;
    final conversation = args is Map && args['conversation'] is Conversation
        ? args['conversation'] as Conversation
        : null;
    final conversationId = args is Map
        ? int.tryParse((args['conversation_id'] ?? args['id'] ?? '').toString())
        : null;

    if (conversation != null) {
      await openThread(conversation);
    } else if (conversationId != null && conversationId > 0) {
      await loadThread(conversationId);
    }
  }

  Future<void> openThread(Conversation conversation) async {
    selectedConversation.value = conversation;
    await Future.wait([
      loadMessages(conversationId: conversation.id, refresh: true),
      markConversationRead(conversation.id),
    ]);
  }

  Future<void> loadThread(int conversationId) async {
    isMessagesLoading.value = true;
    messageError.value = '';

    try {
      selectedConversation.value =
          await _repository.fetchConversation(conversationId);
      await Future.wait([
        loadMessages(conversationId: conversationId, refresh: true),
        markConversationRead(conversationId),
      ]);
    } catch (e) {
      messageError.value = e.toString();
    } finally {
      isMessagesLoading.value = false;
    }
  }

  Future<void> loadMessages({
    int? conversationId,
    bool refresh = false,
  }) async {
    final id = conversationId ?? selectedConversation.value?.id;
    if (id == null || id <= 0) return;
    if (refresh) {
      _messagePage = 1;
      _messageLastPage = 1;
    } else if (_messagePage > _messageLastPage ||
        isOlderMessagesLoading.value) {
      return;
    }

    if (refresh) {
      isMessagesLoading.value = true;
    } else {
      isOlderMessagesLoading.value = true;
    }
    messageError.value = '';

    try {
      final result = await _repository.fetchMessages(
        conversationId: id,
        page: _messagePage,
      );
      final sorted = result.items..sort(_sortMessagesAscending);
      if (refresh) {
        messages.assignAll(sorted);
        _seedReadMessageIds(sorted);
        _scrollToBottom();
      } else {
        messages.insertAll(0, sorted);
        _seedReadMessageIds(sorted);
      }
      _messagePage = result.currentPage + 1;
      _messageLastPage = result.lastPage;
    } catch (e) {
      messageError.value = e.toString();
    } finally {
      isMessagesLoading.value = false;
      isOlderMessagesLoading.value = false;
    }
  }

  Future<void> sendTextMessage() async {
    final text = composerController.text.trim();
    final conversationId = selectedConversation.value?.id;
    if (text.isEmpty || conversationId == null || isSending.value) return;

    composerController.clear();
    final replyMessage = replyTo.value;
    replyTo.value = null;

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticMessage = ChatMessage(
      id: tempId,
      conversationId: conversationId,
      senderType: ChatSenderType.shop,
      type: ChatMessageType.text,
      message: text,
      replyTo: replyMessage == null
          ? null
          : ReplyPreview(
              id: replyMessage.id,
              message: replyMessage.previewText,
              senderName: isMine(replyMessage) ? 'You' : 'Customer',
              type: replyMessage.type,
            ),
      createdAt: DateTime.now(),
      isPending: true,
    );
    messages.add(optimisticMessage);
    _scrollToBottom();

    isSending.value = true;
    try {
      final savedMessage = await _repository.sendMessage(
        conversationId: conversationId,
        type: ChatMessageType.text,
        message: text,
        replyToMessageId: replyMessage?.id,
      );
      final index = messages.indexWhere((message) => message.id == tempId);
      if (index >= 0) messages[index] = savedMessage;
      await refreshConversations();
    } catch (e) {
      final index = messages.indexWhere((message) => message.id == tempId);
      if (index >= 0) {
        messages[index] = optimisticMessage.copyWith(
          isPending: false,
          isFailed: true,
        );
      }
      Get.snackbar('Chat', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> markConversationRead(int conversationId) async {
    if (_conversationReadRequests.contains(conversationId)) return;
    _conversationReadRequests.add(conversationId);

    try {
      await _repository.markConversationRead(conversationId);
      _replaceConversationUnreadCount(conversationId, 0);
      _markIncomingMessagesReadLocally();
    } catch (_) {
    } finally {
      _conversationReadRequests.remove(conversationId);
    }
  }

  Future<void> markMessageReadIfNeeded(ChatMessage message) async {
    if (message.id <= 0 || isMine(message) || message.isRead || message.isSeen) {
      return;
    }
    if (_readMessageIds.contains(message.id) ||
        _readMessageRequests.contains(message.id)) {
      return;
    }

    _readMessageRequests.add(message.id);
    try {
      await _repository.markMessageRead(message.id);
      _readMessageIds.add(message.id);
      final index = messages.indexWhere((item) => item.id == message.id);
      if (index >= 0) {
        messages[index] = messages[index].copyWith(
          isRead: true,
          isSeen: true,
        );
      }
      final conversationId =
          message.conversationId ?? selectedConversation.value?.id;
      if (conversationId != null) {
        _decrementConversationUnreadCount(conversationId);
      }
    } catch (_) {
    } finally {
      _readMessageRequests.remove(message.id);
    }
  }

  void setReply(ChatMessage message) => replyTo.value = message;

  void clearReply() => replyTo.value = null;

  bool isMine(ChatMessage message) => message.senderType == ChatSenderType.shop;

  String outgoingReadStatus(ChatMessage message) {
    if (message.isFailed) return 'Failed';
    if (message.isPending) return 'Sent';
    if (message.isRead || message.isSeen) return 'Read';
    if (message.isDelivered) return 'Delivered';
    return 'Sent';
  }

  void _seedReadMessageIds(List<ChatMessage> loadedMessages) {
    for (final message in loadedMessages) {
      if (message.isRead || message.isSeen) {
        _readMessageIds.add(message.id);
      }
    }
  }

  void _markIncomingMessagesReadLocally() {
    final conversationId = selectedConversation.value?.id;
    for (var index = 0; index < messages.length; index++) {
      final message = messages[index];
      if (isMine(message)) continue;
      if (conversationId != null && message.conversationId != null &&
          message.conversationId != conversationId) {
        continue;
      }
      if (!message.isRead || !message.isSeen) {
        messages[index] = message.copyWith(isRead: true, isSeen: true);
      }
      _readMessageIds.add(message.id);
    }
  }

  void _decrementConversationUnreadCount(int conversationId) {
    final index = conversations.indexWhere((item) => item.id == conversationId);
    if (index < 0) return;

    final current = conversations[index];
    final nextCount = current.unreadCount > 0 ? current.unreadCount - 1 : 0;
    _replaceConversationUnreadCount(conversationId, nextCount);
  }

  void _replaceConversationUnreadCount(int conversationId, int unreadCount) {
    final index = conversations.indexWhere((item) => item.id == conversationId);
    if (index < 0) return;

    final current = conversations[index];
    conversations[index] = Conversation(
      id: current.id,
      shopId: current.shopId,
      customerId: current.customerId,
      shop: current.shop,
      customer: current.customer,
      lastMessage: current.lastMessage,
      unreadCount: unreadCount,
      status: current.status,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );
  }

  void _handleMessageScroll() {
    if (!messageScrollController.hasClients) return;
    if (messageScrollController.position.pixels <= 80 &&
        canLoadOlderMessages &&
        !isOlderMessagesLoading.value) {
      loadMessages();
    }
  }

  int _sortMessagesAscending(ChatMessage a, ChatMessage b) {
    final first = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final second = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return first.compareTo(second);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messageScrollController.hasClients) return;
      messageScrollController.animateTo(
        messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }
}
