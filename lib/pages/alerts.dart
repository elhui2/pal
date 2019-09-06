import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:location/location.dart' as geoloc;

import '../scoped-models/main.dart';
import '../config.dart';
import '../widgets/ui_elements/nav_bar.dart';
import '../widgets/location/gmap.dart';

///
/// alerts
/// @version 1.1
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //Objetos dinamicos, esto es una marranada
  BuildContext scaffoldContext;

  @override
  initState() {
    super.initState();
    print("Alerts initState");
  }

  void _sendAlert(int type, Function alert) async {
    alert(type).then((response) {
      print("Respuesta de la alerta en UI $response");
      if (!response["success"]) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alerta!'),
              content: Text(response['message']),
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: NavBar(model),
        appBar: AppBar(
          title: Text('Alertas'),
          actions: <Widget>[
            IconButton(
              icon: Icon((model.currentLocation == null)
                  ? Icons.gps_not_fixed
                  : Icons.gps_fixed),
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
                          model.setCurrentLocation(
                              currentLoc.latitude, currentLoc.longitude);
                          Navigator.pushReplacementNamed(context, '/');
                        }).catchError((error) {
                          print("Error  ${error.toString()}");
                        });
                      }
                    });
                  }
                });
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height / 16,
              child: Center(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.map,
                        color: Colors.deepOrange,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8),
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3.7,
              child: Gmap(model),
            ),
            Container(
              margin: EdgeInsets.only(top: 18),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Center(
                      child: Row(
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
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 18, bottom: 18),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Text(
                "De preferencia, revisa que tu ubicación en el mapa se a la correcta y presiona un tipo de alerta",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              child: Center(
                child: (model.getActiveAlert)
                    ? Center(
                        child: Column(children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Cancelar Alerta",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            iconSize: MediaQuery.of(context).size.width / 3,
                            color: Colors.red,
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              _sendAlert(1, model.sendAlert);
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
            Container(
              width: MediaQuery.of(context).size.width * .80,
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
            )
          ],
        ),
      );
    });
  }
}
