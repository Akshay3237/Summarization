
import 'package:textsummarize/FireBaseImplementation/UserService.dart';
import 'package:textsummarize/services/IAuthenticateService.dart';
import 'package:textsummarize/services/IUserService.dart';

import '../FireBaseImplementation/authenticateservice.dart';
import '../Implementation/SummarizeService.dart';
import '../services/ISummarizeService.dart';

class Injection {
  static final Map<String, Object> _singletons = {};

  static T getInstance<T>(String t, bool isSingleton) {
    if (isSingleton) {
      if (_singletons.containsKey(t)) {
        return _singletons[t] as T;
      }
    }

    if (t == Iauthenticateservice.typeName) {

      T instance = FireBaseAuthService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }
    else if(t==IUserService.typeName){
      T instance = FireBaseUserService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }
    else if(t==ISummarizeService.typeName){
      T instance = SummarizeService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }

    throw Exception("No instance available for the provided type and parameters.");
  }
}
