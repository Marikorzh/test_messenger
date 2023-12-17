import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatService {
  DatabaseReference databaseReference =
  FirebaseDatabase.instance.reference().child('rooms');

  Future<void> sendMessage(String senderId, String receiverId,
      String message, String timestamp) async {
    //create new message
    Message newMessage = Message(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room id from current user id and receiver
    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_"); // combine the ids into string, chatRoomId


    //add new message to database
    databaseReference.child("$chatRoomId/messages").set(
        newMessage.toMap());
  }

  String setTimeOffline(String timestamp){
    DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    DateTime now = DateTime.now();

    Duration difference = now.difference(lastSeen);

    String formattedLastSeen = '';

    if (difference.inDays > 0) {
      formattedLastSeen = 'last seen ${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      formattedLastSeen = 'last seen ${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      formattedLastSeen = 'last seen ${difference.inMinutes} minutes ago';
    } else {
      formattedLastSeen = 'last seen just now';
    }

    return formattedLastSeen;
  }
  
  String setTimeMessage(int timestamp){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    String formattedTime = DateFormat('HH:mm').format(dateTime);

    return formattedTime; // Рядок у форматі 24 годин: "17:02:07"
  }
}

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;


  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  //convert to map
  Map<String, dynamic> toMap(){
    return {
      "senderId" : senderId,
      "receiverId" : receiverId,
      "message" : message,
      "timestamp" : timestamp,
    };
  }
}