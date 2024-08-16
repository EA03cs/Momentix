import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/Screens/BottomBar.dart';
import 'package:instagram/Screens/LogIn.dart';
import 'package:instagram/models/UserModel.dart';
import 'package:uuid/uuid.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool _obscurePassword = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? pickImage;

  void pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var selected = File(image.path);
      setState(() {
        pickImage = selected;
      });
    }
  }

  void signUpMethod() async {
    setState(() {
      isLoading = true;
    });
    try {
      final uuid = Uuid().v4();
      final ref = FirebaseStorage.instance
          .ref()
          .child('userImages')
          .child(uuid + '.jpg');
      await ref.putFile(pickImage!);
      final imageurl = await ref.getDownloadURL();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);
      Usermodel user = Usermodel(
          [], [],
          name.text,
          email.text,
          password.text,
          FirebaseAuth.instance.currentUser!.uid,
          imageurl, []);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(user.converttomap());
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomBar()));
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: h * 0.05,
                  ),
                  const Text(
                    'Momentix',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,fontFamily: 'Pacifico'),
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage:
                        pickImage != null ? FileImage(pickImage!) : null,
                        child: pickImage == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        child: IconButton(
                          onPressed: pickImageFromGallery,
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.black,
                          ),
                        ),
                        bottom: 10,
                        right: 20,
                      )
                    ],
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              )),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: 'Email',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              )),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: password,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                          },
                          decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        formKey.currentState!.save();
                        if (formKey.currentState!.validate()) {
                          signUpMethod();
                        }
                      },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Sign Up'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const LogIn()));
                      },
                      child: const Text('Already have an account? Log in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
