import 'dart:async';

import 'package:chato/models/config.dart';
import 'package:chato/myApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chato/models/connect.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  String message = '';
  Timer timer;
  _LoginState(){
    timer = Timer.periodic(Duration(seconds: 4), (t)async{
      if (await Config.userId != null ) {
        t.cancel();
        Navigator.pushNamedAndRemoveUntil(context, ChatsRoute,(r)=>false);}
    });
  }
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height-580,bottom: 20),
            child: Text('LOGIN',textAlign: TextAlign.center,style: Theme.of(context).textTheme.title),
          ),
          Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 130),
          child:Container(
            height: 460,
              padding: EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 110),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(message,style: Theme.of(context).textTheme.body2,textAlign: TextAlign.center,),
                  TextField(
                    cursorColor: Color(0xFFFF9980),
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'username'
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.visiblePassword,
                    dragStartBehavior: DragStartBehavior.start,
                    controller: passwordController,
                    cursorColor: Color(0xFFFF9980),
                    decoration: InputDecoration(
                      hasFloatingPlaceholder: true,

                      border: OutlineInputBorder(),
                      labelText: 'password'
                    ),
                  ),
                  Builder(builder:(context) => RaisedButton(
                      child: Text('Login',style: TextStyle(
                        color: Color(0xFFFFFFFF),
                      ),),
                    color: Theme.of(context).buttonColor,
                    onPressed:() => _login(context),
                  ),),
                  GestureDetector(
                    child: Text('Dont have account ?',style: Theme.of(context).textTheme.body2,textAlign: TextAlign.center,),
                    onTap: () => Navigator.pushNamedAndRemoveUntil(context, RegisterRoute,(r)=>false),
                  )
                ],
              ),
            )),
            Hero(
              tag:'logoAvatar',
              child: Center(
              child: CircleAvatar(
                radius:80,
                backgroundColor: Theme.of(context).backgroundColor,
                child: Image.asset('assets/images/ic_launcher.png',fit: BoxFit.fill,)),),),
          ]),
        ],
      ),
    );
  }
  _login(BuildContext context) {
    if(usernameController.text.isEmpty || passwordController.text.isEmpty){
      setState(() {
        message = "field should not be empty";
      });
    }else if (usernameController.text.contains(' ')) {
      setState(() {
        message = "username should not have spaces";
      });
    }else {
      Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 10),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Container(
          padding: EdgeInsets.all(30),
          height: 300,
          child: FutureBuilder(
            future: Connect.login(usernameController.text, passwordController.text),
            builder: (context,snapshot){
              if(snapshot.connectionState != ConnectionState.done){
                return CircularProgressIndicator();
              }else{

                  message = snapshot.data;



                return Text(snapshot.data);
              }
            },
          ),
        ),
      ));

    }
    setState(() {

    });
  }
}
