import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../provider/userProvider.dart';

class Chat extends StatefulWidget {
  final String Uid;
  final String username;
  final String userImage;

  const Chat(
      {super.key,
        required this.Uid,
        required this.username,
        required this.userImage});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final textController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // إضافة ScrollController

  String chatRoomId() {
    List users = [
      FirebaseAuth.instance.currentUser!.uid,
      widget.Uid
    ];
    users.sort();
    return '${users[0]}_${users[1]}';
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final uuid = const Uuid().v4();

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('chat_images').child(uuid);
      await storageRef.putFile(file);

      final imageUrl = await storageRef.getDownloadURL();

      // Save image message to Firestore
      await FirebaseFirestore.instance.collection('chats').doc(chatRoomId()).collection('messages').doc(uuid).set({
        'sender': FirebaseAuth.instance.currentUser!.uid,
        'receiver': widget.Uid,
        'message': imageUrl,
        'date': Timestamp.now(),
        'messageid': uuid,
        'type': 'image',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<Userprovider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userImage),
            ),
            const SizedBox(width: 10),
            Text(widget.username),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chats').doc(chatRoomId()).collection('messages').orderBy('date', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Scroll to bottom when messages are loaded
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                });

                return ListView.builder(
                  controller: _scrollController, // Assign ScrollController here
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    var currentUser = FirebaseAuth.instance.currentUser!.uid;
                    var sender = data['sender'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: currentUser == sender ? Alignment.topRight : Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Delete Message ?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            FirebaseFirestore.instance
                                                .collection('chats')
                                                .doc(chatRoomId())
                                                .collection('messages')
                                                .doc(data['messageid'])
                                                .delete();
                                          },
                                          child: const Text("Yes"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("No"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0), // Add padding
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
                                  color: currentUser == sender ? Colors.grey[800] : Colors.black,
                                ),
                                child: data['type'] == 'image'
                                    ? Image.network(
                                  data['message'],
                                  width: 150, // set width for the image
                                  height: 150, // set height for the image
                                  fit: BoxFit.cover, // make sure the image covers the space
                                )
                                    : Text(
                                  data['message'],
                                  style: const TextStyle(color: Colors.white, fontSize: 24),
                                ),
                              ),
                            ),
                            Text(DateFormat.jm().format(data['date'].toDate()), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
        TextField(
          controller: textController,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              onPressed: () {
                pickAndUploadImage();
              },
              icon: const Icon(Icons.photo),
            ),
            suffixIcon: IconButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  final uuid = const Uuid().v4();
                  await FirebaseFirestore.instance.collection('chats').doc(chatRoomId()).set({
                    'senderName': userprovider.getUser!.username,
                    'senderImage': userprovider.getUser!.userImage,
                    'sender': userprovider.getUser!.uid,
                    'receiver': widget.Uid,
                    'receiverName': widget.username,
                    'receiverImage': widget.userImage,
                    'message': textController.text,
                    'participants': [userprovider.getUser!.uid, widget.Uid],
                    'chatroomid': chatRoomId(),
                    'date': Timestamp.now(),
                  }, SetOptions(merge: true));
                  await FirebaseFirestore.instance.collection('chats').doc(chatRoomId()).collection('messages').doc(uuid).set({
                    'sender': userprovider.getUser!.uid,
                    'receiver': widget.Uid,
                    'message': textController.text,
                    'date': Timestamp.now(),
                    'messageid': uuid,
                    'type': 'text',
                  });
                  setState(() {
                    textController.clear();
                  });
                }
              },
              icon: const Icon(Icons.send),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ), // TextField
      ]),
    );
  }
}

