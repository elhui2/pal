import 'package:flutter/material.dart';

class Alert {
  final int idAlert;
  final String status;
  final String type;
  final String registerDate;

  Alert({
    @required this.idAlert,
    @required this.status,
    @required this.type,
    @required this.registerDate,
  });
}
