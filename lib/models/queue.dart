import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Queue {

  static const FILE_NAME = 'queue.json';

  static Future<io.File> get _config async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, FILE_NAME);
    var db = io.File(path);
    if (!await db.exists()){
      await db.create();
      await db.writeAsString(json.encode({}));
    }
    return db;
  }

  static Future<List<String>> get queue async {

    var file = await _config;
    var myjson =await file.readAsString();
    Map<String,String> q ;
    try {
      var data = (json.decode(myjson.toString()) as Map<String,dynamic>).map((k,v) => MapEntry<String,String>(k,v.toString())).values.toList();
      return data ;
    }catch(e){
      debugPrint(e.toString());
    }
    return [];
  }

  static  push (String id) async {
    if (null == id) {
      return;
    }

    var file = await _config;
    var myjson = await file.readAsString();
    var data = (json.decode(myjson.toString())as Map<String,dynamic>).map((k,v) => MapEntry<String,String>(k,v.toString()));
    data.update(id,(a) => id ,ifAbsent:() => id);
    myjson = json.encode(data);
    await file.writeAsString(myjson);
  }

  static  delete (String id) async {
    if (null == id) {
      return;
    }

    var file = await _config;
    var myjson = await file.readAsString();
    var data = (json.decode(myjson.toString())as Map<String,dynamic>).map((k,v) => MapEntry<String,String>(k,v.toString())) ;
    data.remove(id);
    myjson = json.encode(data);
    await file.writeAsString(myjson);
  }
}