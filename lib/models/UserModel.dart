import 'package:cloud_firestore/cloud_firestore.dart';

class Usermodel {
  String username;
  String email;
  String password;
  String uid;
  String userImage;
  final List following;
  final List followers;
  final List stories;

  Usermodel(this.following, this.followers, this.username, this.email,
      this.password, this.uid, this.userImage, this.stories);

  Map<String, dynamic> converttomap() =>
      {
        "username": username,
        "email": email,
        "password": password,
        "uid": uid,
        "userImage": userImage,
        "following": following,
        "followers": followers,
        'stories': stories
      };

  static convertSnapToModel(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Usermodel(
      snapshot['following'],
      snapshot['followers'],
      snapshot['username'],
      snapshot['email'],
      snapshot['password'],
      snapshot['uid'],
      snapshot['userImage'],
      snapshot['stories'],
    );
  }
}
