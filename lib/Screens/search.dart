import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/chat.dart';
import 'package:instagram/Screens/profile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: TextField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  controller: searchcontroller,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    border: InputBorder.none,
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              searchcontroller.text.isEmpty
                  ? const Center(
                child: Text(
                  'Please enter a search term',
                  style: TextStyle(color: Colors.white, fontSize: 18,fontFamily: 'Pacifico'),
                ),
              )
                  : FutureBuilder(
                future: searchUsers(searchcontroller.text),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.white, fontSize: 18,fontFamily: 'Pacifico'),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      return ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Chat(
                                Uid: data['uid'],
                                username: data['username'],
                                userImage: data['userImage'],
                              ),
                            ));
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Profile(
                              Uid: snapshot.data!.docs[index]['uid'],
                            ),
                          ));
                        },
                        title: Text(
                          snapshot.data!.docs[index]['username'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(snapshot.data!.docs[index]['userImage']),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<QuerySnapshot> searchUsers(String query) async {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('username')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .get();
  }
}
