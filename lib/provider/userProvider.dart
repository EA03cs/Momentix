import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram/Firebase/firestore.dart';
import 'package:instagram/models/UserModel.dart';

class Userprovider with ChangeNotifier {
 Usermodel? userdata;
 Usermodel? get getUser{
   return userdata;
 }
 
   void fetchUSer({required uid}) async {
   Usermodel user = await firestoreMethodes().getUserDetails(
     uid: uid,
   );
    userdata = user;
    notifyListeners();
  }
  void increaseFollwers(){
   getUser!.followers.length++;
    notifyListeners();
  }
 void decreaseFollwers(){
   getUser!.followers.length--;
   notifyListeners();
 }
 void deleteStory({required Map Story}){
   userdata!.stories.removeWhere((element){
     return element == Story;
   });
   notifyListeners();
 }
}