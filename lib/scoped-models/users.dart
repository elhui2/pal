import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

///
/// UsersModel
/// @version 1.4
/// @author Daniel Huidobro <daniel@rebootproject.mx>
/// Modelo principal del app
///
class UsersModel extends Model {
  final Config config = new Config();

  bool _isLoading = false;

  ///
  /// SendAlert
  /// @version 1.4
  /// Envia una alerta al servidor
  ///
  Future<Map<String, dynamic>> forgot(String email) async {
    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';

    http.Response _response;
    Map<String, dynamic> responseData;

    try {
      _response = await http.post(config.apiUrl + '/users/forgot', body: {
        'email': email,
      });

      responseData = json.decode(_response.body);
    } catch (_ex) {
      print("Error en alerta ->" + _ex.toString());
      return {
        'success': false,
        'message':
            'No pudimos enviar la solicitud, revisa tu conexión a internet'
      };
    }

    if (responseData['status'] == true) {
      success = true;
      message = 'Se envió la alerta';
    } else {
      success = false;
      message = responseData['message'];
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }
}
