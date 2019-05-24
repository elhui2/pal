import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:location/location.dart' as geoloc;

import '../scoped-models/main.dart';
import '../config.dart';
import '../widgets/ui_elements/nav_bar.dart';
import '../widgets/location/gmap.dart';
import '../widgets/ui_elements/buttons_alert.dart';

/**
 * alerts
 * @version 0.9.7
 * @author Daniel Huidobro <daniel@rebootproject.mx>
 * Boton de alerta del app
 */
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              child: Gmap(model),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 9,
              color: Colors.deepOrange,
              child: Center(
                child: Text(
                  "Revisa tu ubicación en el mapa",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
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
                                child: IconButton(
                                  iconSize:
                                      MediaQuery.of(context).size.width / 3,
                                  color: Colors.blue,
                                  icon: Icon(Icons.security),
                                  onPressed: () {
                                    _sendAlert(3, model.sendAlert);
                                  },
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
                                child: IconButton(
                                  iconSize:
                                      MediaQuery.of(context).size.width / 3,
                                  color: Colors.red,
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    _sendAlert(4, model.sendAlert);
                                  },
                                ),
                              )
                            ])),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
