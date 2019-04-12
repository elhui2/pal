import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/helpers/ensure_visible.dart';
import '../models/refer.dart';
import '../scoped-models/main.dart';

/**
 * RefEdit
 * @version 0.7
 * @author Daniel Huidobro <daniel@rebootproject.mx>
 * Edicion de una referencia
 */
class RefEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RefEditState();
  }
}

class _RefEditState extends State<RefEdit> {

  final Map<String, dynamic> _formData = {
    'idRefer': null,
    'name': null,
    'email': null,
    'phone': null,
    'relationship': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _relationshipFocusNode = FocusNode();

  Widget _buildNameTextField(Refer refer) {
    return EnsureVisibleWhenFocused(
      focusNode: _nameFocusNode,
      child: TextFormField(
        focusNode: _nameFocusNode,
        decoration: InputDecoration(labelText: 'Nombre Completo'),
        initialValue: refer == null ? '' : refer.name,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 4) {
            return 'El Nombre es requerido y debe tener 4+ caracteres';
          }
        },
        onSaved: (String value) {
          _formData['name'] = value;
        },
      ),
    );
  }

  Widget _buildEmailTextField(Refer refer) {
    return EnsureVisibleWhenFocused(
      focusNode: _emailFocusNode,
      child: TextFormField(
        focusNode: _emailFocusNode,
        decoration: InputDecoration(labelText: 'Correro Electronico'),
        initialValue: refer == null ? '' : refer.email,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty ||
              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
            return 'Ingresa una dirección de email valida';
          }
        },
        onSaved: (String value) {
          _formData['email'] = value;
        },
      ),
    );
  }

  Widget _buildPhoneTextField(Refer refer) {
    return EnsureVisibleWhenFocused(
      focusNode: _phoneFocusNode,
      child: TextFormField(
        focusNode: _phoneFocusNode,
        decoration: InputDecoration(labelText: 'Celular'),
        initialValue: refer == null ? '' : refer.phone,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length != 10) {
            return 'El telefono es requerido y debe tener 10 caracteres';
          }
        },
        onSaved: (String value) {
          _formData['phone'] = value;
        },
      ),
    );
  }

  String selectedRelation;

  Widget _buildRelationshipField(Refer refer) {
    if (refer != null && selectedRelation == null) {
      selectedRelation = refer.relationship;
    }
    List<String> relations = ['padre', 'hermano', 'pareja', 'amigo', 'otro'];
    return EnsureVisibleWhenFocused(
      focusNode: _relationshipFocusNode,
      child: new DropdownButtonFormField<String>(
        hint: new Text("Seleccionar parentesco"),
        value: selectedRelation,
        validator: (String value) {
          if (value == null || value.isEmpty) {
            return 'Debes seleccionar una opción';
          }
        },
        onChanged: (String value) {
          print(value);
          setState(() {
            selectedRelation = value;
            print(selectedRelation);
          });
        },
        onSaved: (String value) {
          _formData['relationship'] = value;
        },
        items: relations.map((String relation) {
          return new DropdownMenuItem<String>(
            value: relation,
            child: new Text(
              relation,
              style: new TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Guardar'),
                textColor: Colors.white,
                onPressed: () => _submitForm(model.addRefer, model.updateRefer,
                    model.selectRefer, model.selectedReferIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Refer refer) {
    print(refer.toString());
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
              _buildNameTextField(refer),
              _buildEmailTextField(refer),
              _buildPhoneTextField(refer),
              _buildRelationshipField(refer),
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

  void _submitForm(
      Function addRefer, Function updateRefer, Function setSelectedRefer,
      [int selectedBookIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedBookIndex == null) {
      addRefer(
        _formData['name'],
        _formData['email'],
        _formData['phone'],
        _formData['relationship'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/refers')
            .then((_) => setSelectedRefer(null));
      });
    } else {
      updateRefer(
        _formData['name'],
        _formData['email'],
        _formData['phone'],
        _formData['relationship'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/refers')
            .then((_) => setSelectedRefer(null));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedRefer);
        return model.selectedReferIndex == null
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Editar Referido'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
