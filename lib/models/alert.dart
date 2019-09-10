import 'package:flutter/material.dart';

///
/// Alert
/// @version 1.1
/// @author Daniel Huidobro daniel@rebootproject.mx
/// Modelo de alertas
///
class Alert {
  final int idAlert;
  final String idDevice;
  final int idUser;
  final String status;
  final String type;
  final String registerDate;

  Alert({
    @required this.idAlert,
    @required this.idDevice,
    @required this.idUser,
    @required this.status,
    @required this.type,
    @required this.registerDate,
  });

  Map<String, dynamic> toSqlMap() {
    return {
      'id_alert': idAlert,
      'id_device': idDevice,
      'id_user': idUser,
      'status': status,
      'type': type,
      'register_date': registerDate
    };
  }

  factory Alert.fromMap(Map<String, dynamic> json) => new Alert(
        idAlert: json["id_alert"],
        idDevice: json["id_device"],
        idUser: json["id_user"],
        status: json["status"],
        type: json["type"],
        registerDate: json["register_date"],
      );
}
