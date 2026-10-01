import 'package:ecom_delivery_flutter/app/modules/auth/login/controllers/login_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ecom_delivery_flutter/main.dart';

class FireBaseMessagingService extends GetxService {
  late List<String?> numbers;
  final FlutterTts _flutterTts = FlutterTts();

  static const String orderChannelId = 'new_order_channel_v1';

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Important seller notifications',
    importance: Importance.high,
    playSound: true,
  );

  final AndroidNotificationChannel orderChannel =
      const AndroidNotificationChannel(
    orderChannelId,
    'New Orders',
    description: 'Notifications for newly received orders',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('new_order'),
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<FireBaseMessagingService> init() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped: ${response.payload}');
      },
    );

    final androidNotifications =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidNotifications?.createNotificationChannel(channel);
    await androidNotifications?.createNotificationChannel(orderChannel);

    firebaseCloudMessagingListeners();

    return this;
  }

  void firebaseCloudMessagingListeners() {
    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        _handleChatNavigation(message.data);
        type = message.data['notification_type'] != '' &&
                message.data['notification_type'] != null
            ? message.data['notification_type'].toString()
            : message.data['notification_sub_type'].toString();
        print(
            'i am in get initial message function:${message.data['notification_type']}');

        // flutterLocalNotificationsPlugin.show(
        //     message.data.hashCode,
        //     notification.title!,
        //     notification.body!,
        //     NotificationDetails(
        //       android: AndroidNotificationDetails(
        //         channel.id,
        //         channel.name,
        //         // channel.description,
        //         // TODO add a proper drawable resource to android, for now using
        //         //      one that already exists in example app.
        //         // icon: message.notification!.android!.smallIcon,
        //       ),
        //     ));
        // if (type == '') {
        //   if (message.data.isNotEmpty) {
        //     if (message.data['notification_type'].toString() == '1') {
        //       Get.toNamed(Routes.OFFER, arguments: message.data['notification_type'].toString());
        //     }
        //     if (message.data['notification_type'].toString() == '2') {
        //       Get.toNamed(Routes.RECHARGE_REPORT, arguments: message.data['notification_type'].toString());
        //     }
        //     if (message.data['notification_type'].toString() == '3') {
        //       Get.toNamed(Routes.TRANSACTION_HISTORY, arguments: message.data['notification_type'].toString());
        //     }
        //   }
        // }
      }
    });

    FirebaseMessaging.instance
        .requestPermission(sound: true, badge: true, alert: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final title = notification?.title ??
          message.data['title']?.toString() ??
          (_isNewOrder(message.data) ? 'New order received' : 'MyZoo');
      final body = notification?.body ??
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          '';
      final isNewOrder = _isNewOrder(message.data);
      final selectedChannel = isNewOrder ? orderChannel : channel;

      await flutterLocalNotificationsPlugin.show(
        message.messageId?.hashCode ?? message.data.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            selectedChannel.id,
            selectedChannel.name,
            channelDescription: selectedChannel.description,
            importance: isNewOrder ? Importance.max : Importance.high,
            priority: Priority.high,
            playSound: true,
            sound: isNewOrder
                ? const RawResourceAndroidNotificationSound('new_order')
                : null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: isNewOrder ? 'new_order.wav' : null,
          ),
        ),
        payload: _notificationPayload(message, title, body),
      );
    });
    print("starting on message opened app function ++++++++++++++++++++++ ");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("i am in on message opened app function ");

      _handleChatNavigation(message.data);
      String? payloadOfOpenedApp =
          message.data['notification_type']?.toString() ?? '';

      // Get.showSnackbar(Ui.notificationSnackBar(
      //   title: notification.title!,
      //   message: notification.body!,
      // ));
      print(
          'on message opened app $payloadOfOpenedApp : ${message.notification?.title ?? ''}');
      print("on message opened app 7777777 ");
      // flutterLocalNotificationsPlugin.show(
      //     message.data.hashCode,
      //     notification.title!,
      //     notification.body!,
      //     NotificationDetails(
      //       android: AndroidNotificationDetails(
      //         channel.id,
      //         channel.name,
      //         // channel.description,
      //         // TODO add a proper drawable resource to android, for now using
      //         //      one that already exists in example app.
      //         // icon: message.notification!.android!.smallIcon,
      //       ),
      //     ));
    });
  }

  bool _isNewOrder(Map<String, dynamic> data) {
    final notificationType = (data['type'] ??
            data['notification_type'] ??
            data['notification_sub_type'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    return notificationType == 'order_created' ||
        notificationType == 'new_order' ||
        notificationType == 'new-order';
  }

  String _notificationPayload(
    RemoteMessage message,
    String title,
    String body,
  ) {
    if (title.contains('Robi Recharge') ||
        title.contains('Airtel Recharge') ||
        title.contains('Teletalk Recharge')) {
      return body;
    }

    return (message.data['notification_type'] ?? message.data['type'] ?? '')
        .toString();
  }

  void _handleChatNavigation(Map<String, dynamic> data) {
    final notificationType =
        (data['type'] ?? data['notification_type'] ?? '').toString();
    final conversationId =
        (data['conversation_id'] ?? data['conversationId'] ?? '').toString();

    if (notificationType != 'chat' || conversationId.isEmpty) return;
    if (Get.currentRoute == Routes.SHOP_CHAT_THREAD) return;

    Get.toNamed(
      Routes.SHOP_CHAT_THREAD,
      arguments: {'conversation_id': conversationId},
    );
  }

  static Future<void> setDeviceToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    Get.find<LoginController>().deviceToken.value = token ?? '';
  }

  Future<bool> extractNumbersFromString(String input) async {
    RegExp regExp = RegExp(r'\d+');
    numbers = regExp.allMatches(input).map((match) => match.group(0)).toList();
    return true;
  }

  void onSelectNotification(String? payload) async {
    print("I am in onselect notification function $payload");

    // Map notificationModelMap = jsonDecode(payload!);
  }

  Future<void> _speak(String text) async {
    print("i am talking to you >>>>>>>>>");
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }
}
