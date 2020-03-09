import 'package:flutter/material.dart';
import 'package:pal/database/alerts_db.dart';
import 'package:pal/models/alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:toast/toast.dart';
import 'package:location/location.dart' as geoloc;

import '../scoped-models/main.dart';
import '../config.dart';
import '../widgets/ui_elements/nav_bar.dart';
import '../widgets/location/gmap.dart';

///
/// alerts
/// @version 1.6.1
/// @author Daniel Huidobro <daniel@rebootproject.mx>
/// Boton de alerta del app
///
class Alerts extends StatefulWidget {
  final Config config = Config();
  final MainModel model;

  Alerts(this.model);

  @override
  State<StatefulWidget> createState() {
    return _AlertsState();
  }
}

class _AlertsState extends State<Alerts> {
  final location = geoloc.Location();

  @override
  initState() {
    widget.model.checkToken();
    super.initState();
  }

  void _sendAlert(int type, Function alert) async {
    alert(type).then((response) {
      Toast.show(response['message'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  void _cancelAlert(Function cancel, Function activeAlert) async {
    AlertsDb.db.getStatusAlert().then((alert) {
      if (alert == null) {
        activeAlert(false);
        Toast.show("No encontramos alerta activa", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else if (alert.status == "sync") {
        Alert syncAlert = Alert(
            idAlert: alert.idAlert,
            idDevice: alert.idDevice,
            idUser: alert.idUser,
            type: alert.type,
            status: "complete",
            registerDate: "");
        AlertsDb.db.updateAlert(syncAlert);
        Toast.show("Tu alerta se ha cancelado", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        activeAlert(false);
      } else if (alert.status == "process") {
        cancel(alert).then((response) {
          Toast.show(response['message'], context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      AlertsDb.db.getStatusAlert().then((alert) {
        if (alert == null) {
          model.setActiveAlert(false);
        } else if (alert.status == "process") {
          // print("Hay alerta activa en el dispositivo, ya esta en el servidor!");
          model.setActiveAlert(true);
        } else if (alert.status == "sync") {
          // print(
          //     "Hay alerta activa en el dispositivo, esperando como perro internet!");
          model.syncAlert(alert);
          model.setActiveAlert(true);
        }
      });
      return Scaffold(
        // key: _scaffoldKey,
        drawer: NavBar(model),
        appBar: AppBar(
          title: Text('Alertas'),
          actions: <Widget>[
            // TODO: Esto para otra version con la funcion de tomar foto
            // IconButton(
            //   icon: Icon((model.currentLocation == null)
            //       ? Icons.gps_not_fixed
            //       : Icons.gps_fixed),
            //   onPressed: () {
            //     location.hasPermission().then((permisions) {
            //       print("NavButton hasPermission $permisions");
            //       if (permisions == false) {
            //         location.requestPermission().then((request) {
            //           print("NavButton requestPermission $request");
            //           if (request == true) {
            //             location.getLocation().then((currentLoc) {
            //               print(
            //                   "NavButton getLocation ${currentLoc.latitude},${currentLoc.longitude}");
            //               model.setCurrentLocation(
            //                   currentLoc.latitude, currentLoc.longitude);
            //               Navigator.pushReplacementNamed(context, '/');
            //             }).catchError((error) {
            //               print("Error  ${error.toString()}");
            //             });
            //           }
            //         });
            //       }
            //     });
            //   },
            // )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Icon(
                          Icons.map,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Container(
                        child: Text(
                          "Revisa tu ubicación en el mapa",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: Gmap(model),
              ),
            ),
            Expanded(
              flex: 1,
              child: (model.currentLocation != null &&
                      model.currentLocation.latitude != 0)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.notifications,
                            color: Colors.deepOrange,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: Text(
                            "Selecciona tipo de alerta",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text(
                        "Solicitar permisos de ubicación",
                      ),
                      onPressed: () {
                        location.hasPermission().then((permisions) {
                          print("NavButton hasPermission $permisions");
                          if (permisions == false) {
                            location.requestPermission().then((request) {
                              print("NavButton requestPermission $request");
                              if (request == true) {
                                location.getLocation().then((currentLoc) {
                                  print(
                                      "NavButton getLocation ${currentLoc.latitude},${currentLoc.longitude}");
                                  model.setCurrentLocation(currentLoc.latitude,
                                      currentLoc.longitude);
                                  Navigator.pushReplacementNamed(context, '/');
                                }).catchError((error) {
                                  print("Error  ${error.toString()}");
                                });
                              }
                            });
                          }
                        });
                      },
                    ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * .90,
                child: Text(
                  "Revisa que tu ubicación en el mapa sea la correcta y selecciona un tipo de alerta",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: (model.getActiveAlert)
                    ? Center(
                        child: Column(children: <Widget>[
                        Container(
                          child: Text(
                            "Cancelar Alerta",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: FlatButton(
                            padding: EdgeInsets.all(0.0),
                            child: Image.asset('assets/bt_cancel.png'),
                            onPressed: () {
                              _cancelAlert(
                                  model.cancelAlert, model.setActiveAlert);
                            },
                          ),
                        )
                      ]))
                    : Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Center(
                                child: Column(children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Policía",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: FlatButton(
                                  onPressed: () {
                                    _sendAlert(3, model.sendAlert);
                                  },
                                  padding: EdgeInsets.all(0.0),
                                  child: Image.asset('assets/bt_police.png'),
                                ),
                              )
                            ])),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Center(
                              child: Column(children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Médico",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: FlatButton(
                                    onPressed: () {
                                      _sendAlert(4, model.sendAlert);
                                    },
                                    padding: EdgeInsets.all(0.0),
                                    child: Image.asset('assets/bt_medic.png'),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    height: 1,
                    color: Colors.black26,
                  ),
                  Text(
                    "Copyright Reset 2000",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w100,
                      color: Colors.deepOrange,
                      // fontStyle: FontStyle.italic
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
