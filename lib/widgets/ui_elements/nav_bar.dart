import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../scoped-models/main.dart';

class NavBar extends StatelessWidget {

  MainModel model;

  NavBar(this.model);

  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Seleccionar'),
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Mi PAL'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/alerts');
            },
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle),
            title: Text('Referidos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/refers');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Salir'),
            onTap: () {
              _logout(context);
            },
          )
        ],
      ),
    );
  }

  void _logout(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('firstName');
    prefs.remove('lastName');
    prefs.remove('email');
    prefs.remove('mobileNum');
    prefs.remove('token');
    prefs.clear();
    model.setUser(null);
    Navigator.pushReplacementNamed(context, '/');
  }
}
