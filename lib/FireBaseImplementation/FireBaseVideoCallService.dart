import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:textsummarize/services/IServiceVideoCall.dart';

class FireBaseVideoCallService implements IServiceVideoCall {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> initiateCall(String receiverEmail) async {
    try {
      // Get current user's email from Firebase Auth
      String userEmail = _auth.currentUser!.email!; // Current authenticated user's email

      // Add a new document to the 'videoCalls' collection with an auto-generated ID
      DocumentReference callRef = await _firestore.collection('videoCalls').add({
        'callerEmail': userEmail,
        'receiverEmail': receiverEmail,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      String callId = callRef.id;  // Firebase auto-generates a unique ID for the call
      return callId;
      print("Call initiated with Call ID: $callId");
    } catch (e) {
      throw Exception("Failed to initiate call: $e");
    }
  }

  @override
  Future<void> joinCall(String callId) async {
    try {
      // Fetch the call details from Firestore
      DocumentSnapshot callDoc = await _firestore.collection('videoCalls').doc(callId).get();

      if (callDoc.exists) {
        String status = callDoc['status'];
        if (status == 'pending') {
          // Update the status to 'accepted' when the call is joined
          await _firestore.collection('videoCalls').doc(callId).update({
            'status': 'accepted',
          });
        } else {
          throw Exception("Call already accepted or rejected.");
        }
      } else {
        throw Exception("Call does not exist.");
      }
    } catch (e) {
      throw Exception("Failed to join call: $e");
    }
  }

  @override
  Future<String> getCallStatus(String callId) async {
    try {
      // Fetch the call details and return the current status
      DocumentSnapshot callDoc = await _firestore.collection('videoCalls').doc(callId).get();

      if (callDoc.exists) {
        return callDoc['status'];
      } else {
        throw Exception("Call does not exist.");
      }
    } catch (e) {
      throw Exception("Failed to get call status: $e");
    }
  }


}
