import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notification;
import 'package:chato/models/connect.dart';
import 'package:chato/models/message.dart';
import 'package:chato/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  User user;
  Chat(this.user);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Color color;
  Color color2;
  static final  notification.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = notification.FlutterLocalNotificationsPlugin();
  int index = 0;
  TextStyle inputStyle;
Timer timer;
  @override
  void initState() {
    User.fetchAll().then((users){
      for(int i =0;i<users.length;i++){
        if(users[i].username == widget.user.username)index=i;
      }
    });

    timer = Timer.periodic(Duration(seconds: 2), (t) async {
      await flutterLocalNotificationsPlugin.cancel(index);
      Connect.sendMessages();
      Connect.getMessages();
      Connect.updateUser(widget.user);
      User user = await User.fetchByUsername(widget.user.username);
      if (user.messages == null)user.messages = [];
      user.messages.forEach((m)=>m.sendSeen());
      setState(() {
        this.widget.user = user;
      });
    });
    super.initState();
  }
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
      title: Row(children:[
      Container(
        height: 45,width: 45,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).appBarTheme.textTheme.title.color,width: 1) ,
          borderRadius: BorderRadius.circular(30)
        ),
        child:Hero(
      tag:'Profile-'+widget.user.username,
        child:ClipRRect(
            borderRadius: BorderRadius.circular(30),
          child: widget.user.profileImage == 'none'?
              Image.asset('assets/images/profile0.jpg',fit: BoxFit.cover):
              Image.file(File(widget.user.profileImage,),fit: BoxFit.cover,),
        ),),
      ),
        SizedBox(width: 10,),
        Container(width:MediaQuery.of(context).size.width * 0.45,child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Text(widget.user.name,style: Theme.of(context).appBarTheme.textTheme.title,overflow: TextOverflow.ellipsis,),
          Text(_formatDatels(widget.user.lastseen),style: Theme.of(context).textTheme.overline,),
        ],),),
        ]),
    elevation: 0.0,actions: <Widget>[
        Builder(builder:(context)=>
            IconButton(
              onPressed: () => Scaffold.of(context).showSnackBar( _showInfo(),),
              icon: Icon(Icons.more_vert,color: Theme.of(context).appBarTheme.textTheme.title.color,),
              iconSize: 30,
              color: Theme.of(context).appBarTheme.textTheme.title.color,
            ),),
    ],
    ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child:Column(children:[
          SizedBox(height: 20,),
        Expanded(child:Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
          child: ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.only(top: 15.0,bottom: 2),
                  itemCount: widget.user.messages.length,
                  itemBuilder: (BuildContext context , int index){
                    final Message message = widget.user.messages[index];
                    return _buidMessage(message);
                  }
              )
        ),
      ),),
      _buidMessageComposer()
      ],),)
    );
  }
  TextEditingController messageController = new TextEditingController(text: '');
  Widget _buidMessageComposer(){
    if(color2==null){
      color = Theme.of(context).backgroundColor;
      color2 = Theme.of(context).primaryColor;
      inputStyle = Theme.of(context).textTheme.subhead.copyWith(fontSize: 18,height: 2);;
    }
    return Container(
      decoration: BoxDecoration(
        color: color,
        boxShadow: [BoxShadow(color: const Color(0x10000000),blurRadius: 3,spreadRadius: 0.2)],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 3),
      height: 60.0,
      child: Row(children: <Widget>[
        SizedBox(width: 20,),
        Expanded(
          child: TextField(
            onChanged:  (s){
              if(messageController.text.isEmpty){
                setState(() {
                  color = Theme.of(context).backgroundColor;
                  color2 = Theme.of(context).primaryColor;
                  inputStyle = Theme.of(context).textTheme.subhead.copyWith(fontSize: 18,height: 2);
                });
              }else{
                setState(() {
                  color2 = Theme.of(context).backgroundColor;
                  color = Theme.of(context).primaryColor;
                  inputStyle = TextStyle(color: color2,fontSize: 18,height: 2);
                });

              }
            },
            style: inputStyle,
            maxLines: 2,
            keyboardType: TextInputType.multiline,
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration.collapsed(
              hintText: 'Type a message',
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send,color: color2,),
          iconSize: 25.0,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if(messageController.text.isNotEmpty){
              await User.sendMessage(messageController.text,'none',widget.user.username);
              await widget.user.updateMessages();
              setState(() {
                color = Theme.of(context).backgroundColor;
                color2 = Theme.of(context).primaryColor;
                inputStyle = Theme.of(context).textTheme.subhead;
                messageController.text = '';
              });
            }
          },
        )
      ],),
    );
  }

  Widget _buidMessage(Message message){
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.end;
    Icon icon ;
    Color color = Theme.of(context).dividerColor;
    BorderRadius br = BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10),);
    EdgeInsets margin = EdgeInsets.only(bottom: 5.0,top: 2.0,left: 60);
    switch(message.status){
      case 'none':case 'read':
      mainAxisAlignment = MainAxisAlignment.start;
        color = Theme.of(context).primaryColorLight;
        margin = EdgeInsets.only(bottom: 5.0,top: 2.0,right: 60);
        br = BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10),);
        break;
      case 'delevered':
        icon = Icon(Icons.check_circle,color: Theme.of(context).textTheme.subtitle.color,size: Theme.of(context).textTheme.subtitle.fontSize,);
        break;
      case 'seen':
          icon = Icon(Icons.remove_red_eye,color: Theme.of(context).canvasColor,size: Theme.of(context).textTheme.subtitle.fontSize,);
        break;
      case 'sent':
        icon = Icon(Icons.check_circle_outline,color: Theme.of(context).textTheme.subtitle.color,size: Theme.of(context).textTheme.subtitle.fontSize,);
        break;
      case 'queued':
        icon = Icon(Icons.schedule,color: Theme.of(context).textTheme.subtitle.color,size: Theme.of(context).textTheme.subtitle.fontSize,);
        break;
    }
    return  Row(
      mainAxisAlignment: mainAxisAlignment,
      children: <Widget>[Container(
      margin: margin,
      padding: EdgeInsets.symmetric(horizontal: 25.0,vertical: 10.0),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color:const Color(0x20220000),spreadRadius: 0.1,blurRadius: 0.5,)],
        borderRadius: br,
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
      Container(constraints:BoxConstraints(maxWidth: MediaQuery.of(context).size.width-110),child:
          Text(message.text,style: Theme.of(context).textTheme.subhead,)
      ),
          SizedBox(height: 3.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_formatDate(message.date),style: Theme.of(context).textTheme.subtitle,),
              SizedBox(width: 1,),
              Builder(
                builder: (BuildContext context){
                  if(icon == null)return Container();
                  return icon;
                },
              )
            ],
          ),
        ],
      ),
    ) ],);
  }

  SnackBar _showInfo(){
    return SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/ic_launcher.png'),
            Text('Chato',style: Theme.of(context).textTheme.title,),
            Text('aelmardhi © 2020',style: Theme.of(context).textTheme.overline,)
          ],
        )
    );
  }

  String _formatDatels(DateTime date){
    DateTime now = DateTime.now();
    if(date.year == now.year){
      if(date.month == now.month){
        if(date.day == now.day){
          if(date.hour == now.hour){
            if(date.minute >= now.minute ){
              return 'Online';
            }
            int d = now.minute - date.minute;
            return 'lastseen '+d.toString()+' minute'+(d==1?'':'s')+' ago';
          }
          return 'lastseen '+(date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString();
        }
        if(date.day == now.day-1)
          return 'lastseen '+'Yesterday '+(date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString();
      }
      return 'lastseen '+date.day.toString() +'/'+ date.month.toString()+ ' '+(date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString() ;
    }
    return 'lastseen '+date.toIso8601String().substring(0,10);
  }
String _formatDate(DateTime date){
  DateTime now = DateTime.now().toLocal();
  if(date.year == now.year){
    if(date.month == now.month){
      if(date.day == now.day){
        return (date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString();
      }
      if(date.day == now.day-1)
        return 'Yesterday '+(date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString();
    }
    return date.day.toString()+'/'+date.month.toString()+' '+ (date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString();
  }
  return date.toIso8601String().substring(0,10)+' '+(date.hour<10?'0':'') + date.hour.toString()+':'+ (date.minute<10?'0':'') +date.minute.toString();
}
}
