import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  //getx Controller를 어디서든 호출하기 위해 생성

  final Rxn<RemoteMessage> message = Rxn<RemoteMessage>();

  //Rx라고도 할 수 있으며 n은 null을 의미한다.
  Future<bool> initialize() async {
    await Firebase.initializeApp();
    //Firebase 앱 객체를 생성
    var token = await FirebaseMessaging.instance.getToken();
    print('-------토큰값 $token');

    // Android 에서는 별도의 확인 없이 리턴되지만, requestPermission()을 호출하지 않으면 수신되지 않는다.
    await FirebaseMessaging.instance.requestPermission(
        alert: true,
        //사용자에게 알림을 표시할 것인지
        announcement: true,
        //AirPod에 연결되었을 때 알림 설정
        badge: true,
        //읽지 않은 알림이 있을 때 아이콘 옆에 알림점이 표시될 지 여부 설정
        carPlay: true,
        //차량 장비에 연결되었을 때 알림 설정  ( 추가적인 정보 필요 )
        criticalAlert: true,
        // ( 추가적인 정보 필요 )
        provisional: true,
        //임시권한이 부여되는지 여부를 설정
        sound: true
        //장치에 알림이 표시될 때 사운드가 들리게 할 것인지 설정
        );

    // foreground에서의 푸시 알림 표시를 위한 알림 중요도 설정
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /**
     * foreground 상태일 때 상단 메시지 보여주기**/

    FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
      message.value = rm;
      RemoteNotification? notification = rm.notification;
      AndroidNotification? android = rm.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                'high_importance_channel',
                // AndroidNotificationChannel()에서 생성한 ID
                'High Importance Notifications',
                channelDescription:
                    'This channel is used for important notifications.'
                // other properties...
                ),
          ),
        );
      }
    });

    // FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
    //   message.value = rm;
    // });
    return true;
  }
}
