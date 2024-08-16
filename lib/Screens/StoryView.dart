import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Firebase/firestore.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

import '../provider/userProvider.dart';

class Story extends StatefulWidget {
  final List stories;

  const Story({super.key, required this.stories});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final controller = StoryController();
  Map storyy = {};
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<Userprovider>(context);
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            storyItems: widget.stories.map((story) {
              storyy = story;

              if (story['type'] == 'image') {
                return StoryItem.pageImage(
                  url: story['content'],
                  controller: controller,
                );
              } else {
                return StoryItem.pageVideo(
                  story['content'],
                  controller: controller,
                );
              }
            }).toList(),
            controller: controller,
            onComplete: () {
              Navigator.of(context).pop();
            },
            repeat: false,
          ),
          Positioned(
            top: 45,
            left: 20,
            child: IconButton(
                onPressed: () {
                  if (storyy['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                    firestoreMethodes().deleteStory(Story: storyy);
                    userprovider.deleteStory(Story: storyy);
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(
                  Icons.delete,
                )),
          )
        ],
      ),
    );
  }
}
