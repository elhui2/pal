import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped-models/main.dart';

/**
 * AuthPage
 * @version 0.5
 * @author Daniel Huidobro <daniel@rebootproject.mx>
 */
class ButtonsAlert extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ButtonsAlertState();
  }
}

class _ButtonsAlertState extends State<ButtonsAlert> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return (model.getActiveAlert)
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
                    onPressed: () {},
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
                          iconSize: MediaQuery.of(context).size.width / 3,
                          color: Colors.blue,
                          icon: Icon(Icons.security),
                          onPressed: () {},
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
                          iconSize: MediaQuery.of(context).size.width / 3,
                          color: Colors.red,
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {},
                        ),
                      )
                    ])),
                  ),
                ],
              );
      },
    );
  }
}
