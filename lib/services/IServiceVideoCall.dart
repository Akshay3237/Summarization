// services/IServiceVideoCall.dart

abstract class IServiceVideoCall {
  static const String typeName = "IServiceVideoCall";

  Future<String> initiateCall(String receiverEmail);
  Future<void> joinCall(String callId);
  Future<String> getCallStatus(String callId);

}
