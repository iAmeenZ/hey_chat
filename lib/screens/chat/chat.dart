import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hey_chat/model/custom_button.dart';
import 'package:hey_chat/model/user_model.dart';
import 'package:hey_chat/screens/chat/chatroom.dart';
import 'package:hey_chat/services/auth.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  
  final firestore = FirebaseFirestore.instance;

  final database = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: 'https://heychatflutter-default-rtdb.asia-southeast1.firebasedatabase.app')
    .ref();

  Future<List<RoomChat>> getRoomChat(List<String> roomIds) async {
    List<RoomChat> list = [];

    try {
      for (var e in roomIds) {
        await database.child('room').child(e).once().then((snapshot) {
          if (snapshot.snapshot.exists) {
            Map map = snapshot.snapshot.value as Map;
            RoomChat roomChat = RoomChat.fromRtdb(map);
            list.add(roomChat);
          }
        });
      }

    } catch (e) {
      debugPrint('ROSAK AMAT $e');
    }

    debugPrint('Length ${list.length}');

    return list;
  }

  late Future<List<RoomChat>> getRoomChato;

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    getRoomChato = getRoomChat(userModel.roomIds);
  }

  String email = '';
  bool searchOpen = false;

  Future<String> getSearchedUser(UserModel me) async {
    UserModel provider = Provider.of<UserModel>(context, listen: false);
    if (me.email == email) return 'Can\'t add yourself.';
    if (email.isEmpty) return 'Please fill an email';

    final data = await firestore.collection('users').where('email', isEqualTo: email).get();
    
    try {
      if (data.docs.isNotEmpty) {
        UserModel friendModel = UserModel.fromMap(data.docs[0].data());

        DatabaseReference ref = database.child('room').push();

        RoomChat roomChat = RoomChat(
          id: ref.key!,
          users: [
            me,
            friendModel
          ]
        );

        final meLatest = await firestore.collection('users').doc(me.uid).get();
        List meLatestRoomIds = meLatest.get('roomIds');
        meLatestRoomIds.add(ref.key);
        
        List friendLatestRoomIds = friendModel.roomIds;
        friendLatestRoomIds.add(ref.key);
        await Future.wait([
          firestore.collection('users').doc(me.uid).update({
            'roomIds': meLatestRoomIds
          }),
          firestore.collection('users').doc(friendModel.uid).update({
            'roomIds': friendLatestRoomIds
          }),
          database.child('room').child(ref.key!).set(roomChat.toMap())
        ]);

        if (mounted) provider.updateRoomIds(ref.key!);

        return 'success';
      }
    } catch  (e) {
      debugPrint('ROSAK $e');
    }
    
    return 'Can\'t find any user with this email.';
  }

  String? error;

  bool loading = false;

  late int currentLength = Provider.of<UserModel>(context, listen: false).roomIds.length;
  bool roomIdsChanged = false;

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    if (currentLength != userModel.roomIds.length) {
      debugPrint('MASUK');
      currentLength = userModel.roomIds.length;
      getRoomChato = getRoomChat(userModel.roomIds);
    }
    
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.forum, color: Colors.white),
        title: Text('HeyChat'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searchOpen = !searchOpen;
              });
            },
            icon: Icon(searchOpen ? Icons.close : Icons.search)
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [

          if (searchOpen)...[
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 300,
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: "Friend's email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: loading ? SpinKitWave(color: Colors.redAccent) : Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          error = null;
                          loading = true;
                        });
                        String anyError = await getSearchedUser(userModel);
                        if (anyError != 'success') error = anyError;
                        loading = false;
                        setState(() {});
                      },
                      child: Text('ADD')
                    ),
                  ),
                )
              ],
            ),
          ],

          if (error != null)...[
            SizedBox(height: 10),
            Text(error!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center)
          ],

          SizedBox(height: 10),

          FutureBuilder<List<RoomChat>>(
            future: getRoomChato,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Container();
              if (snapshot.data == null) return Text('No data');

              final List<RoomChat> list = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  int e = 0;
                  if (userModel.uid == list[index].users[0].uid) e = 1;
                  return CustomButton(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                    splashColor: Colors.redAccent.shade100,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                        userModel: userModel,
                        roomChat: list[index],
                        friendModel: list[index].users[e]
                      ))).then((value) => setState(() {}));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage(list[index].users[e].pic!),
                        backgroundColor: Colors.transparent,
                      ),
                      title: Text(list[index].users[e].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      subtitle: Text(list[index].users[e].email, style: TextStyle(color: Colors.grey, fontSize: 14)),
                    )
                  );
                }
              );
            }
          ),
        ],
      )
    );
  }
}
