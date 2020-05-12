import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Config {

  static const FILE_NAME = 'config.json';

  static Future<io.File> get _config async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, FILE_NAME);
    var db = io.File(path);
    if (!await db.exists()){
      await db.create();
      await db.writeAsString('{\"message-count\":\"0\"}');
    }
    return db;
  }

  static Future<String> get userId async {
    try {
    var file = await _config;
    var myjson =await file.readAsString();
      var data = json.decode(myjson.toString());
      return data['_id'] ;
    }catch(e){
      return e.toString();
    }

  }
  static Future<String> get authToken async {

    var file = await _config;
    var myjson = await file.readAsString();
    var data = (json.decode(myjson));
    return data['auth-token'] as String;
  }
  static Future<String> get messageCount async {

    io.File file = await _config;
    var myjson = await file.readAsString();
    var data = json.decode(myjson.toString());
    String  s = data['message-count']as String;
    int i = int.parse(s);
    i++;
    data.update('message-count',(a) => i.toString() ,ifAbsent:() => i.toString());
    myjson = json.encode(data);
    await file.writeAsString(myjson,mode: io.FileMode.write);
    return s;
  }

  static  setId (String id) async {
    if (null == id) {
      return;
    }

    var file = await _config;

    var myjson = await file.readAsString();

    var data = json.decode(myjson.toString());
    data.update('_id',(a) => id ,ifAbsent:() => id);
    myjson = json.encode(data);
    await file.writeAsString(myjson);
  }

  static  setToken (String token) async {
    if (null == token) {
      return;
    }

    var file = await _config;
    var myjson =await file.readAsString();
    Map<String, dynamic> data = json.decode(myjson.toString());
    data.update('auth-token',(a) => token ,ifAbsent:() => token);
    myjson = json.encode(data);
    await file.writeAsString(myjson);
  }

}