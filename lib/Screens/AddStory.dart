import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/helper/showSnackBar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../provider/userProvider.dart';
import 'BottomBar.dart';

class AddStory extends StatefulWidget {
  const AddStory({super.key});

  @override
  State<AddStory> createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  late VideoPlayerController videoPlayerController;
  File? pickImage;
  File? pickVideo;
  final des = TextEditingController();
  bool isLoading = false; // متغير حالة التحميل

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(File(''));
  }

  void pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var selected = File(image.path);
      setState(() {
        pickImage = selected;
        pickVideo = null;
        videoPlayerController.pause();
      });
    } else {}
  }

  void pickImageVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      var selected = File(video.path);
      setState(() {
        pickVideo = selected;
        pickImage = null;
        videoPlayerController = VideoPlayerController.file(pickVideo!);
        videoPlayerController.initialize();
        videoPlayerController.play();
      });
    } else {}
  }

  Future<void> uploadStory() async {
    setState(() {
      isLoading = true; // بدء التحميل
    });

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final uuid = const Uuid().v4();
      var media = pickVideo ?? pickImage;
      final ref = FirebaseStorage.instance
          .ref()
          .child('usersStories')
          .child('$uuid.jpg');
      await ref.putFile(media!);
      final content = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'stories': FieldValue.arrayUnion([{
          'uid': uid,
          'storyId': const Uuid().v1(),
          'content': content,
          'type': pickVideo != null ? 'video' : 'image',
          'date': Timestamp.now(),
          'viewers': [],
        }])
      });
      Provider.of<Userprovider>(context, listen: false).fetchUSer(uid: uid);
      setState(() {
        pickVideo = null;
        pickImage = null;
        isLoading = false; // إيقاف التحميل
      });
      showSnackBar(context, 'Story added successfully');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomBar()));
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false; // إيقاف التحميل في حالة حدوث خطأ
      });
      showSnackBar(context, 'Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                      const Text(
                        'Add Story',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,fontFamily: 'Pacifico'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (pickImage == null && pickVideo == null) {
                            showSnackBar(context, 'Please select an image or video');
                            return;
                          }
                          await uploadStory(); // رفع الاستوري
                        },
                        child: const Text('Next',style: TextStyle(fontFamily: 'Pacifico'),),
                      ),
                    ],
                  ),
                  pickImage != null
                      ? Image.file(
                    pickImage!,
                    height: h * 0.4, // Adjusted the height factor
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                  )
                      : pickVideo != null
                      ? SizedBox(
                    height: h * 0.4, // Adjusted the height factor
                    width: double.infinity,
                    child: VideoPlayer(videoPlayerController),
                  )
                      : const SizedBox(),
                  PopupMenuButton(
                    icon: const Icon(Icons.upload),
                    onSelected: (String choice) {
                      if (choice == 'option1') {
                        pickImageVideoFromGallery();
                      } else if (choice == 'option2') {
                        pickImageFromGallery();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'option1',
                          child: Text('Select Video'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'option2',
                          child: Text('Select Image'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            if (isLoading) // عرض دائرة التحميل إذا كان التحميل جارٍ
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
