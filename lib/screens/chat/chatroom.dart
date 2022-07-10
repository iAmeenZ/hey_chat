import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hey_chat/model/custom_button.dart';
import 'package:hey_chat/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  final UserModel friendModel;
  final UserModel userModel;
  final RoomChat roomChat;
  const ChatRoom({Key? key, required this.friendModel, required this.roomChat, required this.userModel}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _controller = TextEditingController();

  String message = "";

  Future<void> addMessage() async {
    await database.child('room').child(widget.roomChat.id).child('chats').push().set({
      'uid' : widget.userModel.uid,
      'text' : message,
      'datetime' : DateTime.now().toUtc().toIso8601String()
    });
  }

  Future<void> deleteMessage(String key) async {
    await database.child('messages').child(widget.roomChat.id).child(key).set({});
  }

  late List<ChatModel> chatList = [];

  final database = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://heychatflutter-default-rtdb.asia-southeast1.firebasedatabase.app')
    .ref();

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool isOnce = false;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.only(left: 15),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        elevation: 0,
        title: Text(widget.friendModel.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final friendDoc = await FirebaseFirestore.instance.collection("users").doc(widget.friendModel.uid).get();
              List friendRoomIds = friendDoc.get('roomIds');
              friendRoomIds.removeWhere((e) => e == widget.roomChat.id);

              List myRoomIds = widget.userModel.roomIds;
              myRoomIds.removeWhere((e) => e == widget.roomChat.id);

              await Future.wait([
                // Them
                FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.friendModel.uid)
                  .update({
                    'roomIds': friendRoomIds
                  }),
                // Me
                FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.userModel.uid)
                  .update({
                    'roomIds': myRoomIds
                  })
              ]);

              if (mounted) {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: database.child('room').child(widget.roomChat.id).child('chats').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.active) return Container();
                if (snapshot.data == null || snapshot.data!.snapshot.value == null) {
                  debugPrint('LEL');
                  database.child('room').child(widget.roomChat.id).child('chats').push().set({
                    'uid' : widget.userModel.uid,
                    'text' : '',
                    'datetime' : DateTime.now().toUtc().toIso8601String()
                  });
                  return Container();
                }

                chatList = [];
                final Map data = snapshot.data!.snapshot.value as Map;

                data.forEach((key, value) {
                  chatList.add(ChatModel(uid: value['uid'], key: key, text: value['text'], datetime: value['datetime']));
                });

                chatList.sort((a, b) => a.key.compareTo(b.key));
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                });
                return ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: chatList.length,
                  itemBuilder: (context, i) {

                    DateTime dateTime = DateTime.parse(chatList[i].datetime).add(Duration(hours: 8));
                    DateTime? dateTimeBefore = i != 0 ? DateTime.parse(chatList[i-1].datetime).add(Duration(hours: 8)) : null;
                    String time = DateFormat('HH:mm').format(dateTime);
                    String date = DateFormat('dd MMMM (EEEE)').format(dateTime);
                    if (chatList.length == 1) return Column(
                      children: [
                        SizedBox(height: 150),
                        Icon(Icons.forum, size: 100, color: Colors.black.withOpacity(0.3)),
                        SizedBox(height: 20),
                        Text('Start Chat!', style: TextStyle(fontSize: 17, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.bold))
                      ],
                    );
                    if (chatList[i].text == '') return Container();
                    if (chatList[i].uid == widget.userModel.uid) {
                      return Column(
                        children: [

                          if (i == 1 || dateTime.day != dateTimeBefore!.day)
                            Container(margin: EdgeInsets.symmetric(vertical: 10), child: Text(date)),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(time),
                              SizedBox(width: 5),
                              Container(
                                width: chatList[i].text.length > 30 ? MediaQuery.of(context).size.width - 5 - 20 - 20 - 50 - 20 : null,
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade700
                                ),
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                child: Text(chatList[i].text, style: TextStyle(color: Colors.white))
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: CircleAvatar(
                                  radius: 17.0,
                                  backgroundImage: NetworkImage(widget.userModel.pic ?? ''),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    else {
                      return Column(
                        children: [

                          if (i == 1 || (dateTimeBefore != null && dateTime.day != dateTimeBefore.day))
                            Container(margin: EdgeInsets.symmetric(vertical: 10), child: Text(date)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: CircleAvatar(
                                  radius: 17.0,
                                  backgroundImage: NetworkImage(widget.friendModel.pic ?? ''),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              Container(
                                width: chatList[i].text.length > 30 ? MediaQuery.of(context).size.width - 5 - 20 - 20 - 50 - 20 : null,
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent
                                ),
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                child: Text(chatList[i].text, style: TextStyle(color: Colors.white))
                              ),
                              SizedBox(width: 5),
                              Text(time)
                            ],
                          ),
                        ],
                      );
                    }
                  },
                );
              }
            ),
          ),
          Container(
            height: 70,
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _controller,
                      onChanged: (value) {
                        message = value;
                      },
                      cursorColor: Colors.white,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Message here..',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    margin: EdgeInsets.zero,
                    isShadow: false,
                    color: Colors.redAccent,
                    onTap: () async {
                      if (message != '') {
                        _controller.clear();
                        chatList = [];
                        if (widget.friendModel.fcm != null) sendPushMessage(message, widget.userModel.name, widget.friendModel.fcm!);
                        await addMessage();
                        message = '';
                      }
                    },
                    child: Text('Send', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendPushMessage(String body, String title, String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAA-wlLelc:APA91bHS9wpwK9GtWqAoJi-NklHpb67YGUMxL3BfU48exMpGhGFlGqDNwUE7N7PquRWs8qBarAsHvj4jBz3eNzJwKtIWjCTXn_vaTWkHPp2HFHDsr5qTf-KWG-EZzsI9F8ADtYVoVYBv',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'image': widget.userModel.pic
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');
    } catch (e) {
      print("error push notification");
    }
  }
}
