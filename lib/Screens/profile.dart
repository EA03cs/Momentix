import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Firebase/firestore.dart';
import 'package:instagram/Screens/AddStory.dart';
import 'package:instagram/Screens/StoryView.dart';
import 'package:instagram/Screens/widgets/post.dart';
import 'package:instagram/provider/userProvider.dart';
import 'package:provider/provider.dart';

import 'LogIn.dart';

class Profile extends StatefulWidget {
  final String Uid;

  const Profile({super.key, required this.Uid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late List following;
  late bool inFollowing;
  bool isLoading = false;
  late int postCount;
  bool storyViewed = false; // متغير لتتبع حالة عرض القصة

  void fetchCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var snap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.Uid)
        .get();
    postCount = snap.docs.length;
    following = snapshot.data()!['following'];

    setState(() {
      inFollowing = following.contains(widget.Uid);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    final userprovider = Provider.of<Userprovider>(context, listen: false);
    userprovider.getUser!.stories.forEach((element) {
      firestoreMethodes().deleteafter24h(Story: element);
    });
    userprovider.fetchUSer(uid: widget.Uid);
    fetchCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<Userprovider>(context);
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.Uid == FirebaseAuth.instance.currentUser!.uid
                        ? IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const LogIn()));
                        },
                        icon: const Icon(Icons.logout))
                        : Container(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          if (userprovider.getUser!.stories.isNotEmpty) {
                            setState(() {
                              storyViewed = true; // تحديث حالة عرض القصة
                            });
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => Story(
                                        stories: userprovider
                                            .getUser!.stories)));
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: userprovider.getUser!.stories
                                      .isEmpty
                                      ? Colors.grey
                                      : storyViewed
                                      ? Colors.grey
                                      : Colors.pink,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: userprovider.getUser !=
                                    null
                                    ? NetworkImage(
                                  userprovider.getUser!.userImage,
                                )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 5,
                              child: FirebaseAuth.instance.currentUser!
                                  .uid ==
                                  widget.Uid
                                  ? InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const AddStory()));
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            postCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          const Text(
                            ' Posts',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${userprovider.getUser!.followers.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          const Text(
                            ' Followers',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${userprovider.getUser!.following.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          const Text(
                            ' Following',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.01,
                ),
                userprovider.getUser != null
                    ? Text(
                  userprovider.getUser!.username,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18),
                )
                    : Container(),
                SizedBox(
                  height: h * 0.01,
                ),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          if (widget.Uid ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            // Edit profile logic here
                          } else {
                            if (inFollowing) {
                              firestoreMethodes()
                                  .unFollwUser(uid: widget.Uid);
                              setState(() {
                                userprovider.decreaseFollwers();
                                inFollowing = false;
                              });
                            } else {
                              firestoreMethodes()
                                  .follwUser(uid: widget.Uid);
                              setState(() {
                                userprovider.increaseFollwers();
                                inFollowing = true;
                              });
                            }
                          }
                        },
                        child: widget.Uid ==
                            FirebaseAuth.instance.currentUser!.uid
                            ? const Text('Edit profile')
                            : inFollowing
                            ? const Text(
                          'Unfollow',
                          style: TextStyle(color: Colors.red),
                        )
                            : const Text('Follow'))),
                SizedBox(
                  height: h * 0.03,
                ),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.Uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }
                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1,
                        shrinkWrap: true,
                        children: List.generate(
                          snapshot.data!.docs.length,
                              (index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            postWidget(
                                                postMap: snapshot
                                                    .data!.docs[index]
                                                    .data())));
                              },
                              child: Image.network(
                                snapshot.data!.docs[index]['imagePost'],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
