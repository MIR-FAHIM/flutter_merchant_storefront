import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/views/widgets/shop_chat_widgets.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationListView extends GetView<ShopChatController> {
  const ConversationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111213),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Customer Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.refreshConversations,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isConversationLoading.value &&
            controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.conversationError.value.isNotEmpty &&
            controller.conversations.isEmpty) {
          return ChatEmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load chats',
            message: controller.conversationError.value,
            onRetry: controller.refreshConversations,
          );
        }

        if (controller.conversations.isEmpty) {
          return const ChatEmptyState(
            icon: Icons.forum_outlined,
            title: 'No customer conversations yet',
            message: 'New customer messages will appear here for your shop.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshConversations,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 120) {
                controller.loadConversations();
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.conversations.length +
                  (controller.isConversationLoading.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.conversations.length) {
                  return const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final conversation = controller.conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    Get.toNamed(
                      Routes.SHOP_CHAT_THREAD,
                      arguments: {'conversation': conversation},
                    );
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
