import 'dart:convert';
import 'dart:async';
import 'package:pal/database/alerts_db.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/deviceInfo.dart';
import '../models/refer.dart';
import '../models/alert.dart';
import '../models/user.dart';
import '../models/location_data.dart';

///
/// ConnectedPalsModel
/// @version 1.8
/// @author Daniel Huidobro <daniel@rebootproject.mx>
/// Modelo principal del app
///
class ConnectedPalsModel extends Model {
  final Config config = new Config();
  List<Alert> _alerts = [];
  List<Refer> _refers = [];
  int _selReferIndex;
  User _authenticatedUser;
  LocationData _userCurrentLocation;
  bool _isLoading = false;
  bool _activeAlert = false;
  DeviceInfo _deviceInfo;

  Future<void> setDeviceinfo(DeviceInfo device) async {
    http.Response _response;
    Map<String, dynamic> responseData;
    try {
      _response = await http.post(config.apiUrl + '/devices/check', body: {
        'vendor_key': device.vendorKey,
        'type': device.type,
        'model': device.model,
        'version_os': device.versionOs
      });

      // print(_response.toString());

      responseData = json.decode(_response.body);

      print(_response.body);

      if (responseData["status"] == true) {
        print("uuid de respuesta ----->" +
            responseData['response']['vendor_key']);
        _deviceInfo = new DeviceInfo(
            idDevicePal: responseData['response']['id_device'],
            regDatePal: responseData['response']['register_date'],
            vendorKey: responseData['response']['vendor_key'],
            type: responseData['response']['type'],
            versionOs: responseData['response']['version_os'].toString(),
            model: responseData['response']['model'],
            vendorToken: null);
        notifyListeners();
        return {'success': true, 'message': 'El dispositivo se ha actualizado'};
      } else {
        return {'success': false, 'message': responseData['message']};
      }
    } catch (_ex) {
      print("Error en setDeviceinfo ->" + _ex.toString());
      return {
        'success': false,
        'message': 'No pudimos conectarnos con el servidor, intentalo más tarde'
      };
    }
  }

  DeviceInfo getDeviceInfo() {
    return _deviceInfo;
  }
}

class AlertsModel extends ConnectedPalsModel {
  ///
  /// fetchAlerts
  /// @version 0.8
  /// @author Daniel Huidobro daniel@rebootproject.mx
  /// Listar referidos
  ///
  Future<Null> fetchAlerts() {
    _isLoading = true;
    return http
        .get(config.apiUrl + '/users_alerts/get/${_authenticatedUser.idUser}')
        .then((http.Response response) {
      //print(config.apiUrl + '/users_alerts/get/${_authenticatedUser.idUser}');
      final Map<String, dynamic> alertListData = jsonDecode(response.body);
      //print(response.body);

      if (alertListData['status'] == false) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<Alert> fetchAlertList = [];
      AlertsDb.db.deleteTable();
      print(alertListData['response']);
      alertListData['response'].forEach((dynamic alertData) {
        final Alert alert = Alert(
          idAlert: alertData['id_alert'],
          idDevice: alertData['id_device'].toString(),
          idUser: alertData['id_user'],
          status: alertData['status'],
          type: alertData['type'],
          registerDate: alertData['register_date'],
        );
        AlertsDb.db.newAlert(alert);
        fetchAlertList.add(alert);
      });

      _alerts = fetchAlertList;
      _isLoading = false;
      notifyListeners();
    });
  }

  void setActiveAlert(bool alert) {
    if (alert) {
      _activeAlert = true;
    } else {
      _activeAlert = false;
    }
    notifyListeners();
  }

  ///
  /// cancelAlert
  /// @version 1.8
  /// Cancelar una alerta
  ///
  Future<Map<String, dynamic>> cancelAlert(Alert localAlert) async {
    _isLoading = true;
    print("Cancelar la alerta!");
    notifyListeners();
    http.Response _response;
    Map<String, dynamic> responseData;

    try {
      _response = await http.post(config.apiUrl + '/alerts_app/cancel', body: {
        'device': _deviceInfo.vendorKey,
        'lat': _userCurrentLocation.latitude.toString(),
        'lng': _userCurrentLocation.longitude.toString(),
        'token': "1234"
      });
      print("Cancelar la alerta -> " + _response.body);

      responseData = json.decode(_response.body);

      if (responseData["status"] == true) {
        _activeAlert = false;
        notifyListeners();
        fetchAlerts();
        return {
          'success': true,
          'message': 'Tu alerta se ha cancelado con éxito'
        };
      } else {
        return {'success': false, 'message': responseData['message']};
      }
    } catch (_ex) {
      print("Error en alerta ->" + _ex.toString());
      return {
        'success': false,
        'message': 'No pudimos conectarnos con el servidor, intentalo más tarde'
      };
    }
  }

