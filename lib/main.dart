import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;

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
  List<WifiNetwork> sinlimp = [];
  String version;
  String _ssidactual;
  final _contrasenia = TextEditingController();
  bool _isConnected;
  final _scaffKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    // Limpia el controlador cuando el Widget se descarte
    _contrasenia.dispose();
    super.dispose();
  }

  @override
  void initState() {
    cargaLista();
    _initializeTimer();

    super.initState();
  }

  void _initializeTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(const Duration(seconds: 10), initState);
  }

  Future<List<WifiNetwork>> loadWifiLista() async {
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
      print(htResultNetwork);
    } on PlatformException {
      htResultNetwork = List<WifiNetwork>();
    }
    return htResultNetwork;
  }

  @override
  Widget build(BuildContext context) {
    //      Future.delayed(Duration(seconds: 5));
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              cargaLista();
              setState(() {});
            },
          )
        ],
        title: const Text('busqueda wifis'),
      ),
      body: ListView.builder(
          itemCount: null == _listwifi ? 0 : _listwifi.length,
          itemBuilder:
              /* (0 == _listwifi.length)
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
              : */
              (context, index) {
            WifiNetwork listalowifi = _listwifi[index];
            /*  (listalowifi.startsWith("STECH"))? */
            return InkWell(
                onTap: () {
                  dameSSID();
                  WiFiForIoTPlugin.disconnect();
                  _optionsDialogBox(listalowifi.ssid, context);
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

  void cargaLista() async {
    sinlimp = await loadWifiLista();
    setState(() {});
    if (_listwifi != null) _listwifi.clear();
    if (sinlimp != null) {
      for (int i = 0; i < sinlimp.length; i++) {
        if (sinlimp[i].ssid != "" && (sinlimp[i].ssid).startsWith("STECH"))
          _listwifi.add(sinlimp[i]);
      }
    }
  }

/*   void conectoEnvioDisconect(WifiNetwork wifiSelect) async {
    WiFiForIoTPlugin.disconnect();

    _optionsDialogBox(wifiSelect.ssid, contex);
    conectoAnterior();
  }

  void conectoAnterior() async {
     await Future.delayed(Duration(seconds: 10));
       WiFiForIoTPlugin.getSSID().then(
                              (val) => WiFiForIoTPlugin.removeWifiNetwork(val)) ;VER SI CONECTA Y LUEGO HABILITAR
    WiFiForIoTPlugin.connect(_ssidactual);
  }

    List<dynamic> armaLista(List<dynamic> _listwifi) {
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
  }  */

  void _envioUDPDesconecto() async {
    await Future.delayed(Duration(seconds: 10));
    // TODO: envio pack, no anda el "remove"
/*   dameSSID();
  WiFiForIoTPlugin.removeWifiNetwork(_ssidactual); */
    WiFiForIoTPlugin.disconnect();
  }

  Future<void> _optionsDialogBox(String ssid, BuildContext contex) {
    String _contra;
    return showDialog(
        context: contex,
        builder: (contex) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: TextFormField(
                      obscuringCharacter: '•',
                      decoration: InputDecoration(
                        labelText: "Contraseña:",
                      ),
                      controller: _contrasenia,
                      obscureText: true,
                    ),
                  ),
                  GestureDetector(
                    child: RaisedButton(
                      color: Theme.of(contex).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textColor: Colors.white,
                      onPressed: () {
                        _contra = _contrasenia.text;
                        WiFiForIoTPlugin.connect(
                          ssid,
                          security: NetworkSecurity.WPA,
                          password: _contra,
                          joinOnce: true,
                        );
                        WiFiForIoTPlugin.isConnected()
                            .then((val) => setState(() {
                                  _isConnected = val;
                                }));
                        if (!_isConnected) {
                          _showSnackbar(
                              "No se pudo conectar, verifique contraseña y trate nuevamente");
                        }
                        
                        _envioUDPDesconecto();
                        Navigator.of(contex).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Conectar a Wifi"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showSnackbar(dynamic e) {
    SnackBar snackbar = SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(
          label: "Ok",
          onPressed: () {},
        ));
    _scaffKey.currentState.showSnackBar(snackbar);
  }
}
