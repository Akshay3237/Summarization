import '../models/Pair.dart';


abstract class Iauthenticateservice{
  static const String typeName = "IAuthService";

  // Initialize database
  Future<Pair<bool, Object>> initializing();

  // Return authenticated user
  Future<Pair<bool, Object>> getAuth();

  // Register user in respective database
  Future<Pair<bool, Object>> register(String email, String password);

  // Login user with checking in respective database
  Future<Pair<bool, Object>> login(String email, String password);

  // Login using Google
  Future<Pair<bool, Object>> loginWithGoogle();
  // Logout user
  Future<Pair<bool, Object>> logout();
}