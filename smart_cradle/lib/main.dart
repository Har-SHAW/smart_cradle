import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_cradle/home/homeScreen.dart';
import 'package:smart_cradle/home/login.dart';

void main() => runApp(MyApp());
Future<bool> get() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String id = pref.getString("id");
  String pass = pref.getString("pass");
  if (id != null && pass != null) {
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: get(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            if(snapshot.data){
              return MainBody();
            }else{
              return LoginThreePage();
            }
          }else{
            return Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width
            );
          }
        },
      ),
    );
  }
}
