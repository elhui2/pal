import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:location/location.dart' as geoloc;

import '../scoped-models/main.dart';
import '../config.dart';
import '../widgets/ui_elements/nav_bar.dart';
import '../widgets/location/gmap.dart';

/**
 * alerts
 * @version 0.9.5
 * @author Daniel Huidobro <daniel@rebootproject.mx>
 * Boton de alerta del app
 */
class Alerts extends StatefulWidget {
  final Config config = Config();
  final MainModel model;
  Scaffold mainContainer;

  Alerts(this.model);

  @override
  State<StatefulWidget> createState() {
    return _AlertsState(model);
  }
}

class _AlertsState extends State<Alerts> {
  final location = geoloc.Location();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Constructor
  _AlertsState(this.model);

  //Objetos dinamicos
  BuildContext scaffoldContext;
  MainModel model;


  Gmap gMap = Gmap();

  @override
  initState() {
    location.onLocationChanged().listen((currentLocation) {
      model.setCurrentLocation(
          currentLocation.latitude, currentLocation.longitude);
      gMap.userLocation(model.currentLocation);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Container buttons = Container(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: <Widget>[
                Text(
                  "Seguridad",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  iconSize: MediaQuery.of(context).size.width / 3,
                  color: (model.getActiveAlert == true)
                      ? Colors.grey
                      : Colors.blue,
                  icon: Icon(Icons.add_alert),
                  onPressed: () {
                    _sendAlert(3);
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(32.0),
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: <Widget>[
                Text(
                  "Medico",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  iconSize: MediaQuery.of(context).size.width / 3,
                  color:
                      (model.getActiveAlert == true) ? Colors.grey : Colors.red,
                  icon: Icon(Icons.accessible),
                  onPressed: () {
                    //_sendAlert(4);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavBar(widget.model),
      appBar: AppBar(
        title: Text('Alerta'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              scaffoldContext = context;
              return IconButton(
                icon: Icon(Icons.gps_fixed),
                onPressed: () {
                  print("Buscar geolocalización");
                  location.hasPermission().then((permisions) {
                    if (permisions) {
                      location.getLocation().then((currentLoc) {
                        print(
                            "Mover Mapa a ${currentLoc.latitude},${currentLoc.longitude}");
                        model.setCurrentLocation(
                            currentLoc.latitude, currentLoc.longitude);
                        gMap.userLocation(model.currentLocation);
                      }).catchError((error) {
                        print("Error  ${error.toString()}");
                      }).then((currentLoc) {
                        print("Mover Mapa a ${currentLoc.toString()}");
                      });
                    } else {
                      location.requestPermission().then((request) {
                        print("Permisos geolocalizacion -> $request");
                        if (request == true) {
                          location.getLocation().then((currentLoc) {
                            print(
                                "Mover Mapa a ${currentLoc.latitude},${currentLoc.longitude}");
                            model.setCurrentLocation(
                                currentLoc.latitude, currentLoc.longitude);
                            gMap.userLocation(model.currentLocation);
                          }).catchError((error) {
                            print("Error  ${error.toString()}");
                          });
                        }
                      });
                    }
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
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            child: gMap,
          ),
          (model.isLoading)
              ? Center(child: CircularProgressIndicator())
              : buttons,
          Container(
            width: MediaQuery.of(context).size.width,
            height: 64,
            padding: const EdgeInsets.all(16.0),
            child: new FlatButton(
              textColor: Colors.white,
              color: (model.getActiveAlert == true) ? Colors.red : Colors.grey,
              onPressed: (() {
                _sendAlert(1);
              }),
              child: (model.getActiveAlert == true)
                  ? Text("Cancelar Alerta Activa")
                  : Text("No tienes alertas activas"),
            ),
          ),
        ],
      ),
    );
  }

  void _sendAlert(int type) async {
    model.sendAlert(type).then((response) {
      print("Respuesta de la alerta en UI $response loading ${model.isLoading} activeAlert ${model.getActiveAlert}");
      String _message = response['message'];
      if (response['success'] == true) {
        if (type == 1) {
          model.setActiveAlert(false);
        } else {
          model.setActiveAlert(true);
        }
      } else {
        if (type == 1) {
          model.setActiveAlert(false);
        }
      }

      final snackBar = new SnackBar(
        content: Text(_message),
        action: SnackBarAction(
          label: 'OK',
          onPressed: (() {}),
        ),
      );

      Scaffold.of(scaffoldContext).showSnackBar(snackBar);
    });
  }
}
