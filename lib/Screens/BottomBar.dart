import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/AddPost.dart';
import 'package:instagram/Screens/Home.dart';
import 'package:instagram/Screens/profile.dart';
import 'package:instagram/Screens/search.dart';

class BottomBar extends StatefulWidget {
  BottomBar({Key? key}) : super(key: key);
  String id = 'Home';

  @override
  State<BottomBar> createState() => _BottomBarState();
}

int _selectedpageindex = 0;

class _BottomBarState extends State<BottomBar> {
  List<Widget> Screens = [
    const Home(),
    const AddPost(),
    const SearchScreen(),
     Profile(
      Uid: FirebaseAuth.instance.currentUser!.uid,
    ),
  ];

  void selectpage(int value) {
    setState(() {
      _selectedpageindex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Screens[_selectedpageindex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BottomNavigationBar(
              fixedColor: Colors.white,
              onTap: selectpage,
              currentIndex: _selectedpageindex,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  label: 'Home',
                  backgroundColor: Colors.black,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.black,
                  label: 'Add',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  label: 'Search',
                  backgroundColor: Colors.black,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                  ),
                  label: 'Profile',
                  backgroundColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
