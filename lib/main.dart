import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './config.dart';
import './pages/auth.dart';
import './pages/alerts_admin.dart';
import './pages/refers_admin.dart';
import './pages/alerts.dart';
import './scoped-models/main.dart';

///
/// main.dart
/// @version 0.9.7
/// @author Daniel Huidobro daniel@rebootproject.mx
///
void main() {
  final Config config = Config();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();

  @override
  void initState() {
    _model.autoAuthenticate().then((success) {
      if (success) {
        _model.checkToken();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepOrangeAccent,
            buttonColor: Colors.deepOrange),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant(builder:
                  (BuildContext context, Widget child, MainModel model) {
                return model.user == null ? AuthPage() : Alerts(_model);
              }),
          '/alerts': (BuildContext context) => AlertsAdmin(_model),
          '/refers': (BuildContext context) => RefersAdmin(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {},
      ),
    );
  }
}
