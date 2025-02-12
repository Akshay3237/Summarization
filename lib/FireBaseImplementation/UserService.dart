

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:textsummarize/models/Pair.dart';
import 'package:textsummarize/models/User.dart';
import 'package:textsummarize/services/IUserService.dart';

import '../models/User.dart';

class FireBaseUserService implements IUserService{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  Future<Pair<bool, Object>> Update(u) {
    // TODO: implement Update
    throw UnimplementedError();
  }

  @override
  Future<Pair<bool, Object>> findById(String Uid) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  Future<Pair<bool, Object>> findByMail(String mailId) async {
    try {
      // Searching for the user in the Firestore database (assuming you're looking in the 'users' collection)
      QuerySnapshot querySnapshot = await _firestore
          .collection('users') // Or 'videoCalls', depending on where you store the email
          .where('email', isEqualTo: mailId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Email found, return true and the user data
        var userDoc = querySnapshot.docs.first;
        var data=userDoc.data();
        if(data!=null)
          return Pair(true, data);
        else{
          return Pair(false, 'User not found');
        }
      } else {
        // Email not found, return false and an appropriate error message
        return Pair(false, 'User not found');
      }
    } catch (e) {
      // Catching any errors and returning failure status with error message
      return Pair(false, 'Error: $e');
    }
  }

  @override
  Future<Pair<bool, Object>> save(u) async{
    // TODO: implement save
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Add user data to Firestore
        CollectionReference users = FirebaseFirestore.instance.collection(
            'users');
        await users.doc(user.uid).set({
          "uid": user.uid,
          "fullName": u.fullname,
          "email": u.email,
        });

        return Pair(true, "Successfuly save");
      }
      return Pair(false, "not saved because user not logged in");
    }
    catch(e){
      print(e.toString());
      Pair<bool,String> result=new Pair(false, e.toString());
      return result;
    }
  }
  
}