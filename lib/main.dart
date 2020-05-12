import 'package:flutter/material.dart';
import 'myApp.dart';
import 'package:async/async.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'models/connect.dart';



void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  bool a =await AndroidAlarmManager.initialize();


  runApp(MyApp());
  await AndroidAlarmManager.periodic(const Duration(minutes : 5), 0, _service,exact: true,wakeup: true,rescheduleOnReboot: true);
}
void _service() async {
  Connect.getMessages();
  Connect.sendMessages();
}


