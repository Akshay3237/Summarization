

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:textsummarize/models/Pair.dart';
import 'package:textsummarize/models/User.dart';
import 'package:textsummarize/services/IUserService.dart';

import '../models/User.dart';

class FireBaseUserService implements IUserService{




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
  Future<Pair<bool, Object>> findByMail(String mailId) {
    // TODO: implement findByMail
    throw UnimplementedError();
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