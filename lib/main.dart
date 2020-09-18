import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;

import './config.dart';
import './models/deviceInfo.dart';
import './pages/auth.dart';
import './pages/alerts_admin.dart';
import './pages/refers_admin.dart';
import './pages/alerts.dart';
import './scoped-models/main.dart';

///
/// main.dart
/// @version 1.8
/// @author Daniel Huidobro daniel@rebootproject.mx
///
void main() {
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
    super.initState();
    infoDevice();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepOrangeAccent,
            buttonColor: Colors.deepOrange),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant(builder:
                  (BuildContext context, Widget child, MainModel model) {
                return Alerts(_model);
              }),
          '/alerts': (BuildContext context) => AlertsAdmin(_model),
          '/refers': (BuildContext context) => RefersAdmin(_model),
          '/login': (BuildContext context) => AuthPage(),
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

  ///
  ///infoDevice
  ///@version 1.8
  ///Saca la info del dispositivo
  ///
  Future<void> infoDevice() async {
    //OS Info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    DeviceInfo device;
    if (Platform.isAndroid) {
      print('Running on Android');
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = new DeviceInfo(
          idDevicePal: null,
          vendorKey: androidInfo.androidId,
          type: 'android',
          versionOs: androidInfo.version.toString(),
          model: androidInfo.model,
          vendorToken: null,
          regDatePal: null);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on Ios' + iosInfo.identifierForVendor);
      device = new DeviceInfo(
        idDevicePal: null,
        vendorKey: iosInfo.identifierForVendor, //UUID
        type: 'ios',
        versionOs: iosInfo.systemVersion,
        model: iosInfo.utsname.machine,
        vendorToken: null, regDatePal: null,
      );
    }
    //Update device in server
    _model.setDeviceinfo(device).then((_) {
      _model.checkToken();
    });
  }
}
