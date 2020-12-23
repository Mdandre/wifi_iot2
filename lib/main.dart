import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;

import 'package:wifiproyect/services/serviceWifi.dart';
const String STA_DEFAULT_SSID = "STA_SSID";
const String STA_DEFAULT_PASSWORD = "STA_PASSWORD";
const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

const String AP_DEFAULT_SSID = "AP_SSID";
const String AP_DEFAULT_PASSWORD = "AP_PASSWORD";
void main() => {runApp(MyApp())};

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<WifiNetwork> _listwifi = [];
  Timer _timer;
  List<WifiNetwork> sinlimp;
  String version;
  String _ssidactual;
  @override
  void initState() {
    print("ES ANDORID??" + Platform.isAndroid.toString());
    cargaLista();
    do{_initializeTimer();}while(_listwifi == []);
    
    super.initState();
    cargaLista();
  }

  void _initializeTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(const Duration(seconds: 2), initState);
  }

  Future<List<WifiNetwork>> getConnectionState() async {
    var listAvailableWifi = await WiFiForIoTPlugin.loadWifiList();
    return listAvailableWifi;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () {
              initState();
            },
          )
        ],
        title: const Text('busqueda wifis'),
      ),
      body: ListView.builder(
          itemCount: 0 == _listwifi.length ? 1 : _listwifi.length,
          itemBuilder: (0 == _listwifi.length)
              ? (contex, index) {
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.black),
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              : (contex, index) {
                  WifiNetwork listalowifi = _listwifi[index];
                  /*  (listalowifi.startsWith("STECH"))? */
                  return InkWell(
                      onTap: () {
                        dameSSID();
                        conectoEnvioDisconect(listalowifi);
                      },
                      child: Card(
                          shadowColor: Colors.black,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(listalowifi.ssid),
                                  ]))));
                }),
    ));
  }

  dynamic dameSSID() {
    WiFiForIoTPlugin.getSSID().then((value) {
      _ssidactual = value;
    });
    print("EL ACTUAL" + _ssidactual);
  }

  void cargaLista() {
    _listwifi.clear();
    setState(() {
      getConnectionState().then((value) {
        sinlimp = value;
      });
      print("CARGADO");
    });
    if (sinlimp != null) {
      for (int i = 0; i < sinlimp.length; i++) {
        if (sinlimp[i].ssid != "" && (sinlimp[i].ssid).startsWith("STECH"))
          _listwifi.add(sinlimp[i]);
      }
    }
  }

  dynamic conectoEnvioDisconect(WifiNetwork wifiSelect) async {
    //WiFiForIoTPlugin.disconnect();
  WifiConfiguration.connectToWifi(wifiSelect.ssid);
    conectoAnterior();
  }

  dynamic conectoAnterior() async {
    await Future.delayed(Duration(seconds: 10));
   // WiFiForIoTPlugin.disconnect();
    WifiConfiguration.connectToWifi(_ssidactual);
  }

  /*  List<dynamic> armaLista(List<dynamic> _listwifi) {
    setState(() {
      var _listaObtenida = _listwifi.map((dynamic a) {
        if (a != "") {
          if (a.startsWith("STECH")) {
            return DropdownMenuItem<dynamic>(
              child: Text(a),
              value: a,
              onTap: () {},
            );
          }
        }
      }).toList();
      return _listaObtenida;
    });
  } */
}

