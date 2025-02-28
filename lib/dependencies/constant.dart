class Constant{
  static const ClientId= "713512622317-tm2o6jtk32bgbj7sgjpmv7o4lgbubdvp.apps.googleusercontent.com";
  static const config = {
    "audio": {
      "echoCancellation": true,
      "noiseSuppression": true,
      "autoGainControl": true,
      "allowAudioInputSharing": true, // ✅ Allows multiple apps to access the microphone
    },
    "video": {
      "width": 640,
      "height": 480,
      "frameRate": 30,
      "facingMode": "user"
    }
  };
  static const configAudio={
    "audio": {
      "echoCancellation": true,
      "noiseSuppression": true,
      "autoGainControl": true,
      "allowAudioInputSharing": true, // ✅ Allows multiple apps to access the microphone
    },
    "video":false,
  };
}