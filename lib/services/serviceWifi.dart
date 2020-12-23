import 'dart:async';
import 'package:flutter/services.dart';

enum WifiConnectionStatus {
  connected,
  alreadyConnected,
  notConnected,
  platformNotSupported,
  profileAlreadyInstalled,
  locationNotAllowed,
}

class WifiConfiguration {
  static const MethodChannel _channel =
      const MethodChannel('wifi_configuration');

  static Future<String> getplatformVersion() async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }//ESTE NO SE QUE HARIA


  static Future<WifiConnectionStatus> connectToWifi(
      String ssid/*, String password , String packageName */) async {
      final String isConnected = await _channel.invokeMethod(
          'connectToWifi', <String, dynamic>{
        "ssid": ssid,
       //  "password": password, 
        /* "packageName": packageName */
      });
    switch (isConnected) {
      case "connected":
        return WifiConnectionStatus.connected;
        break;

      case "alreadyConnected":
        return WifiConnectionStatus.alreadyConnected;
        break;

      case "notConnected":
        return WifiConnectionStatus.notConnected;
        break;

      case "platformNotSupported":
        return WifiConnectionStatus.platformNotSupported;
        break;

      case "profileAlreadyInstalled":
        return WifiConnectionStatus.profileAlreadyInstalled;
        break;

      case "locationNotAllowed":
        return WifiConnectionStatus.locationNotAllowed;
        break;
    }
  }

  static Future<List<dynamic>> getWifiList() async {
    final List<dynamic> wifiList = await _channel.invokeMethod('getWifiList');
    return wifiList;
  }

  static Future<bool> isConnectedToWifi(String ssid) async {
    final bool isConnected = await _channel
        .invokeMethod('isConnectedToWifi', <String, dynamic>{"ssid": ssid});
    return isConnected;
  }

  static Future<String> connectedToWifi() async {
    final String connectedWifiName =
        await _channel.invokeMethod('connectedToWifi');
    return connectedWifiName;
  }

  static Future<WifiConnectionStatus> disconnect( String ssid) async{
     final String isDisconnected = await _channel.invokeMethod(
        'disconnect', <String, dynamic>{
      "ssid": ssid,
    }); 
    if(isDisconnected.toString()== "notConnected")
        return WifiConnectionStatus.notConnected;
  }

    static Future<bool> removeWifiNetwork(String ssid) async {
    Map<String, String> htArguments = Map();
    htArguments["ssid"] = ssid;
    bool bResult;
    try {
      bResult = await _channel.invokeMethod('removeWifiNetwork', htArguments);
    } on MissingPluginException catch (e) {
      print("MissingPluginException : ${e.toString()}");
    }
    return bResult != null && bResult;
  }

    static Future<String> getSSID() async {
    Map<String, String> htArguments = Map();
    String sResult;
    try {
      sResult = await _channel.invokeMethod('getSSID');
    } on MissingPluginException catch (e) {
      print("MissingPluginException : ${e.toString()}");
    }
    return sResult;
  }
}

