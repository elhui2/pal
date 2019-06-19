import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/refer.dart';
import '../models/alert.dart';
import '../models/user.dart';
import '../models/location_data.dart';

/**
 * ConnectedPalsModel
 * @version 1.0
 * @author Daniel Huidobro <daniel@rebootproject.mx>
 * Modelo principal del app
 */
class ConnectedPalsModel extends Model {
  final Config config = new Config();
  List<Alert> _alerts = [];
  List<Refer> _refers = [];
  int _selReferIndex;
  User _authenticatedUser;
  LocationData _userCurrentLocation;
  bool _isLoading = false;
  bool _activeAlert = false;
}

class AlertsModel extends ConnectedPalsModel {
  /**
   * fetchAlerts
   * Listar referidos
   */
  Future<Null> fetchAlerts() {
    _isLoading = true;
    return http
        .get(config.apiUrl + '/users_alerts/get/${_authenticatedUser.idUser}')
        .then((http.Response response) {
      final Map<String, dynamic> alertListData = jsonDecode(response.body);
      if (alertListData['status'] == false) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final List<Alert> fetchAlertList = [];
      alertListData['response'].forEach((dynamic alertData) {
        final Alert alert = Alert(
          idAlert: int.parse(alertData['id_alert']),
          status: alertData['status'],
          registerDate: alertData['register_date'],
        );
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
  ///SendAlert
  ///@version 1.0
  ///Envia una alerta al servidor
  ///
  Future<Map<String, dynamic>> sendAlert(int type) async {
    _isLoading = true;
    notifyListeners();
    bool success = true;
    String message = 'Ocurrio un error';

    http.Response _response;
    Map<String, dynamic> responseData;

    try {

      _response = await http.post(config.apiUrl + '/alerts', body: {
        'device': _authenticatedUser.idDevice,
        'code_panic': type.toString(),
        'lat': _userCurrentLocation.latitude.toString(),
        'lng': _userCurrentLocation.longitude.toString()
      });

      responseData = json.decode(_response.body);

      if (responseData['status'] == true) {

        success = true;
        message = 'Se envió la alerta';

        if (type == 1) {
          _activeAlert = false;
        } else {
          _activeAlert = true;
        }

      } else {
        success = false;
        message = responseData['message'];
      }

    } catch (_ex) {

      print(_ex.toString());
      success = false;
      message = 'No tienes conexion con el servidor';

    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
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
      final Map<String, dynamic> referListData = jsonDecode(response.body);
      if (referListData['status'] == false) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final List<Refer> fetchReferList = [];
      referListData['response'].forEach((dynamic referData) {
        final Refer refer = Refer(
            idRefer: int.parse(referData['id_user_reference']),
            name: referData['name'],
            email: referData['email'],
            phone: referData['phone'],
            relationship: referData['relationship'],
            registerDate: referData['register_date']);
        fetchReferList.add(refer);
      });
      _refers = fetchReferList;
      _isLoading = false;
      notifyListeners();
    });
  }

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
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status']) {
        final Refer newRefer = Refer(
            idRefer: int.parse(responseData['response']['id_user_reference']),
            name: responseData['response']['name'],
            email: responseData['response']['email'],
            phone: responseData['response']['phone'],
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
            idRefer: int.parse(responseData['response']['id_user_reference']),
            name: responseData['response']['name'],
            email: responseData['response']['email'],
            phone: responseData['response']['phone'],
            relationship: responseData['response']['relationship'],
            registerDate: responseData['response']['register_date']);
        _refers[selectedReferIndex] = updatedRefer;
      } else {
        //TODO: Cachar errores
      }
      _isLoading = false;
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

/**
 * UserModel
 * @version 0.7
 * Modelo del usuario
 * TODO:Ver los warninds de todos los modelos
 */
class UserModel extends ConnectedPalsModel {
  void setCurrentLocation(double lat, double lng) {
    if (lat != null && lat > 0) {
      _userCurrentLocation = new LocationData(
          latitude: lat, longitude: lng, description: null, address: null);
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

    final Map<String, dynamic> responseData = json.decode(_response.body);

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
        idDevice: idDevice,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('idUser', int.parse(responseData['response']['id_user']));
      prefs.setString('firstName', responseData['response']['first_name']);
      prefs.setString('lastName', responseData['response']['last_name']);
      prefs.setString('email', responseData['response']['email']);
      prefs.setString('mobileNum', responseData['response']['mobile_num']);
      prefs.setString('token', responseData['response']['token']);
      prefs.setString('idDevice', idDevice);
    } else {
      message = responseData['message'];
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
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
  /// @version 0.9.5
  /// Verificara el token del usuario y lo renueva si es necesario
  /// TODO: Verificar token de acceso en api y app
  void checkToken() async {
    _isLoading = true;
    notifyListeners();
    final http.Response response =
        await http.post(config.apiUrl + '/alerts', body: {
      "device": _authenticatedUser.idDevice,
      "token": _authenticatedUser.token,
      'code_panic': 2.toString(), //Hearbeat
      'lat': (_userCurrentLocation == null)
          ? 0.0.toString()
          : _userCurrentLocation.latitude.toString(),
      'lng': (_userCurrentLocation == null)
          ? 0.0.toString()
          : _userCurrentLocation.longitude.toString(),
    });
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['status'] == true) {
      //TODO: Renovar el token cada 24 hrs
      _activeAlert = responseData['response']['activeAlert'];
    } else {
      _authenticatedUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}

class UtilityModel extends ConnectedPalsModel {
  bool get isLoading {
    return _isLoading;
  }
}
