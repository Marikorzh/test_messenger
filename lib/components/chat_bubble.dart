import 'package:flutter/material.dart';
import 'package:test_messenger/service/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String name;
  final String msg;
  final Color color;
  final int timestamp;

  ChatBubble({
    required this.name,
    required this.msg,
    required this.color,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(color == Colors.blueAccent ? 12 : 0),
            topRight: Radius.circular(color == Colors.blueAccent ? 0 : 12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )),
      child: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: color == Colors.blueAccent ? "" : "$name\n",
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700)),

//real message
                TextSpan(
                  text: msg + "          ",
                  style: TextStyle(
                      color: color == Colors.blueAccent
                          ? Colors.white
                          : Colors.black87),
                ),

//fake additionalInfo as placeholder

                TextSpan(
                  text: ChatService().setTimeMessage(timestamp),
                  style: TextStyle(
                      fontSize: 10,
                      color: color == Colors.blueAccent
                          ? Colors.white
                          : Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
