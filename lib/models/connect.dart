import 'dart:convert';
import 'dart:io';
import 'package:chato/models/message.dart';
import 'package:chato/models/queue.dart';
import 'package:chato/models/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notification;
import 'package:path_provider/path_provider.dart';

import 'config.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
class Connect {
  static bool bussy = false;
  static final _baseURL = 'https://dardasha.herokuapp.com/api';
  static final  notification.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = notification.FlutterLocalNotificationsPlugin();


  static Future<String> login(String username, String password) async {
    http.Response response = await http.post(_baseURL + '/user/login', body: {
      'username': username,
      'password': password
    }, headers: {
      'charset': 'utf-8'
    });
    String res = response.body;

    if (response.statusCode == 200) {
      if (res != null) {
        Map<String, dynamic> data = json.decode(res);
        String id = data['_id'] as String;
        String token = data['auth-token'] as String;
        await Config.setId(id);
        await Config.setToken(token);
        return 'done';
      } else
        return 'none';
    }
    return res.toString();
  }

  static Future<String> register(String name, String username,
      String password) async {
    http.Response response = await http.post(
        _baseURL + '/user/register', body: {
      'name': name,
      'username': username,
      'password': password
    }, headers: {
      'charset': 'utf-8'
    });
    String res = response.body;

    if (response.statusCode == 200) {
      if (res != null) {
        Map<String, dynamic> data = json.decode(res);
        String id = data['_id'] as String;
        String token = data['auth-token'] as String;
        await Config.setId(id);
        await Config.setToken(token);
        return 'done';
      } else
        return 'none';
    }
    return res.toString();
  }

  static getMessages() async {
    if(bussy)return;
    bussy = true;
    String res;
    Map<String, dynamic> data;
    String token = await Config.authToken;
    do {
      try {
        http.Response response = await http.get(
            _baseURL + '/messages/text', headers: {
          'charset': 'utf-8',
          'auth-token': token
        });
        res = response.body;
        if (res == "no messages" || res == null){bussy=false; return;}
        if (response.statusCode == 200) {
          if (res != null) {
            data = json.decode(res);
            String text = data['text'] as String;
            String status = 'none';
            if (text == 'sent' || text == 'delevered' || text == 'seen') {
              Message.updateStatus(data['ref'], text);
//            continue;
            } else {
              await Message.add(
                  data['_id'], data['ref'], data['from'], text, status,
                  DateTime.fromMillisecondsSinceEpoch(DateTime.parse(
                      data['date']).millisecondsSinceEpoch)
                  );
              if ((await User.fetchByUsername(data['from'])) == null) {
                User u = await getUser(data['from']);
                if (u != null) {
                  if(u.profileImage != 'none')u.profileImage = await updateProfileImage( u.profileImage);
                  await User.add(
                      u.id, u.name, u.username, u.about, u.v, u.profileImage, u.lastseen);
                }
              }
              List<User> users = await User.fetchAll();
              int index = 0;
              for(int i =0;i<users.length;i++){
                if(users[i].username == data['from'])index=i;
              }
              var androidPlatformChannelSpecifics = notification.AndroidNotificationDetails(
                  'chato', 'chato', ' chato channel description',
                  importance: notification.Importance.Max, priority: notification.Priority.High, ticker: 'ticker');
              var iOSPlatformChannelSpecifics = notification.IOSNotificationDetails();
              var platformChannelSpecifics = notification.NotificationDetails(
                  androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
              await flutterLocalNotificationsPlugin.show(
                  index, data['from'], text, platformChannelSpecifics,
                  payload: data['from']);
            }
            await delete(data['_id']);
          }
        }
      }catch (e) {
        bussy = false;
//       if (data != null && data['_id'] != null)await delete(data['_id']);
        debugPrint('Connect get Messages'+e.toString());
        return;
      }
    } while (res != "no messages" && res != null);
    bussy = false;
  }

    static delete(String id)async{
    try {
      if (id == null) return;
      String token = await Config.authToken;
      http.Response response = await http.post(
          _baseURL + '/messages/delete/text', body: {
        '_id': id
      },
          headers: {
            'charset': 'utf-8',
            'auth-token': token
          });
    }catch(e){
      debugPrint('connect delete'+e);
    }
    }

    static Future<User> getUser(String username)async{

    try {
    String token = await Config.authToken;

    http.Response response = await http.get((_baseURL+'/user/' + username),headers: {
    'charset':'utf-8',
    'auth-token': token
    });
    String res = response.body;
    if(response.statusCode == 200){
    if( res!= null) {
    Map<String, dynamic> data = json.decode(res);
    return User(data['_id'], data['name'], data['username'], data['about'], data['__v'] as int, data['profileImage'], DateTime.fromMillisecondsSinceEpoch(DateTime.parse(
        data['lastseen']).millisecondsSinceEpoch));
    }
    }}catch (e){
      debugPrint('connect get user'+e.toString());
    }
    return null;
    }

    static Future<String> updateProfileImage( String url)async {
    if (url == null)return null;
    try {
      var response = await http.get(url); // <--2
      var documentDirectory = await getApplicationDocumentsDirectory();
      var firstPath = documentDirectory.path + "/profile_images";
      var filePathAndName = firstPath +
          url.substring(url.lastIndexOf('/'));
      //comment out the next three lines to prevent the image from being saved
      //to the device to show that it's coming from the internet
      await Directory(firstPath).create(recursive: true); // <-- 1
      File file2 = new File(filePathAndName); // <-- 2
      file2.writeAsBytesSync(response.bodyBytes);
      return filePathAndName;
    }catch(e){
      debugPrint('download profile image'+e);return 'none';
    }

    }

    static sendMessages()async{
    String _id;
      try {
      String token = await Config.authToken;
      List<String> queue = await Queue.queue ?? [];
      if(queue.isEmpty)return;

        for (String id in queue) {
          _id = id;
          Queue.delete(id);
          Message message = await Message.fetchById(id);
          String ref ,text;
          if(message.status == 'queued'){
            ref = 'none';
            text = message.text;
          }else if(message.status == 'none' || message.status == 'read'){
            text = 'seen';
            ref = message.id;
          }
          http.Response response = await http.post(
              (_baseURL + '/messages/send/' + message.from + '/text'), body: {
            'text': text,
            'ref': ref
          },
              headers: {
                'charset': 'utf-8',
                'auth-token': token
              });
          String res = response.body;
          if (res ==  null )Queue.push(_id);
          else if (response.statusCode < 300) {
            if (res != null) {
              Map<String, dynamic> data = json.decode(res);
              if(message.status == 'queued') {
                Message.update(id, Message(
                    data['_id'], data['ref'], message.from, message.text,
                    'sent',
                    DateTime.fromMillisecondsSinceEpoch(
                    DateTime.parse(
                        data['date']).millisecondsSinceEpoch)));
              }else if(message.status == 'none'){
                Message.updateStatus(message.id, 'read');
              }
            }
          }else{
            Queue.push(_id);
          }
        }
      }catch(e){
        Queue.push(_id);
        debugPrint('connect.send'+e.toString());
      }
}
  static updateUser(User user)async{
    User user2 = await getUser(user.username);
    if(user2 == null )return;
    if(user2.username != user.username)return;
    if(user.v != user2.v ){
      debugPrint(user2.profileImage);
      user2.profileImage = await updateProfileImage(user2.profileImage);
    }else{
      user2.profileImage = user.profileImage;
    }

    await User.update(user.id, user2);
  }


}