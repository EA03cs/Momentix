import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/helper/showSnackBar.dart';
import 'package:instagram/models/UserModel.dart';
import 'package:uuid/uuid.dart';

class firestoreMethodes {
  Future<Usermodel> getUserDetails({required uid}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return Usermodel.convertSnapToModel(snap);
  }

  addPost({required Map postMap}) async {
    if (postMap['Likes'].contains(FirebaseAuth.instance.currentUser!.uid)) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postMap['postId'])
          .update({
        'Likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postMap['postId'])
          .update({
        'Likes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    }
  }

  deletePost({required Map postMap}) async {
    if (FirebaseAuth.instance.currentUser!.uid == postMap['uid']) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postMap['postId'])
          .delete();
    }
  }

  addComment(
      {required comment,
      required postId,
      required uid,
      required userImage,
      required username}) async {
    final uuid = Uuid().v4();
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(uuid)
        .set({
      'comment': comment,
      'username': username,
      'uid': uid,
      'postId': postId,
      'userImage': userImage,
      'commentId': uuid,
      'datePublished': Timestamp.now(),
    });
  }

  follwUser({required uid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'following': FieldValue.arrayUnion([uid])
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'followers':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }
  unFollwUser({required uid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'following': FieldValue.arrayUnion([uid])
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'followers':
      FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }
  deleteComment({required commentId, required postId}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(postId['uid'])
        .update({
      'comments': FieldValue.arrayRemove([commentId])
        });
  }
  deleteStory({required Map Story}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Story['uid'])
        .update({
      'stories': FieldValue.arrayRemove([Story])
        });
  }
  deleteafter24h({required Map Story}) async {
 Duration difference = DateTime.now().difference(Story['datePublished'].toDate());
    if(difference.inHours>24){
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Story['uid'])
          .update({
        'stories': FieldValue.arrayRemove([Story])
      });
    }
  }
}
