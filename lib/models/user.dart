import 'dart:io' as io;
import 'dart:math';
import 'package:chato/models/message.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'config.dart';
import 'package:chato/models/queue.dart';
class User {
  final String id;

  List<Message> messages ;

  String name;
  String about;
  int v;
  final String username;
  String profileImage;
  DateTime lastseen;

  User(this.id, this.name, this.username,this.about,this.v, this.profileImage,
      this.lastseen);



  static Database _db;


  static const String TABLE = 'users';
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String ABOUT = 'about';
  static const String V = 'v';
  static const String USERNAME = 'username';
  static const String PROFILE_IMAGE = 'profileImage';
  static const String LAST_SEEN = 'lastSeen';
  static const String DB_NAME = 'users.db';

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
        "CREATE TABLE $TABLE($ID TEXT PRIMARY KEY ,$PROFILE_IMAGE TEXT, $NAME TEXT, $USERNAME TEXT, $ABOUT TEXT ,$V INTEGER ,$LAST_SEEN DATE)");
  }

  /////////////////////////////////////****************************///////////////////////////////////////////

  static Future<List<User>> fetchAll() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
        TABLE, columns: [ID, USERNAME, NAME, ABOUT, V, PROFILE_IMAGE, LAST_SEEN]);
    List<User> users = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        User u = User(maps[i][ID], maps[i][NAME], maps[i][USERNAME], maps[i][ABOUT], maps[i][V],
            maps[i][PROFILE_IMAGE], DateTime.parse(maps[i][LAST_SEEN]));
        await u.updateMessages();
        users.add(u);
      }
    }
    return users;
  }

  static Future<User> fetchById(String userId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
        TABLE, columns: [ID, USERNAME, ABOUT, V, NAME, PROFILE_IMAGE, LAST_SEEN],
        where: '$ID = ?', whereArgs: [userId]);
    if (maps.length > 0) {
      User u = User(
          maps[0][ID], maps[0][NAME], maps[0][USERNAME], maps[0][ABOUT],maps[0][V], maps[0][PROFILE_IMAGE],
          DateTime.parse(maps[0][LAST_SEEN]));
      await u.updateMessages();
      return u;
    }
    return null;
  }
static Future<User> fetchByUsername(String username) async {
    var dbClient = await db;
    try{
    List<Map> maps = await dbClient.query(
        TABLE, columns: [ID, USERNAME, NAME, ABOUT, V, PROFILE_IMAGE, LAST_SEEN],
        where: '$USERNAME = ?', whereArgs: [username]);
    if (maps.length > 0) {
      User u = User(
          maps[0][ID], maps[0][NAME], maps[0][USERNAME], maps[0][ABOUT],maps[0][V], maps[0][PROFILE_IMAGE],
          DateTime.parse(maps[0][LAST_SEEN]));
      await u.updateMessages();
      return u;
    }}catch(e){return null;}
    return null;
  }

  static add(String id, String name, String username, String about, int v, String profileImage,
      DateTime lastSeen) async {
    var dbClient = await db;
    await dbClient.insert(TABLE, {
      ID: id,
      NAME: name,
      USERNAME: username,
      ABOUT: about,
      V: v,
      PROFILE_IMAGE: profileImage,
      LAST_SEEN: lastSeen.toIso8601String()
    });
  }

  static update(String id,User user) async{
    var dbClient = await db;
    await dbClient.update(TABLE,
        {ID : user.id,NAME : user.name,USERNAME : user.username ,ABOUT : user.about,V : user.v,PROFILE_IMAGE : user.profileImage,LAST_SEEN : user.lastseen.toIso8601String()},
        where: '$ID = ?', whereArgs: [id]);
  }

  static Future<User> getCurrentUser()async{
    User u = await fetchById(await Config.userId);
    await u.updateMessages();
    return u;
  }

  updateMessages() async{
    this.messages = (await  Message.fetchByUsername(this.username)).reversed.toList();
  }

  static sendMessage(String text,String ref,String from)async{
    String id = await Config.messageCount;
    await Message.add(id,ref,from,text,'queued',DateTime.now());
    Queue.push(id);
  }
}