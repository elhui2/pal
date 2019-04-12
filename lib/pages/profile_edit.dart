import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/helpers/ensure_visible.dart';
import '../scoped-models/main.dart';
import '../models/user.dart';

class ProfileEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileEditState();
  }
}

class _ProfileEditState extends State<ProfileEdit> {
  String password = '';
  String confPassword = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();
  final _confPasswordFocusNode = FocusNode();

   Widget _buildPasswordField(User user) {
     return EnsureVisibleWhenFocused(
       focusNode: _passwordFocusNode,
       child: TextFormField(
         focusNode: _passwordFocusNode,
         obscureText: true,
         decoration: InputDecoration(labelText: 'Contraseña'),
         initialValue: '',
         validator: (String value) {
           password = value;
           if (value.isEmpty || value.length < 6) {
             return 'El password es requerido y debe tener 6+ caracteres';
           }
         },
         onSaved: (String value) {
           password = value;
         },
       ),
     );
   }

   Widget _buildConfPasswordFocusNode(User user) {
     return EnsureVisibleWhenFocused(
       focusNode: _confPasswordFocusNode,
       child: TextFormField(
         focusNode: _confPasswordFocusNode,
         obscureText: true,
         decoration: InputDecoration(labelText: 'Confirmar contraseña'),
         initialValue: '',
         validator: (String value) {
           if (value != password) {
             print("Los passwords $password y $value son diferentes");
             return 'Las contraseñas deben coincidir';
           }
         },
         onSaved: (String value) {
           confPassword = value;
         },
       ),
     );
   }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Actualizar'),
                textColor: Colors.white,
                 onPressed: () => _submitForm(model.updateUser),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, User user) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
               _buildPasswordField(user),
               _buildConfPasswordFocusNode(user),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

   void _submitForm(Function updateUser) {
     if (!_formKey.currentState.validate()) {
       return;
     }
     _formKey.currentState.save();

     updateUser(password).then((response){
        print('Respuesta $response');
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
                    _formKey.currentState.reset();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        if(response['success']==true){

        }else{

        }
     });

   }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.user);
        return pageContent;
      },
    );
  }
}