  ///
  /// SendAlert
  /// @version 1.8
  /// Envia una alerta al servidor
  ///
  Future<Map<String, dynamic>> sendAlert(int type) async {
    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';

    http.Response _response;
    Map<String, dynamic> responseData;
    print("Vendor Key " + _deviceInfo.vendorKey);
    var _dataRequest = {};
    if (_authenticatedUser == null) {
      _dataRequest = {
        'device': _deviceInfo.vendorKey,
        'lat': (_userCurrentLocation != null)
            ? _userCurrentLocation.latitude.toString()
            : 0,
        'lng': (_userCurrentLocation != null)
            ? _userCurrentLocation.longitude.toString()
            : 0,
        'type': (type == 3) ? "policia" : "medico",
      };
    } else {
      _dataRequest = {
        'device': _deviceInfo.vendorKey,
        'lat': (_userCurrentLocation != null)
            ? _userCurrentLocation.latitude.toString()
            : 0,
        'lng': (_userCurrentLocation != null)
            ? _userCurrentLocation.longitude.toString()
            : 0,
        'token': "token",
        'type': (type == 3) ? "policia" : "medico"
      };
    }

    try {
      print(_dataRequest.toString());
      _response =
          await http.post(config.apiUrl + '/alerts_app', body: _dataRequest);
      responseData = json.decode(_response.body);
      print("Alert Alert" + _response.body);
      if (responseData['status'] == 'active') {
        _activeAlert = true;
      }
      // print("Alert Response" + _response.body);
    } catch (_ex) {
      AlertsDb.db.newAlert(new Alert(
          //idAlert: 0,
          idDevice:
              (_deviceInfo != null) ? _deviceInfo.idDevicePal.toString() : "",
          idUser: (_authenticatedUser == null) ? 0 : _authenticatedUser.idUser,
          status: "sync",
          type: type.toString(),
          registerDate: ""));
      print("Error en sendAlert() ->" + _ex.toString());
      return {
        'success': false,
        'message':
            'No pudimos conectarnos con el servidor, intentalo más tarde o revisa tu conexión'
      };
    }

    if (responseData['status'] == true) {
      success = true;
      message = responseData['message'];
    } else {
      success = false;
      message = responseData['message'];
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  ///
  /// syncAlert
  /// @version 1.8
  /// Sincroniza una alerta de la base de datos
  ///
  Future syncAlert(Alert alert) async {
    http.Response _response;
    Map<String, dynamic> responseData;

    try {
      print("Current Location" + alert.type);
      _response = await http.post(config.apiUrl + '/alerts', body: {
        'device': _deviceInfo.idDevicePal,
        'code_panic': alert.type.toString(),
        // 'lat': _userCurrentLocation.latitude.toString(),
        // 'lng': _userCurrentLocation.longitude.toString(),
        'register_device': alert.registerDate
      });

      responseData = json.decode(_response.body);
    } catch (_ex) {
      print("syncAlert err -> " + _ex.toString());
      return;
    }

    if (responseData['status'] == true) {
      //fetchAlerts();
    } else {
      print("No se pudo sincronizar la alerta");
    }
  }

  List<Alert> get allAlerts {
    return List.from(_alerts);
  }

  bool get getActiveAlert {
    return _activeAlert;
  }
}

class RefersModel extends ConnectedPalsModel {
  /**
   * fetchRefers
   * Listar referidos
   */
  Future<Null> fetchRefers() {
    _isLoading = true;
    return http
        .get(config.apiUrl + '/refers/get/${_authenticatedUser.idUser}')
        .then((http.Response response) {
      print(response.body);
      final Map<String, dynamic> referListData = jsonDecode(response.body);
      if (referListData['status'] == false) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final List<Refer> fetchReferList = [];
      referListData['response'].forEach((dynamic referData) {
        final Refer refer = Refer(
            idRefer: referData['id_user_reference'],
            name: referData['name'],
            email: referData['email'],
            phone: referData['phone'].toString(),
            relationship: referData['relationship'],
            registerDate: referData['register_date']);
        fetchReferList.add(refer);
      });
      _refers = fetchReferList;
      _isLoading = false;
      notifyListeners();
    });
  }

  ///
  /// addRefer
  /// @version 1.3
  /// Agrega un referido al servidor
  ///
  Future<Null> addRefer(
      String name, String email, String phone, String relationship) {
    _isLoading = true;
    notifyListeners();
    return http.post(config.apiUrl + '/refers/add', body: {
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship,
      'userId': _authenticatedUser.idUser.toString()
    }).then((http.Response response) {
      print(response.body);
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status']) {
        final Refer newRefer = Refer(
            idRefer: responseData['response']['id_user_reference'],
            name: responseData['response']['name'],
            email: responseData['response']['email'],
            phone: responseData['response']['phone'].toString(),
            relationship: responseData['response']['relationship'],
            registerDate: responseData['response']['register_date']);
        _refers.add(newRefer);
      } else {
        //TODO: Cachar errores
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  ///
  /// addRefer
  /// @version 1.3
  /// Agrega un referido al servidor
  ///
  Future<Null> updateRefer(
      String name, String email, String phone, String relationship) {
    return http.post(config.apiUrl + '/refers/update', body: {
      'id_user_reference': selectedRefer.idRefer.toString(),
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship
    }).then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status']) {
        final Refer updatedRefer = Refer(
            idRefer: responseData['response']['id_user_reference'],
            name: responseData['response']['name'],
            email: responseData['response']['email'],
            phone: responseData['response']['phone'].toString(),
            relationship: responseData['response']['relationship'],
            registerDate: responseData['response']['register_date']);
        _refers[selectedReferIndex] = updatedRefer;
      } else {
        //TODO: Cachar errores
      }
      _isLoading = false;
      _selReferIndex = null;
      notifyListeners();
    });
  }

  /**
   * deleteRefer
   * Elimina un referido
   */
  void deleteRefer() {
    _isLoading = true;
    final int deleteReferId = selectedRefer.idRefer;
    _refers.remove(selectedRefer);
    _selReferIndex = null;
    notifyListeners();
    http.post(config.apiUrl + "/refers/delete", body: {
      'id_user_reference': deleteReferId.toString()
    }).then((http.Response response) {
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Refer> get allRefers {
    return List.from(_refers);
  }

  int get selectedReferIndex {
    return _selReferIndex;
  }

  void selectRefer(int index) {
    _selReferIndex = index;
    notifyListeners();
  }

  Refer get selectedRefer {
    if (selectedReferIndex == null) {
      return null;
    }
    return _refers[selectedReferIndex];
  }
}

///
/// UserModel
/// @version 0.7
/// Modelo del usuario
/// TODO:Ver los warninds de todos los modelos
///
class UserModel extends ConnectedPalsModel {
  void setCurrentLocation(double lat, double lng) {
    print("Hello setCurrentLocation!");
    if (lat != null && lat > 0) {
      _userCurrentLocation = new LocationData(
          latitude: lat, longitude: lng, description: null, address: null);
    }
    if (_activeAlert) {
      track();
    }
    notifyListeners();
  }

  LocationData get currentLocation {
    return _userCurrentLocation;
  }

  User get user {
    return _authenticatedUser;
  }

  void setUser(value) {
    _authenticatedUser = value;
  }

  ///
  ///login
  ///@version 1.0
  ///Login del app
  ///
  Future<Map<String, dynamic>> login(
      String email, String password, String osDevice, String idDevice) async {
    http.Response _response;
    try {
      _response = await http.post(config.apiUrl + '/users/login', body: {
        "email": email,
        "password": password,
        'osdevice': osDevice,
        'id_device': idDevice
      });
    } catch (err) {
      print("Error en login" + err.toString());
      return {
        'success': false,
        'message': "No tienes conexión con el servidor"
      };
    }
    print(_response.body);
    final Map<String, dynamic> responseData = json.decode(_response.body);

    bool hasError = true;
    String message = 'Ocurrio un error';

    if (responseData['status']) {
      hasError = false;
      message = 'Login Exitoso';
      _authenticatedUser = User(
        idUser: responseData['response']['id_user'],
        firstName: responseData['response']['first_name'],
        lastName: responseData['response']['last_name'],
        email: responseData['response']['email'],
        phone: responseData['response']['mobile_num'].toString(),
        token: responseData['response']['token'],
        idDevice: idDevice,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('idUser', responseData['response']['id_user']);
      prefs.setString('firstName', responseData['response']['first_name']);
      prefs.setString('lastName', responseData['response']['last_name']);
      prefs.setString('email', responseData['response']['email']);
      prefs.setString(
          'mobileNum', responseData['response']['mobile_num'].toString());
      prefs.setString('token', responseData['response']['token']);
      prefs.setString('idDevice', idDevice);
    } else {
      message = responseData['message'];
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  ///
  ///register
  ///@version 1.6.5
  ///Login del app
  ///
  Future<Map<String, dynamic>> register(String name, String email, String phone,
      String password, String osDevice, String idDevice) async {
    http.Response _response;
    Map<String, dynamic> responseData = new Map<String, dynamic>();
    try {
      _response = await http.post(config.apiUrl + '/users/register', body: {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        'os_device': osDevice,
        'id_device': idDevice
      });

      responseData = json.decode(_response.body);
    } catch (err) {
      print("Error en login" + err.toString());
      return {
        'success': false,
        'message': "No tienes conexión con el servidor"
      };
    }
    if (responseData.isEmpty) {
      return {'success': false, 'message': "No hay información disponible"};
    }
    print(_response.body);

    bool success = false;
    String message = 'Ocurrio un error';

    if (responseData['status']) {
      success = true;
      message = "Registro exitoso, te mandamos un email con tu información";
    } else {
      success = false;
      message = responseData['message'];
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> updateUser(String password) async {
    _isLoading = false;
    final http.Response response = await http.post(
        config.apiUrl + '/users/update',
        body: {"password": password, "token": _authenticatedUser.token});
    final Map<String, dynamic> responseData = json.decode(response.body);

    bool hasError = true;
    String message = 'Ocurrio un error';

    if (responseData['status']) {
      hasError = false;
      message = 'Login Exitoso';
      _authenticatedUser = User(
        idUser: int.parse(responseData['response']['id_user']),
        firstName: responseData['response']['first_name'],
        lastName: responseData['response']['last_name'],
        email: responseData['response']['email'],
        phone: responseData['response']['mobile_num'],
        token: responseData['response']['token'],
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('idUser', int.parse(responseData['response']['id_user']));
      prefs.setString('firstName', responseData['response']['first_name']);
      prefs.setString('lastName', responseData['response']['last_name']);
      prefs.setString('email', responseData['response']['email']);
      prefs.setString('mobileNum', responseData['response']['mobile_num']);
      prefs.setString('token', responseData['response']['token']);
    } else {
      message = responseData['message'];
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  /**
   * autoAuthenticate
   * @version 0.9.5
   * Revisa la autenticacion y el token de acceso
   * TODO: Renovar el token cada 24 hrs
   */
  Future<bool> autoAuthenticate() async {
    _isLoading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String idDevice = prefs.getString('idDevice');
    final int idUser = prefs.getInt('idUser');
    final String firstName = prefs.getString('firstName');
    final String lastName = prefs.getString('lastName');
    final String userEmail = prefs.getString('email');
    final String mobileNum = prefs.getString('mobileNum');
    bool _success = true;
    if (token != null && idDevice != null) {
      _authenticatedUser = User(
          idUser: idUser,
          firstName: firstName,
          lastName: lastName,
          email: userEmail,
          phone: mobileNum,
          token: token,
          idDevice: idDevice);
    } else {
      _authenticatedUser = null;
      _success = false;
    }
    _isLoading = false;
    notifyListeners();
    return _success;
  }

  ///
  /// checkToken
  /// @version 1.8
  /// Verificara el token del usuario y lo renueva si es necesario
  /// TODO: Verificar token de acceso en api y app
  ///
  void checkToken() async {
    _isLoading = true;
    notifyListeners();
    http.Response _response;
    try {
      _response = await http.post(config.apiUrl + '/alerts', body: {
        "device": _deviceInfo.vendorKey,
        'code_panic': 2.toString(), //Hearbeat
        'lat': (_userCurrentLocation == null)
            ? 0.0.toString()
            : _userCurrentLocation.latitude.toString(),
        'lng': (_userCurrentLocation == null)
            ? 0.0.toString()
            : _userCurrentLocation.longitude.toString(),
      });
      print("CheckToken -> " + _response.body);
    } catch (err) {
      print("checkToken -> No hay conexión con el servidor ${err}");
      return;
    }

    final Map<String, dynamic> responseData = json.decode(_response.body);

    if (responseData['status'] == true) {
      //TODO: Renovar el token cada inicio del app
      _activeAlert = responseData['response']['activeAlert'];
    }
    _isLoading = false;
    notifyListeners();
  }

  ///
  /// track
  /// @version 0.1.1
  /// Verificara el token del usuario y lo renueva si es necesario
  /// TODO: Verificar token de acceso en api y app
  ///
  void track() async {
    http.Response _response;
    try {
      _response = await http.post(config.apiUrl + '/alerts_app/track', body: {
        "device": _authenticatedUser.idDevice,
        "token": _authenticatedUser.token,
        'lat': (_userCurrentLocation == null)
            ? 0.0.toString()
            : _userCurrentLocation.latitude.toString(),
        'lng': (_userCurrentLocation == null)
            ? 0.0.toString()
            : _userCurrentLocation.longitude.toString(),
      });
    } catch (err) {
      print("checkToken -> No hay conexión con el servidor");
    }

    final Map<String, dynamic> responseData = json.decode(_response.body);

    print(responseData["message"]);

    _isLoading = false;
    notifyListeners();
  }
}

class UtilityModel extends ConnectedPalsModel {
  bool get isLoading {
    return _isLoading;
  }
}
