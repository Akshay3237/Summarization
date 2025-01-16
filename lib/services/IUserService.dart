import '../models/Pair.dart';
import '../models/User.dart';


abstract class IUserService{
  static const String typeName = "IUserService";

  //this for save user data when user registers
  Future<Pair<bool, Object>> save(User u);

  //this is use for find user for calling via mail
  Future<Pair<bool, Object>> findByMail(String mailId);

  //find by userid
  Future<Pair<bool, Object>> findById(String Uid);


  //update user data
  Future<Pair<bool, Object>> Update(User u);
}