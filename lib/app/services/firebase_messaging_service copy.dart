// import 'package:get/get.dart';
//
//
// import '../../common/ui.dart';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
//
//
//
// class FireBaseMessagingService extends GetxService {
//   Future<FireBaseMessagingService> init() async {
//     firebaseCloudMessagingListeners();
//     return this;
//   }
//
//   void firebaseCloudMessagingListeners() {
//     ///gives you the message on which user taps
//     ///and it opened the app from terminated state
//     FirebaseMessaging.instance.getInitialMessage().then((message) async {
//       if (message != null) {
//         RemoteNotification notification = message.notification!;
//
//         // var bodyData = jsonDecode(message.data['body']);
//         //
//         // if (bodyData['type'] == 'order') {
//         //   print('hello');
//         //   print('clicked data ${bodyData['order_id']}');
//         //
//         //   var orderId = bodyData['order_id'];
//         //
//         //
//         // }
//
//         Get.showSnackbar(Ui.defaultSnackBar(
//           title: notification.title!,
//           message: notification.body!,
//         ));
//       }
//     });
//
//     FirebaseMessaging.instance
//         .requestPermission(sound: true, badge: true, alert: true);
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       RemoteNotification notification = message.notification!;
//
//       Get.showSnackbar(Ui.defaultSnackBar(
//         title: notification.title!,
//         message: notification.body!,
//       ));
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       RemoteNotification notification = message.notification!;
//
//       Get.showSnackbar(Ui.defaultSnackBar(
//         title: notification.title!,
//         message: notification.body!,
//       ));
//     });
//   }
//
//   Future<void> setDeviceToken() async {
//
//   }
// }
