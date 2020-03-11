import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:toast/toast.dart';

import '../scoped-models/main.dart';
import '../scoped-models/users.dart';

///
/// forgot.dart
/// @version 1.6
/// @author Daniel Huidobro <daniel@rebootproject.mx>
/// TODO: Agregar una imagen
///
class ForgotPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotPageState();
  }
}

class _ForgotPageState extends State<ForgotPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Ingresa tu dirección de correo',
        filled: true,
        fillColor: Colors.black12,
      ),
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

  void _submitForm(Function forgot) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    forgot(_formData['email']).then((response) {
      print("Forgot result -> " + response.toString());
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
    final UsersModel model = UsersModel();

    return ScopedModel<UsersModel>(
      model: model,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recuperar Contraseña'),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: targetWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/logo_pal_orange.png',
                        width: 96,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildEmailTextField(),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        child: Text('Enviar instrucciones'),
                        onPressed: () => _submitForm(model.forgot),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
