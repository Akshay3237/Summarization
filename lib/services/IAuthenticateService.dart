import 'package:textsummarize/models/User.dart';

abstract class Iauthenticateservice{
  Map<bool,String>Register(User user);
  Map<bool,String>Login(String email,String password);
  Map<bool,String>IsAlreadyLoggedIn();
  Map<bool,String>LogOut();
}