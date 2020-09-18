import 'package:flutter/material.dart';

class DeviceInfo {
  int idDevicePal;
  String regDatePal;
  int idUserPal;
  final String vendorKey; // UUID uuid de apple o el id android
  final String type;
  final String versionOs;
  final String model;
  final String vendorToken; // Puede ser transaccional de Firebase
  DeviceInfo(
      {@required this.idDevicePal,
      @required this.regDatePal,
      @required this.vendorKey,
      @required this.type,
      @required this.versionOs,
      @required this.model,
      @required this.vendorToken});
}
