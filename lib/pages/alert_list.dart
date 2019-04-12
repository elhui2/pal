import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';

class AlertList extends StatefulWidget {
  final MainModel model;
  AlertList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _AlertListState();
  }
}

class _AlertListState extends State<AlertList> {
  @override
  initState() {
    widget.model.fetchAlerts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allAlerts[index].status),
              onDismissed: (DismissDirection direction) {
                print(direction.toString());
              },
              //background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(model.allAlerts[index].registerDate),
                    subtitle:
                        Text('${model.allAlerts[index].status.toString()}'),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allAlerts.length,
        );
      },
    );
  }
}
