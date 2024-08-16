import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Chats",style: TextStyle(fontFamily: 'Pacifico',fontSize: 30),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No chats available."),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var currentUser = FirebaseAuth.instance.currentUser!.uid;
              var name = currentUser == data['sender'] ? data['receiverName'] : data['senderName'];
              var receiverImage = currentUser == data['sender'] ? data['receiverImage'] : data['senderImage'];
              var Uid = currentUser == data['sender'] ? data['receiver'] : data['sender'];

              // Fetch latest message
              var latestMessage = data['message'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(
                    Uid: Uid,
                    username: name,
                    userImage: receiverImage,
                  )));
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(receiverImage),
                  ),
                  title: Text(name,style: TextStyle(fontSize: 20),),
                  subtitle: Text(latestMessage),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String value) {
                      if (value == "option1") {
                        FirebaseFirestore.instance.collection('chats').doc(snapshot.data!.docs[index].id).delete();
                      } else if (value == "option2") {}
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'option1',
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'option2',
                          child: Text('Block'),
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
