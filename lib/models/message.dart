import 'dart:io' as io;
import 'dart:math';
import 'package:chato/models/connect.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:chato/models/queue.dart';
class Message {
  final String id;
  final String from;
  String text;
  String status = 'none';
  final String ref;
  DateTime date;

  Message(this.id, this.ref, this.from,this.text,this.status, this.date);

  static Database _db;

  static const String TABLE = 'messages';
  static const String ID = 'id';
  static const String REF = 'ref';
  static const String FROM = 'sender';
  static const String TEXT = 'text';
  static const String DATE = 'DATE';
  static const String STATUS = 'status';
  static const String DB_NAME = 'messages.db';

  static Future<Database> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  static initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  static _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE($ID TEXT PRIMARY KEY ,$REF TEXT, $FROM TEXT, $TEXT TEXT, $STATUS TEXT ,$DATE DATE)");
  }

  /////////////////////////////////////****************************///////////////////////////////////////////

  static Future<List<Message>> fetchAll() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
        TABLE, columns: [ID, REF, FROM, TEXT,STATUS, DATE]);
    List<Message> users = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        users.add(Message(maps[i][ID], maps[i][REF], maps[i][FROM],
            maps[i][TEXT], maps[i][STATUS], DateTime.parse(maps[i][DATE])));
      }
    }
    return users;
  }

  static Future<Message> fetchById(String userId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
        TABLE, columns: [ID, REF, FROM, TEXT,STATUS, DATE],
        where: '$ID = ?', whereArgs: [userId]);
    if (maps.length > 0) {
      return Message(
          maps[0][ID], maps[0][REF], maps[0][FROM], maps[0][TEXT],maps[0][STATUS],
          DateTime.parse(maps[0][DATE]));
    }
    return null;
  }

  static add(String id, String ref, String from, String text,String status ,DateTime date) async {
    var dbClient = await db;
    try{
    await dbClient.insert(TABLE, {
      ID: id,
      REF: ref,
      FROM: from,
      TEXT: text,
      STATUS: status,
      DATE: date.toIso8601String()
    });}catch(e){
      if (id != null)await Connect.delete(id);
      rethrow;
    }
  }
  static updateStatus(String id,String status) async{
    var dbClient = await db;
    await dbClient.update(TABLE,
        {STATUS : status},
        where: '$ID = ?', whereArgs: [id]);
  }
  static Future<List<Message>> fetchByUsername(String username) async {
    var dbClient = await db;
    try {
      List<Map> maps = await dbClient.query(
          TABLE, columns: [ID, REF, FROM, TEXT, STATUS, DATE],
          where: '$FROM = ?', whereArgs: [username]);
      List<Message> messages = [];
      if (maps.length > 0) {
        for (int i = 0; i < maps.length; i++) {
          messages.add(Message(maps[i][ID], maps[i][REF], maps[i][FROM],
              maps[i][TEXT], maps[i][STATUS], DateTime.fromMillisecondsSinceEpoch(DateTime.parse(maps[i][DATE]).millisecondsSinceEpoch)));
        }
        return messages;
      }
    }catch(e){
      return [];
    }

    return [];
  }

  static update(String id,Message message) async{
    var dbClient = await db;
    await dbClient.update(TABLE,
        {ID : message.id,REF : message.ref,TEXT : message.text,FROM : message.from,STATUS : message.status,DATE : message.date.toIso8601String()},
        where: '$ID = ?', whereArgs: [id]);
  }
  sendSeen() async{
    if(this.status == 'none' ){
      Queue.push(this.id);
      updateStatus(this.id, 'read');
    }
  }
}