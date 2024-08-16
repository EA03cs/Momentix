import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/helper/showSnackBar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../provider/userProvider.dart';
import 'BottomBar.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  File? pickImage;
  final des = TextEditingController();
  bool isLoading = false; // إضافة متغير حالة

  void pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var selected = File(image.path);
      setState(() {
        pickImage = selected;
        print("Image picked: ${pickImage!.path}");
      });
    } else {
      print("No image selected.");
    }
  }

  void uploadPost() async {
    setState(() {
      isLoading = true; // تفعيل دائرة التحميل
    });
    try {
      final uuid = Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('postImage').child(uuid + '.jpg');
      await ref.putFile(pickImage!);
      final imageurl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('posts').doc(uuid).set({
        'uid': Provider.of<Userprovider>(context, listen: false).getUser!.uid,
        'username': Provider.of<Userprovider>(context, listen: false).getUser!.username,
        'imagePost': imageurl,
        'userImage': Provider.of<Userprovider>(context, listen: false).getUser!.userImage,
        'postId': uuid,
        'description': des.text,
        'Likes': [],
        'datePublished': Timestamp.now(),
      });
      setState(() {
        pickImage = null;
        des.clear();
        isLoading = false; // إيقاف دائرة التحميل
      });
      showSnackBar(context, 'Done!');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomBar()));
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false; // إيقاف دائرة التحميل
      });
      showSnackBar(context, 'Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Post',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,fontFamily: 'Pacifico'),
                        ),
                        TextButton(
                          onPressed: () {
                            uploadPost();
                          },
                          child: const Text('Next',style: TextStyle(fontFamily: 'Pacifico'),),
                        ),
                      ],
                    ),
                    pickImage == null
                        ? SizedBox(
                      height: h * 0.5, // Adjusted the height factor
                    )
                        : Image.file(
                      pickImage!,
                      height: h * 0.4, // Adjusted the height factor
                      width: double.infinity,
                      fit: BoxFit.fitHeight,
                    ),
                    IconButton(
                      onPressed: () {
                        pickImageFromGallery();
                      },
                      icon: const Icon(Icons.upload),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: des,
                        maxLines: 15,
                        decoration: const InputDecoration(
                          hintText: 'Caption',
                        ),
                      ),
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
      ),
    );
  }
}
