import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:textsummarize/dependencies/constant.dart';
import 'package:textsummarize/services/IAuthenticateService.dart';
import '../firebase_options.dart';
import '../models/Pair.dart';

class FireBaseAuthService implements Iauthenticateservice {
  FirebaseAuth? _auth; // Declare _auth but don't initialize it immediately.
  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: Constant.ClientId);
  @override
  Future<Pair<bool, Object>> initializing() async {
    try {
      // Simulate Firebase initialization asynchronously
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Initialize FirebaseAuth after Firebase is initialized
      _auth = FirebaseAuth.instance;
      return Pair(true, "Firebase initialized successfully");
    } catch (e) {
      return Pair(false, "Error during initialization: ${e.toString()}");
    }
  }


  @override
  Future<Pair<bool, Object>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Pair(false, "Google Sign-In canceled");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print(googleAuth.accessToken);
      print(googleAuth.idToken);
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth!.signInWithCredential(credential);
      return Pair(true, "Google Sign-In successful: ${googleUser.email}");
    } catch (e) {
      print(e.toString());
      return Pair(false, "Google Sign-In error: ${e.toString()}");
    }
  }


  @override
  Future<Pair<bool, Object>> getAuth() async {
    try {
      if (_auth == null) {
        _auth = FirebaseAuth.instance;
      }
      final user = _auth!.currentUser;
      if (user != null) {
        return Pair(true, "User is authenticated: ${user.email}");
      } else {
        return Pair(false, "No user is currently authenticated.");
      }
    } catch (e) {
      return Pair(false, "Error fetching authentication state: ${e.toString()}");
    }
  }

  @override
  Future<Pair<bool, Object>> register(String email, String password) async {
    try {
      if (_auth == null) {
        _auth=FirebaseAuth.instance;
      }
      await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      return Pair(true, "User registered successfully with email: $email");
    } on FirebaseAuthException catch (e) {
      return Pair(false, "Registration error: ${e.message}");
    } catch (e) {
      return Pair(false, "Unexpected error: ${e.toString()}");
    }
  }

  @override
  Future<Pair<bool, Object>> login(String email, String password) async {
    try {
      if (_auth == null) {
        _auth = FirebaseAuth.instance;
      }
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return Pair(true, "User logged in successfully with email: $email");
    } on FirebaseAuthException catch (e) {
      return Pair(false, "Login error: ${e.message}");
    } catch (e) {
      return Pair(false, "Unexpected error: ${e.toString()}");
    }
  }

  @override
  Future<Pair<bool, Object>> logout() async {
    try {
      _auth ??= FirebaseAuth.instance;
      await _auth!.signOut();
      await _googleSignIn.signOut();
      return Pair(true, "User logged out successfully");
    } catch (e) {
      return Pair(false, "Error during logout: ${e.toString()}");
    }
  }
}
