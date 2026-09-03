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
  Future<FireBaseMessagingService> init() async {

    firebaseCloudMessagingListeners();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@drawable/notification_icon');
    var initialzationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initialzationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle the notification tap here
        print('Notification tapped: ${response.payload}');
      },);

    return this;
  }

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      // 'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void firebaseCloudMessagingListeners() {
    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        RemoteNotification notification = message.notification!;
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
      RemoteNotification notification = message.notification!;
      print(notification.title!);
      print("I am here");
    //  _speak(notification.body!);
      print('I am in on message function:${message.data['notification_type']}');
      //new added
      // NotificationLocal.showBigTextNotification(title: notification.title!, body: "hlw",
      //     fln: flutterLocalNotificationsPlugin, payload:"3" );
      // new end

      // snackbar

      flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        notification.title!,
        notification.body!,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            // channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            // icon: message.notification!.android!.smallIcon,
          ),
        ),
        payload: notification.title!.contains("Robi Recharge")
            ? notification.body!
            : notification.title!.contains("Airtel Recharge")
                ? notification.body!
                : notification.title!.contains("Teletalk Recharge")
                    ? notification.body!
                    : message.data['notification_type'].toString(),
      );

    });
    print("starting on message opened app function ++++++++++++++++++++++ ");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("i am in on message opened app function ");

      RemoteNotification notification = message.notification!;
      _handleChatNavigation(message.data);
      String? payloadOfOpenedApp =
          message.data['notification_type']?.toString() ?? '';

      // Get.showSnackbar(Ui.notificationSnackBar(
      //   title: notification.title!,
      //   message: notification.body!,
      // ));
      print(
          'on message opened app ${payloadOfOpenedApp} : ${message.notification!.title!}');
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

  Future<void> setDeviceToken() async {
    Get.find<LoginController>().deviceToken.value =
        (await FirebaseMessaging.instance.getToken())!;
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
