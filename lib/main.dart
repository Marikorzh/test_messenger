import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_messenger/pages/home_page.dart';
import 'package:test_messenger/service/users_data.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
  User? user = userCredential.user;

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;

  MyApp({Key? key, required this.user}) : super(key: key);
  final UserData userData = UserData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<List<String>>(
        future: userData.readDataUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Помилка: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List<String> uidList = snapshot.data ?? [];
            if (!uidList.contains(user!.uid) ) {
              userData.createRecord(user!.uid);
              print("New");
            } else {
              print("Old");
            }
            //userData.createRecord(user!.uid);
            userData.setUserOnlineStatus(user!.uid.substring(0, 4), true);

            return HomePage(userId: user!.uid.toString().substring(0, 4));
          } else {
            return Container(child: Text("Initialization Error"),);
          }
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
