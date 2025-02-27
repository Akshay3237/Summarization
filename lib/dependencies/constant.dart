class Constant{
  static const ClientId= "713512622317-tm2o6jtk32bgbj7sgjpmv7o4lgbubdvp.apps.googleusercontent.com";
  static const config={
    "audio": {
      "echoCancellation": true,
      "noiseSuppression": true,
      "autoGainControl": true,
    },
    "video":  {
      "mandatory": {
        "minWidth": '640',
        "minHeight": '480',
        "minFrameRate": '30',
      },
      "facingMode": "user",
      "optional": [],
    }
  };
}