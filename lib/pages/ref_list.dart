import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './ref_edit.dart';
import '../scoped-models/main.dart';

class RefList extends StatefulWidget {
  final MainModel model;
  RefList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _RefListState();
  }
}

class _RefListState extends State<RefList> {
  @override
  initState() {
    widget.model.fetchRefers();
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectRefer(index);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return RefEdit();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allRefers[index].name),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectRefer(index);
                  model.deleteRefer();
                } else if (direction == DismissDirection.startToEnd) {
                  print('Swiped start to end');
                } else {
                  print('Other swiping');
                }
              },
              background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    // leading: CircleAvatar(
                    //   backgroundImage:
                    //       NetworkImage(model.allBooks[index].image),
                    // ),
                    title: Text(model.allRefers[index].name),
                    subtitle: Text(
                        '${model.allRefers[index].phone.toString() + '/' + model.allRefers[index].email.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allRefers.length,
        );
      },
    );
  }
}
