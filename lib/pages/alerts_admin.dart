import 'package:flutter/material.dart';

import './profile_edit.dart';
import './alert_list.dart';
import '../scoped-models/main.dart';
import '../widgets/ui_elements/nav_bar.dart';

class AlertsAdmin extends StatelessWidget {
  final MainModel model;

  AlertsAdmin(this.model);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: NavBar(model),
        appBar: AppBar(
          title: Text('Mi Pal'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.warning),
                text: 'Mis Alertas',
              ),
              Tab(
                icon: Icon(Icons.verified_user),
                text: 'Datos de Usuario',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[AlertList(model), ProfileEdit()],
        ),
      ),
    );
  }
}
