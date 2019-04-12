import 'package:flutter/material.dart';

class Refer {
  final int idRefer;
  final String name;
  final String email;
  final String phone;
  final String relationship;
  final String registerDate;

  Refer({
    @required this.idRefer,
    @required this.name,
    @required this.email,
    @required this.phone,
    @required this.relationship,
    @required this.registerDate,
  });
}
