import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hey_chat/model/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hey_chat/navigation/wrapper.dart';
import 'package:provider/provider.dart';

import 'services/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // STATUS BAR
    statusBarColor: Colors.transparent,
    systemStatusBarContrastEnforced: false,
    // iOS only
    statusBarBrightness: Brightness.dark,
    // Android only
    statusBarIconBrightness: Brightness.dark,
    
    // // BOTTOM NAVIGATION
    // systemNavigationBarColor: Colors.transparent,
    // // systemNavigationBarDividerColor: Colors.transparent, // DON'T USE THIS (CAUSING statusBarText can't change)
    // systemNavigationBarIconBrightness: Brightness.dark,
    // systemNavigationBarContrastEnforced: false
  ));
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

  await Firebase.initializeApp();
  await requestPermission();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider.value(initialData: null, value: AuthService().user)
        ],
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.red
          ),
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
        ));
  }
}

Future requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    await loadFCM();
  } else if (settings.authorizationStatus ==
      AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }


}

Future loadFCM() async {
  if (!kIsWeb) {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      enableVibration: true,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await listenFCM(flutterLocalNotificationsPlugin, channel);
  }
}

Future listenFCM(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel channel) async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}