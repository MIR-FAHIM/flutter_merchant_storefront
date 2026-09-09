import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/views/widgets/shop_chat_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatThreadView extends StatefulWidget {
  const ChatThreadView({super.key});

  @override
  State<ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<ChatThreadView> {
  late final ShopChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ShopChatController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadThreadFromArguments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Obx(() {
          final conversation = controller.selectedConversation.value;
          return Row(
            children: [
              ChatAvatar(
                imageUrl: conversation?.imageUrl,
                name: conversation?.title ?? 'Customer',
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      conversation?.title ?? 'Customer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Shop side chat',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            tooltip: 'Refresh messages',
            onPressed: () => controller.loadMessages(refresh: true),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isMessagesLoading.value &&
                  controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messageError.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Container(
                  color: const Color(0xFF111213),
                  child: ChatEmptyState(
                    icon: Icons.sms_failed_outlined,
                    title: 'Could not load messages',
                    message: controller.messageError.value,
                    onRetry: () => controller.loadThreadFromArguments(),
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return Container(
                  color: const Color(0xFF111213),
                  child: const ChatEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No messages in this chat',
                    message: 'Send a message to start helping this customer.',
                  ),
                );
              }

              return ListView.builder(
                controller: controller.messageScrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: controller.messages.length +
                    (controller.isOlderMessagesLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (controller.isOlderMessagesLoading.value && index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final offset =
                      controller.isOlderMessagesLoading.value ? index - 1 : index;
                  final message = controller.messages[offset];
                  controller.markMessageReadIfNeeded(message);
                  return MessageBubble(
                    message: message,
                    isMine: controller.isMine(message),
                    readStatusText: controller.isMine(message)
                        ? controller.outgoingReadStatus(message)
                        : null,
                    onReply: () => controller.setReply(message),
                  );
                },
              );
            }),
          ),
          Obx(
            () => ChatComposer(
              textController: controller.composerController,
              isSending: controller.isSending.value,
              replyTo: controller.replyTo.value,
              onClearReply: controller.clearReply,
              onSend: controller.sendTextMessage,
            ),
          ),
        ],
      ),
    );
  }
}
