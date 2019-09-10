import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../scoped-models/main.dart';

///
/// AlertList
/// @version 1.1
/// @author Daniel Huidobro daniel@rebootproject.mx
/// 
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
                    title: Text(
                      formatDate(model.allAlerts[index].registerDate),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text('${model.allAlerts[index].type.toString()} | ${model.allAlerts[index].status.toString()}'),
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

  formatDate(String date) {
    var nowTim = DateTime.parse(date);
    initializeDateFormatting("es");
    String dateformat =
        new DateFormat("d 'de' MMMM 'de' yyyy | H:mm", "es").format(nowTim);
    print(dateformat);
    return dateformat;
  }
}
