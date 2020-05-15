import 'dart:async';

import 'package:chato/models/config.dart';
import 'package:chato/models/connect.dart';
import 'package:chato/models/message.dart';
import 'package:chato/models/user.dart';
import 'package:chato/myApp.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NewChat extends StatefulWidget {
  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  User dummtUser = User('hj','kjk','jhjh','jhjh',0,'jhjh',DateTime.now());
  User user = User('hj','kjk','jhjh','jhjh',0,'jhjh',DateTime.now());
  Color color;
  Color color2;
  TextStyle inputStyle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('New Chat'),
      ),
      body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
        child:Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20,),
          _buildNewChatComposer(),
          SizedBox(height: 10,),
          Expanded(child:Container(
            decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
            ),
            child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
            child: Center(
              child:Builder(
    builder: (context){
      if(user == null || user.name == null)
        return Text('Invalid User',style: Theme.of(context).textTheme.body2,);
      if(user.name == 'kjk')
        return Text('Type username and press search button',style: Theme.of(context).textTheme.body2,);
      if(user.name == 'loading')
        return CircularProgressIndicator();
      return GestureDetector(
        onTap: ()async{
          await User.add(user.id, user.name, user.username, user.about, user.v, user.profileImage, user.lastseen);
          await Message.add(await Config.messageCount, 'none', user.username, 'You are now connected on chato', 'read', DateTime.now());
          await user.updateMessages();
          Navigator.popAndPushNamed(context, ChatRoute,arguments: {'user':user});
        },
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Hero(
            tag:'Profile-'+user.username,
            child:CircleAvatar(
              radius: 80.0,
              backgroundColor: Theme.of(context).cardColor,
              backgroundImage: user.profileImage == 'none'?AssetImage('assets/images/profile0.jpg'):FileImage(File(user.profileImage)),
            ),
          ),
      Text('  '),
      Text('Username:  '+user.username,style: Theme.of(context).textTheme.body2,),
      Text('Name:  '+user.name,style: Theme.of(context).textTheme.body2,),
      Text('Bio: '+user.about,style: Theme.of(context).textTheme.body2,),
        ],
      ),);
    },
    ),))
            ,))
        ],
      ),
    ));
  }


TextEditingController newChatController = new TextEditingController(text: '');

Widget _buildNewChatComposer(){
  if(color2==null){
    color = Theme.of(context).backgroundColor;
    color2 = Theme.of(context).primaryColor;
    inputStyle = Theme.of(context).textTheme.subhead;
  }
  return Container(
    margin: EdgeInsets.all(2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      color: color,
      boxShadow: [BoxShadow(color: const Color(0x10000000),blurRadius: 3,spreadRadius: 0.2)],
    ),
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    height: 60.0,
    child: Row(children: <Widget>[
      SizedBox(width: 20,),
      Expanded(
        child: TextField(
          onChanged:  (s){
            if(newChatController.text.isEmpty){
              setState(() {
                color = Theme.of(context).backgroundColor;
                color2 = Theme.of(context).primaryColor;
                inputStyle = Theme.of(context).textTheme.subhead;
              });
            }else{
              setState(() {
                color2 = Theme.of(context).backgroundColor;
                color = Theme.of(context).primaryColor;
                inputStyle = inputStyle = TextStyle(color: color2);
              });

            }
          },
          style: inputStyle,
          controller: newChatController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration.collapsed(
            hintText: 'Add by Username',
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.search,color: color2,),
        iconSize: 25.0,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          user = dummtUser;
          if(newChatController.text.isEmpty)return;
          setState(() {
            user.name = 'loading';
          });
          User u = await Connect.getUser(newChatController.text);
          if(u!=null &&u.profileImage != 'none')u.profileImage = await Connect.updateProfileImage(u.profileImage);
          newChatController.text='';
          setState(() {
            this.user = u;
            color = Theme.of(context).backgroundColor;
            color2 = Theme.of(context).primaryColor;
            inputStyle = Theme.of(context).textTheme.subhead;
          });
          }
      )
    ],),
  );
}
}
