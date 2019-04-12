import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:location/location.dart' as geoloc;

import '../scoped-models/main.dart';
import '../config.dart';
import '../widgets/ui_elements/nav_bar.dart';
import '../widgets/location/gmap.dart';

/**
 * alerts
 * @version 0.7
 * @author Daniel Huidobro <daniel@rebootproject.mx>
 * Boton de alerta del app
 */
class Alerts extends StatefulWidget {
  final Config config = Config();
  final MainModel model;

  Alerts(this.model);

  @override
  State<StatefulWidget> createState() {
    return _AlertsState(model);
  }
}

class _AlertsState extends State<Alerts> {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final location = geoloc.Location();

  //Constructor
  _AlertsState(this.model);

  MainModel model;
  String osDevice;
  String idDevice;

  Gmap gMap = Gmap();

  @override
  initState() {
    location.onLocationChanged().listen((currentLocation) {
      print("Intentando moverme");
      if (currentLocation != null && model != null && gMap != null) {
        model.setCurrentLocation(
            currentLocation.latitude, currentLocation.longitude);
        gMap.userLocation(model.currentLocation);
      }
    });
    _deviceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IconButton _btnCancelar = IconButton(
      iconSize: 96.0,
      color: (model.getActiveAlert == true) ? Colors.red : Colors.grey,
      icon: Icon(Icons.cancel),
      onPressed: () {
        _sendAlert(1, widget.model);
      },
    );

    IconButton _btnMedico = IconButton(
      iconSize: 96.0,
      color: (model.getActiveAlert == true) ? Colors.grey : Colors.red,
      icon: Icon(Icons.accessible),
      onPressed: () {
        _sendAlert(4, widget.model);
      },
    );

    IconButton _btnSeguridad = IconButton(
      iconSize: 96.0,
      color: (model.getActiveAlert != null && model.getActiveAlert)
          ? Colors.grey
          : Colors.blue,
      icon: Icon(Icons.add_alert),
      onPressed: () {
        _sendAlert(3, model);
      },
    );

    return Scaffold(
      drawer: NavBar(widget.model),
      appBar: AppBar(
        title: Text('Alerta'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(Icons.gps_fixed),
                onPressed: () {
                  print("Buscar geolocalización");
                  location.hasPermission().then((permisions){
                    location.requestPermission().then((request){
                      print("Buscar geolocalización $request");
                    });
                  });
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: gMap,
          ),
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Cancelar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      _btnCancelar,
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Medico",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      _btnMedico,
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Seguridad",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      _btnSeguridad,
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Text("Presiona el boton indicado en caso de emergencia",
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  void _deviceInfo() async {
    if (Platform.isAndroid) {
      osDevice = "android";
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      idDevice = androidInfo.id;
    } else if (Platform.isIOS) {
      osDevice = "ios";
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      idDevice = iosInfo.identifierForVendor;
    }
  }

  void _sendAlert(int type, MainModel model) async {
    model.sendAlert(idDevice, type).then((response) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alerta!'),
            content: Text("Se ha actualizado el estado de tu alerta"),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
      if (response['success'] == true) {
        if (type == 1) {
          model.setActiveAlert(false);
        } else {
          model.setActiveAlert(true);
        }
      } else {
        if (type == 1) {
          model.setActiveAlert(false);
        } else {}
      }
    });
  }
}
