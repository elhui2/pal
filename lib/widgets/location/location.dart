/*
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;

import '../helpers/ensure_visible.dart';
import '../../models/location_data.dart';
import '../../scoped-models/main.dart';
import '../../config.dart';

class LocationInput extends StatefulWidget {
  final MainModel model;
  final _LocationInputState state = _LocationInputState();

  LocationInput(this.model);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  void updateLocation() async {
    final address = await state._getAddress(model.currentLocation.latitude,
        model.currentLocation.longitude);

    state._getStaticMap(address,
        geocode: false,
        lat: model.currentLocation.latitude,
        lng: model.currentLocation.longitude);
  }
}

class _LocationInputState extends State<LocationInput> {
  final Config config = Config();

  Uri _staticMapUri;
  LocationData _locationData;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _getStaticMap("Mexico cdmx", geocode: true);
    super.initState();
  }
  


  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  @override
  void setState(fn) {
    //print("Cambiar el mapa ${widget.model.currentLocation.latitude}");
    super.setState(fn);
  }

  void _getStaticMap(String address,
      {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      print("La direccion esta vacia");
      setState(() {
        _staticMapUri = null;
      });
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {'address': address, 'key': config.gApiKey},
      );
      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coords = decodedResponse['results'][0]['geometry']['location'];
      _locationData = LocationData(
          address: formattedAddress,
          latitude: coords['lat'],
          longitude: coords['lng']);
    } else if (lat == null && lng == null) {
      print("No hay posicion actual");
      _locationData =
          LocationData(address: address, latitude: lat, longitude: lng);
    } else {
      print("Posicion actual $lat,$lng  -> $mounted");
      _locationData =
          LocationData(address: address, latitude: lat, longitude: lng);
    }
    if (mounted) {
      final StaticMapProvider staticMapViewProvider =
          StaticMapProvider(config.gApiKey);
      final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', _locationData.latitude,
            _locationData.longitude)
      ],
          center: Location(_locationData.latitude, _locationData.longitude),
          width: 500,
          height: 320,
          maptype: StaticMapViewType.roadmap);

      setState(() {
        _addressInputController.text = _locationData.address;
        _staticMapUri = staticMapUri;
      });
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '${lat.toString()},${lng.toString()}',
        'key': config.gApiKey,
      },
    );
    final http.Response response = await http.get(uri);
    //print(response.body);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString()),
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found.';
              }
            },
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
      ],
    );
  }
}
*/
