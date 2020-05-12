
import 'dart:async';
import 'dart:io';
import 'package:chato/models/connect.dart';
import 'package:chato/models/message.dart';
import 'package:chato/models/user.dart';
import 'package:chato/myApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  Timer timer;
  List<User> users = [User('l','l','l','l',0,'2',DateTime.now())];
  _ChatsState(){
     User.fetchAll().then((v){
       v.sort((a,b){
         return  b.messages.first.date.compareTo(a.messages.first.date);
       });
       setState(() {
       users=v;
     });});
    timer = Timer.periodic(Duration(seconds: 2), (t) async {
      Connect.getMessages();
      List<User> users = await User.fetchAll();
      users.sort((a,b){
        if(a.messages == null)a.messages = [];
        if(b.messages == null)b.messages = [];
        return  b.messages.first.date.compareTo(a.messages.first.date);
      });
      setState(() {
        this.users = users;
      });
    });
  }
  @override
  void dispose() {
    timer.cancel();
    users = null;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chato',style: TextStyle(fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          wordSpacing: 0.5,
          letterSpacing: 0.1,
          fontSize: 25,
          color: Colors.white ,),),
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
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.person_add,size: 30,),
        onPressed: ()=>Navigator.pushNamed(context, NewChatRoute),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(vertical: 20),),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
              child:Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                ),
                child: Builder(
                builder: (BuildContext context){
                  if(users.isEmpty)
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Tap the button below to start a chat',style: Theme.of(context).textTheme.body2,textAlign: TextAlign.center,),
                    );

                  else if(users[0].name == 'l')
                  return Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Loading..',style: Theme.of(context).textTheme.body2,textAlign: TextAlign.center,),
                  );
                  else return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext context,int index){
                        User u = users[index];
                        if (u.messages == null)u.messages = [];
                            Message m = u.messages.first;
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(context, ChatRoute,arguments: {'user':u}),
                                child: Container(
                            margin: EdgeInsets.only(top: 5.0,bottom: 5.0,right: 2.0),
                            padding: EdgeInsets.only(bottom: 10,left: 20,top: 10,right: 10),
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(color:const Color(0x50550000),spreadRadius: 0,blurRadius: 0.5,)],
                                color: Theme.of(context).cardColor,
                                borderRadius:BorderRadius.all( Radius.circular(10.0))
                              ),
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                    children:[
                                Hero(
                                  tag:'Profile-'+u.username,
                                  child:CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Theme.of(context).cardColor,
                                  backgroundImage: u.profileImage == 'none'?AssetImage('assets/images/profile0.jpg'):FileImage(File(u.profileImage)),
                                ),
                                ),SizedBox(width: 10.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(width:MediaQuery.of(context).size.width * 0.5,child:
                                        RichText(
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(text: u.name,style: Theme.of(context).textTheme.body1,
                                            children: [
                                              TextSpan(text:' @'+u.username,style: Theme.of(context).textTheme.caption,)
                                            ],),),
                                    ),
                                    SizedBox(width: 5.0,),
                                    Container(
                                    child:Row(children:[
                                      Builder(
                                        builder: (BuildContext context){
                                          switch(m==null?'':m.status){
                                            case 'seen':
                                              return Icon(Icons.remove_red_eye,color: Theme.of(context).canvasColor,size: Theme.of(context).textTheme.subtitle.fontSize);
                                              break;
                                            case 'delevered':
                                              return Icon(Icons.check_circle,color: Theme.of(context).textTheme.subtitle.color,size: Theme.of(context).textTheme.subtitle.fontSize);
                                              break;
                                            case 'sent':
                                              return Icon(Icons.check_circle_outline,color: Theme.of(context).textTheme.subtitle.color,size: Theme.of(context).textTheme.subtitle.fontSize);
                                              break;
                                            case 'queued':
                                              return Icon(Icons.schedule,color: Theme.of(context).textTheme.subtitle.color,size: Theme.of(context).textTheme.subtitle.fontSize,);
                                              break;
                                          }
                                          return Text('');
                                        },
                                      ),
                                      Container(width:MediaQuery.of(context).size.width * 0.45,child:
                                      Text(m==null?'  ':'  '+m.text,style: Theme.of(context).textTheme.subtitle,overflow: TextOverflow.ellipsis,),),
                                ]))],
                                ),]),Column(children: <Widget>[
                                Text(m==null?'':_formatDate(m.date),style: Theme.of(context).textTheme.caption,overflow: TextOverflow.ellipsis,),
                                  SizedBox(height: 10,),
                                  Builder(builder: (context){
                                    int count = 0;
                                    if(users[index].messages == null)users[index].messages =[];
                                    users[index].messages.forEach((m){
                                      if(m.status == 'none')count++;
                                    });
                                    if(count>0)return Container(
                                      padding: EdgeInsets.all(2),
                                      child: Center(child:
                                      Text(count>99?'99+':count.toString(),style: Theme.of(context).textTheme.overline,overflow: TextOverflow.ellipsis,),),
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                    );
                                    return SizedBox(height: 18,width: 30,);
                                  },),
                                ],),
                                ],
                            ))
                            );
                      },
                    );
                },
              ),

            ),
            ),
          )
        ],
      )
    );
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
}
