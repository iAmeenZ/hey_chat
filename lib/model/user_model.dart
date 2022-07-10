import 'dart:convert';

import 'package:flutter/cupertino.dart';

class ChatModel {
  final String uid;
  final String key;
  final String text;
  final String datetime;

  ChatModel({
    required this.uid,
    required this.key,
    required this.text,
    required this.datetime,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'uid': uid});
    result.addAll({'key': key});
    result.addAll({'text': text});
    result.addAll({'datetime': datetime});
  
    return result;
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      uid: map['uid'] ?? '',
      key: map['key'] ?? '',
      text: map['text'] ?? '',
      datetime: map['datetime'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source));

  factory ChatModel.fromRtdb(Map map) {
    return ChatModel(
      uid: map['uid'],
      key: map['key'],
      text: map['text'],
      datetime: map['datetime']
    );
  }
}

class UserModelStream {
  final String uid;

  UserModelStream({required this.uid});
}

class UserModel extends ChangeNotifier {
  String uid;
  String email;
  String name;
  String? fcm;
  String? pic;
  List<String> roomIds;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.fcm,
    this.pic,
    required this.roomIds,
  });

  void updateRoomIds(String x) {
    roomIds.add(x);
    notifyListeners();
  }

  factory UserModel.fromRtdb(json){
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      fcm: json['fcm'],
      pic: json['pic'],
      roomIds: [],
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'uid': uid});
    result.addAll({'email': email});
    result.addAll({'name': name});
    if(fcm != null){
      result.addAll({'fcm': fcm});
    }
    if(pic != null){
      result.addAll({'pic': pic});
    }
    result.addAll({'roomIds': roomIds});
  
    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      fcm: map['fcm'],
      pic: map['pic'],
      roomIds: List<String>.from(map['roomIds']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}

// REAL TIME
class RoomChat {
  String id;
  List<UserModel> users;
  
  RoomChat({
    required this.id,
    required this.users
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'users': users.map((x) => x.toMap()).toList()});
  
    return result;
  }

  factory RoomChat.fromMap(Map<String, dynamic> map) {
    return RoomChat(
      id: map['id'] ?? '',
      users: List<UserModel>.from(map['users']?.map((x) => UserModel.fromMap(x)))
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomChat.fromJson(String source) => RoomChat.fromMap(json.decode(source));

  factory RoomChat.fromRtdb(Map map) {
    return RoomChat(
      id: map['id'],
      users: List<UserModel>.from(map['users'].map((x) => UserModel.fromRtdb(x)))
    );
  }
}

// class Chats {
//   String uid;
//   String text;
//   String dateTime;
  
//   Chats({
//     required this.uid,
//     required this.text,
//     required this.dateTime,
//   });

//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};
  
//     result.addAll({'uid': uid});
//     result.addAll({'text': text});
//     result.addAll({'dateTime': dateTime});
  
//     return result;
//   }

//   factory Chats.fromMap(Map<String, dynamic> map) {
//     return Chats(
//       uid: map['uid'] ?? '',
//       text: map['text'] ?? '',
//       dateTime: map['dateTime'] ?? '',
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory Chats.fromJson(String source) => Chats.fromMap(json.decode(source));

//   factory Chats.fromRtdb(Map map) {
//     return Chats(
//       uid: map['uid'],
//       text: map['text'],
//       dateTime: map['dateTime'],
//     );
//   }
// }

// RoomChat2 roomChatFromJson(String str) => RoomChat2.fromJson(json.decode(str));

// String roomChatToJson(RoomChat2 data) => json.encode(data.toJson());

// class RoomChat2 {
//     RoomChat2({
//         required this.users,
//     });

//     List<User2> users;

//     factory RoomChat2.fromJson(Map json) => RoomChat2(
//         users: List<User2>.from(json["users"].map((x) => User2.fromJson(x))),
//     );

//     Map toJson() => {
//         "users": List.from(users.map((x) => x.toJson())),
//     };
// }

// class User2 {
//     User2({
//         required this.email,
//         required this.fcm,
//         required this.name,
//         required this.pic,
//         required this.uid
//     });

//     String email;
//     String fcm;
//     String name;
//     String pic;
//     String uid;

//     factory User2.fromJson(Map json) => User2(
//         email: json["email"],
//         fcm: json["fcm"],
//         name: json["name"],
//         pic: json["pic"],
//         uid: json["uid"]
//     );

//     Map toJson() => {
//         "email": email,
//         "fcm": fcm,
//         "name": name,
//         "pic": pic,
//         "uid": uid
//     };
// }
