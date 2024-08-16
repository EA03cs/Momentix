import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Firebase/firestore.dart';
import 'package:provider/provider.dart';

import '../provider/userProvider.dart';

class Comment extends StatefulWidget {
  final String postId;

  const Comment({super.key, required this.postId});

  @override
  State<Comment> createState() => _CommentState();
}
final comment = TextEditingController();
class _CommentState extends State<Comment> {
  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<Userprovider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Comments',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('datePublished', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> commentMap = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        commentMap['username'],
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage(commentMap['userImage']),
                      ),
                      subtitle:  Text(commentMap['comment']),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite, size: 20),
                      ),
                    );
                  },
                );
              }
            ),
          ),
          const Spacer(), // Spacer to push the text field to the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage(userprovider.getUser!.userImage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: comment,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (comment.text.isNotEmpty){
                            firestoreMethodes().addComment(
                              comment: comment.text,
                              postId: widget.postId,
                              uid: userprovider.getUser!.uid,
                              userImage: userprovider.getUser!.userImage, username: userprovider.getUser!.username,);
                          }
                          comment.clear();

                        },
                        icon: const Icon(Icons.send),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      hintText: 'Write a comment',
                      prefixIcon: const Icon(Icons.comment),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
