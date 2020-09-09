import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainBody extends StatefulWidget {
  MainBody({Key key, this.id}) : super(key: key);
  final String id;
  @override
  _MainBody createState() => new _MainBody();
}

class _MainBody extends State<MainBody> {
  bool on = false;
  String textValue;
  String passtoken = "";
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  //final ref = FirebaseDatabase.instance.reference().child(widget.id);
  String nightMode;
  //StreamSubscription<Event> _onAddeds;
  StreamSubscription<Event> _onChangeds;

  // void _onChangeddes(Event event) {
  //   print(event.snapshot.key);
  //   setState(() {
  //     if (event.snapshot.key == "nightMode") {
  //       nightMode = event.snapshot.value;
  //     }
  //   });
  // }

  @override
  void initState() {
    void _onChangeddes(Event event) {
      print(event.snapshot.key);
      setState(() {
        if (event.snapshot.key == "value") {
          nightMode = event.snapshot.value;
        }
      });
    }

    //_onAddeds = ref.onChildAdded.listen(_onAdded);
    final ref = FirebaseDatabase.instance.reference().child(widget.id).child("nightMode");
    _onChangeds = ref.onChildChanged.listen(_onChangeddes);

    ref.once().then((DataSnapshot snapshot) {
      print("hello");
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() {
          if (key == "value") {
            nightMode = values;
            if(values == "false"){
              on = false;
            }else{
              on = true;
            }
          }
        });
      });
    });
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      setState(() {
        update(token,widget.id);
      });
    });

    super.initState();
  }

  Future<String> getId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("id");
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, msg['notification']['title'], msg['notification']['body'], platform);
  }

  update(String token, String id) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('$id/fcm-token/$token').set({"token": token});
  }

  @override
  void dispose() {
    //_onAddeds.cancel();
    _onChangeds.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[600],
        title: Text(
          'SMART CRADLE',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      on = !on;
                      DatabaseReference databaseReference =
                          new FirebaseDatabase().reference();
                      databaseReference
                          .child('${widget.id}/nightMode')
                          .set({"value": "$on"});
                    });
                  },
                  child: Center(
                    child: Card(
                      elevation: on?1:15,
                      child: Container(
                          child: Icon(
                            Icons.power_settings_new,
                            size: 100,
                            color: on?Colors.green:Colors.red,
                          ),
                          height: 200,
                          width: 200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                ),
                
              ]),
        ),
      ),
    );
  }
}

/*class Body extends StatelessWidget {
  final SnapshotData items;
 

  const Body({Key key, this.snapshotData}) : super(key: key); 
  @override
  Widget build(BuildContext context) {
    print(snapshotData);
    return SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                  child: Container(
                    height: 80.0,
                    width: 400.0,
                    color: Colors.lightBlueAccent[400],
                    child: Text(
                      'Water Discharged: ${items.dischargevalue} L',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26.0),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 80.0,
                    width: 400.0,
                    color: Colors.lightBlueAccent[400],
                    child: Text('Distance : ${snapshotData.distance} cm ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26.0)),
                  ),
                ),
                Center(
                  child: Container(
                    height: 80.0,
                    width: 400.0,
                    color: Colors.lightBlueAccent[400],
                    child: Text('Flowrate : ${snapshotData.flowrate} LPM',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26.0)),
                  ),
                ),
              ]),
        );
  }

}*/
