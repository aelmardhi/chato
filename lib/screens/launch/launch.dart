import 'package:chato/models/config.dart';
import 'package:chato/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chato/myApp.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Launch extends StatefulWidget {
  @override
  _LaunchState createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  String s;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;


  _LaunchState(){
    Config.userId.then((v)async{
      notificationAppLaunchDetails =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

      var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
      // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
      // of the `IOSFlutterLocalNotificationsPlugin` class
      var initializationSettingsIOS = IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
          });
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (String payload) async {
            if (payload != null) {
//              debugPrint('notification payload:' + payload+'.................************************');
            User u = await User.fetchByUsername(payload);
            debugPrint(u.username);
              navigatorKey.currentState.pushNamedAndRemoveUntil(ChatsRoute,(r)=>false);
              navigatorKey.currentState.pushNamed(ChatRoute,arguments: {'user':u});}
          });

      if(v== null) {
        Navigator.pushNamedAndRemoveUntil(context, LoginRoute,(r)=>false);
      }else{
        Navigator.pushNamedAndRemoveUntil(context, ChatsRoute,(r)=>false);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
      padding: EdgeInsets.all(50),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child:Hero(
          tag:'logoAvatar',
          child: Center(
                child: Image.asset('assets/images/ic_launcher.png',fit: BoxFit.fill,)),),),
    ));
  }
}
