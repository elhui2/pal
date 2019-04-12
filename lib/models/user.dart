import 'package:flutter/material.dart';

class User {
  final int idUser;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String token;
  final String idDevice;

  User(
      {@required this.idUser,
      @required this.firstName,
      @required this.lastName,
      @required this.email,
      @required this.phone,
      @required this.token,
      @required this.idDevice});
}
