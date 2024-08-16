import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Firebase/firestore.dart';
import 'package:instagram/Screens/LogIn.dart';
import 'package:instagram/Screens/StoryView.dart';
import 'package:instagram/Screens/widgets/post.dart';
import 'package:instagram/provider/userProvider.dart';
import 'package:provider/provider.dart';

import 'Chats.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Userprovider>(context, listen: false).fetchUSer(
      uid: FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Momentix',
                      style:
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold,fontFamily: 'Pacifico',),
                    ),
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const Chats()));
                        },
                        icon: const Icon(Icons.chat_outlined)),
                  ],
                ),
                SizedBox(
                  height: h * 0.14,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').where('stories',isNotEqualTo:[]).where('followers',arrayContains: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                      builder:(context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong'));
                        }
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userMap = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return const CircularProgressIndicator();
                              }
                              firestoreMethodes().deleteafter24h(Story: userMap['stories'][index]);
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => Story(stories: userMap['stories'],)));
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                        height: h * 0.1,
                                        width: w * 0.200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.pink, width: 3),
                                          image: DecorationImage(
                                            image: NetworkImage(userMap['userImage']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        userMap['username'],
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      }
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts').orderBy('datePublished', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No posts yet'));
                      }
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data = snapshot.data!.docs[index]
                                .data() as Map<String, dynamic>;
                            return postWidget(postMap: data);
                          },
                          itemCount: snapshot.data!.docs.length);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
