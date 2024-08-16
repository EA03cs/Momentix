import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Firebase/firestore.dart';
import 'package:instagram/Screens/profile.dart';
import 'package:intl/intl.dart';

import '../Comment.dart';

class postWidget extends StatelessWidget {
  const postWidget({super.key, required this.postMap});
  final Map <String, dynamic> postMap;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                 GestureDetector(
                   onTap: () {
                     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                       return Profile(Uid: postMap['uid']);
                     }));
                   },
                   child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(postMap['userImage']),
                                 ),
                 ),
                SizedBox(
                  width: w * 0.01,
                ),
                 Text(postMap['username'],
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                const Spacer(),
              IconButton(
                    onPressed: () {
                      firestoreMethodes().deletePost(postMap: postMap);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          SizedBox(
            height: h*0.01,
          ),
          Image.network(postMap['imagePost'],
            height: h * 0.5,
            width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
          Row(
            children: [
              IconButton(onPressed: () {
                firestoreMethodes().addPost(postMap: postMap);
              }, icon:  Icon(Icons.favorite, color: postMap['Likes'].contains(FirebaseAuth.instance.currentUser!.uid)?Colors.red:Colors.white,)),
              IconButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return Comment(
                      postId: postMap['postId']
                  );
                }));
              }, icon: const Icon(Icons.comment)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark)),
            ],
          ),
           Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              '${postMap['Likes'].length} Likes',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
           Text(
            postMap['description'],
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return Comment(postId: postMap['postId'],);
                }));
              },
              child: const Text(
                'add comment',
                style: TextStyle(color: Colors.grey),
              )),
           Text(
            DateFormat.MMMEd().format(postMap['datePublished'].toDate()),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
