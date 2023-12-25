import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_messenger/pages/home_page.dart';
import 'package:test_messenger/service/users_data.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var user = FirebaseAuth.instance.currentUser;
  final UserData userData = UserData();
  late Future<List<String>> userDataFuture;

  @override
  void initState() {
    super.initState();
    userDataFuture = userData.readDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<List<String>>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            return CircularProgressIndicator();
          }
          else if (snapshot.hasError) {
            return Text('Помилка: ${snapshot.error}');
          }
          else if (snapshot.hasData) {
            List<String> uidList = snapshot.data ?? [];
            if(!uidList.contains(user!.uid) && uidList.isNotEmpty){
              userData.createRecord(user!.uid);
              print("New");
            }
            else {
              print("Old");
            }
            userData.setUserOnlineStatus(user!.uid.substring(0,4), true);

            return HomePage(userId: user!.uid.toString().substring(0,4));
          }
          else{return Container(child: Text("initiation Error"),);}
        },
      ),
    );
  }
}


class AuthData{
  String uid;
  String name;
  String id;
  String avatarLink;

  AuthData({required this.uid, required this.name, required this.id, required this.avatarLink});

  Map<String, dynamic> toMap(){
    return {
      "uid": uid,
      "name": name,
      "id" : id,
      "avatarLink" : avatarLink,
    };
  }
}
