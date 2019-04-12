import 'package:flutter/material.dart';

import './ref_edit.dart';
import '../widgets/ui_elements/nav_bar.dart';
import './ref_list.dart';
import '../scoped-models/main.dart';

class RefersAdmin extends StatelessWidget {
  final MainModel model;

  RefersAdmin(this.model);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: NavBar(model),
        appBar: AppBar(
          title: Text('Referidos'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.supervised_user_circle),
                text: 'Mis referidos',
              ),
              Tab(
                icon: Icon(Icons.add_circle),
                text: 'Agregar Referido',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[RefList(model), RefEdit()],
        ),
      ),
    );
  }
}
