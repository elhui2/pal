import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:toast/toast.dart';
import 'dart:io' show Platform;

import '../scoped-models/main.dart';

///
/// Register
/// @version 1.6
/// @author Daniel Huidobro <daniel@rebootproject.mx>
///
class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  
  final Map<String, dynamic> _formData = {
    'name': null,
    'email': null,
    'phone': null,
    'password': null,
    'acceptTerms': false,
    'osdevice': null,
    'idDevice': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Nombre Completo',
          filled: true,
          fillColor: Colors.black12),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty || value.length < 4) {
          return 'Nombre Invalido';
        }
      },
      onSaved: (String value) {
        _formData['name'] = value;
      },
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.black12),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPhoneTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Telefono Celular',
          filled: true,
          fillColor: Colors.black12),
      keyboardType: TextInputType.phone,
      validator: (String value) {
        if (!value.isEmpty && value.length != 10) {
          return 'Telefono invalido';
        }
      },
      onSaved: (String value) {
        _formData['phone'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.black12),
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 4) {
          return 'Password invalid';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  void _submitForm(Function register) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      //TODO: En android sacar el id del device o mejor guardar el token de firebase
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.androidId}');
      _formData['osdevice'] = "android";
      _formData['idDevice'] = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.identifierForVendor}');
      _formData['osdevice'] = "ios";
      _formData['idDevice'] = iosInfo.identifierForVendor;
    }

    _formKey.currentState.save();

    register(_formData['name'], _formData['email'], _formData['phone'],
            _formData['password'], _formData['osdevice'], _formData['idDevice'])
        .then((response) {
      print("Desde login R" + response.toString());
      Toast.show(response['message'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      if (response['success']) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro PAL'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildNameTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPhoneTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (BuildContext context, Widget child,
                          MainModel model) {
                        return RaisedButton(
                          textColor: Colors.white,
                          child: Text('Entrar'),
                          onPressed: () => _submitForm(model.register),
                        );
                      },
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
