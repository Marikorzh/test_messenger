import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_messenger/main.dart';
import 'package:test_messenger/service/users_data.dart';
import 'package:test_messenger/service/utils.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late Query dbRef;
  bool inFocusHint = false;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerName = TextEditingController();

  void selectImage() async{
    Uint8List img = await pickImage(ImageSource.gallery);
    if(img != null){
      String filePath = await UserData().uploadImageToStorage(widget.userId, img);
      UserData().updateUserPhoto(widget.userId, filePath);
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    state == AppLifecycleState.resumed
        ? UserData().setUserOnlineStatus(widget.userId, true)
        : UserData().setUserOnlineStatus(widget.userId, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<AuthData>(
        future: UserData().re3(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Показуємо індікатор завантаження або інший вміст під час очікування
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Виводимо повідомлення про помилку, якщо є помилка
            return Text('Помилка: ${snapshot.error}');
          } else {
            // Показуємо основний вміст після завершення операції
            AuthData? authData = snapshot.data;
            _controllerName.text = authData!.name;
            // Далі ви можете використовувати uidList для побудови вашого інтерфейсу
            return Center(
              child: SafeArea(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Chat App",
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Column(
                          children: [

                            Stack(
                              children:[
                                Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      20.0),
                                  image: DecorationImage(
                                    image: NetworkImage(authData.avatarLink),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                                Positioned(
                                    child: IconButton(onPressed: (){selectImage();}, icon: Icon(Icons.add_a_photo),),
                                ),
                            ]),

                            SizedBox(
                              height: 5,
                            ),

                            Text(
                              "ID: ${authData?.id}" ?? " ",
                              style: TextStyle(fontSize: 30),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 30,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            controller: _controllerName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(width: 1.5),
                              ),
                            ),
                            onSubmitted: (value) {
                              if (_controllerName.text.isNotEmpty) {
                                UserData().updateUserData(
                                    authData.id, _controllerName.text);
                              }
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 118, left: 50, right: 50, top: 20),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () async {
                                    if (await check(_controller.text)) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                    name: authData.name,
                                                    senderId: widget.userId,
                                                    receiverId:
                                                        _controller.text,
                                                avatarLink: authData.avatarLink,
                                                  )));
                                    } else {
                                      showAlertDialog(context);
                                    }
                                  }),
                              labelText: 'Search Room',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(width: 10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Аttention!'),
          content: Text('This ID does not exist.'),
          actions: [
            TextButton(
              onPressed: () {
                // Закриття попап-повідомлення при натисканні на кнопку
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<bool> check(String userId) async {
    final ref = FirebaseDatabase.instance.ref();
    if (userId != '') {
      final snapshot = await ref.child('users/$userId').get();
      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }
}
