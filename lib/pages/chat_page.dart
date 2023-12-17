import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:test_messenger/service/chat_service.dart';
import '../components/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  String senderId;
  String receiverId;
  String name;
  String avatarLink;
  ChatPage({Key? key, required this.senderId, required this.receiverId, required this.name, required this.avatarLink})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>  {
  late String chatRoomId;
  String status = 'Loading...';
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    List<String> ids = [widget.senderId, widget.receiverId];
    ids.sort();
    chatRoomId = ids.join("_");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addScroll();
    });
  }


  TextEditingController _controller = TextEditingController();
  late Query dbRef = FirebaseDatabase.instance.ref().child("rooms/$chatRoomId/messages");

  void addScroll() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }


  Widget _buildMessageItem(Map data) {

    //align the message to the right if the sender is the current user, otherwise to the left
    var alignment = (data["senderId"] == widget.senderId)
        ? Alignment.centerRight
        : Alignment.centerLeft;


    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          crossAxisAlignment: (data["senderId"] == widget.senderId)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: (data["senderId"] == widget.senderId)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            //Text(name),
            ChatBubble(
              name: widget.name,
              msg: data["message"].toString(),
              color: (data["senderId"] == widget.senderId)
                  ? Colors.blueAccent
                  : Colors.black12,
              timestamp: data["timestamp"],
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(widget.avatarLink),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          //title: Text("s"),
          title: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child("users/${widget.receiverId}/status").onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var userInfo = snapshot.data!.snapshot.value;
                var status = userInfo != null ? userInfo.toString() : 'Unknown Status';
                return Text(status == "online" ? "online" : "${ChatService().setTimeOffline(status)}", style: TextStyle(color: Colors.grey, fontSize: 15),);
              } else {
                return Text('Loading...', style: TextStyle(color: Colors.grey),);
              }
            }),
        ),
        body: Container(
          height: double.infinity,
          width: 500,
          child: Column(
            children: [
              SizedBox(height: 20,),
              Expanded(
                child: FirebaseAnimatedList(
                  controller: _scrollController,
                  query: dbRef,
                  itemBuilder: (context, snapshot, animation, index){
                    Map userInfo = snapshot.value as Map;
                    return _buildMessageItem(userInfo);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    suffixIcon:
                    IconButton(icon: Icon(Icons.send), onPressed: () {
                      if(_controller.text != ''){
                      createRecord(widget.senderId, widget.receiverId,
                          _controller.text, (DateTime.now().millisecondsSinceEpoch));
                      addScroll();}
                      _controller.text = "";
                    }),
                    labelText: 'Send message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


void createRecord(String sender, String receiver, String message, int timestamp) {
  List<String> ids = [sender, receiver];
  ids.sort();
  String chatRoomId = ids.join("_");
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('rooms/$chatRoomId/messages');

  databaseReference.push().set({
    'message': message,
    'senderId' : sender,
    'receiverId' : receiver,
    'timestamp' : timestamp,
  });
}
