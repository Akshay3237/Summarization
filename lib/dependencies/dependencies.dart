
import 'package:textsummarize/FireBaseImplementation/FireBaseVideoCallService.dart';
import 'package:textsummarize/FireBaseImplementation/SettingService.dart';
import 'package:textsummarize/FireBaseImplementation/StorageService.dart';
import 'package:textsummarize/FireBaseImplementation/UserService.dart';
import 'package:textsummarize/Implementation1/SummarizeGeminiService.dart';
import 'package:textsummarize/services/IAuthenticateService.dart';
import 'package:textsummarize/services/IServiceVideoCall.dart';
import 'package:textsummarize/services/ISettingService.dart';
import 'package:textsummarize/services/IStorageService.dart';
import 'package:textsummarize/services/IUserService.dart';

import '../FireBaseImplementation/authenticateservice.dart';
import '../Implementation1/SummarizeService.dart';
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
      T instance = SummarizeGeminiService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }
    else if(t==IServiceVideoCall.typeName){
      T instance = FireBaseVideoCallService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }
    else if(t==IStorageService.typeName){
      T instance = FireBaseStorageService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }
    else if(t==ISettingService.typeName){
      T instance = FireBaseSettingService() as T;
      if (isSingleton) {
        _singletons[t] = instance as Object;
      }
      return instance;
    }
    throw Exception("No instance available for the provided type and parameters.");
  }
}
