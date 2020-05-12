import 'package:chato/screens/chat/chat.dart';
import 'package:chato/screens/chats/chats.dart';
import 'package:chato/screens/newChat/newChat.dart';
import 'package:chato/screens/register/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'style.dart';
import 'package:chato/screens/launch/launch.dart';
import 'package:chato/screens/login/login.dart';

const LaunchRoute = '/';
const LoginRoute = '/login';
const RegisterRoute = '/register';
const ChatsRoute = '/chats';
const ChatRoute = '/chat';
const NewChatRoute = '/newChat';
final GlobalKey<NavigatorState> navigatorKey =
new GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateRoute: _routes(),
      theme: _theme(),
    );
  }
  RouteFactory _routes (){
    return (settings){
      final Map <String, dynamic> arguments = settings.arguments;
      Widget screen ;
      switch(settings.name){
        case LaunchRoute:
          screen= Launch();
          break;
          case LoginRoute:
          screen= Login();
          break;
          case RegisterRoute:
          screen= Register();
          break;
          case ChatsRoute:
          screen= Chats();
          break;
          case ChatRoute:
          screen= Chat(arguments['user']);
          break;
          case NewChatRoute:
          screen= NewChat();
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }

  ThemeData _theme(){
    return ThemeData(
      appBarTheme: AppBarTheme(
          textTheme: TextTheme(title: AppBarTextStyle,),
          color: Color(0xFFFE5050),
      ),
      scaffoldBackgroundColor: Color(0xFFFE5050),
      backgroundColor: Color(0xFFFEF3F1),
      cardColor: Color(0xFFFAFAE0),
      primaryColor: Color(0xFFFE5050),
      accentColor: Color(0xFFFF3040),
      dividerColor: Color(0xFFFFF2AF),
      canvasColor: Color(0xFF33BBFF),
      buttonColor: Color(0xFFFF4455),
      secondaryHeaderColor: Color(0xFFFF99AA),
      primaryColorLight: Color(0xFFFFC3CC),
      textTheme: TextTheme(
        title: TitleTextStyle ,
        body1: Body1TextStyle,
        body2: Body2TextStyle,
        subhead:SubheadStyle,
        subtitle: SubtitleStyle,
        caption: CaptionStyle,
        overline: OverLineStyle
      ),
    );
  }
}

