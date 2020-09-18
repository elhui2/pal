import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as geoloc;

import '../../scoped-models/main.dart';

///
/// Gmap
/// @version 1.8
/// @author Daniel Huidobro daniel@rebootproject.mx
/// Mapa de google nativo
///
class Gmap extends StatefulWidget {
  final MainModel model;
  final _GmapState state = _GmapState();

  Gmap(this.model);

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class _GmapState extends State<Gmap> {
  final location = geoloc.Location();
  GoogleMapController mapController;

  LatLng currentPosition = new LatLng(19.432778, -99.133222);
  Set<Marker> _markers = new Set<Marker>();

  @override
  void initState() {
    super.initState();
    print("Gmap initState");
    location.hasPermission().then((permisions) {
      if (permisions == false) {
        location.requestPermission().then((request) {
          if (request == true) {
            // location.onLocationChanged().listen((currentLocation) {
            //   // print(
            //   //     "Init onLocationChanged ${currentLocation.latitude},${currentLocation.longitude}");
            //   widget.model.setCurrentLocation(
            //       currentLocation.latitude, currentLocation.longitude);
            //   currentPosition = new LatLng(
            //       currentLocation.latitude, currentLocation.longitude);
            //   centerMarker(currentPosition);
            // });
          }
        });
      } else {
        // location.onLocationChanged().listen((currentLocation) {
        //   print(
        //       "Init onLocationChanged ${currentLocation.latitude},${currentLocation.longitude}");
        //   widget.model.setCurrentLocation(
        //       currentLocation.latitude, currentLocation.longitude);
        //   currentPosition =
        //       new LatLng(currentLocation.latitude, currentLocation.longitude);
        //   centerMarker(currentPosition);
        // });
      }
    });
  }

  @override
  void setState(fn) {
    super.setState(fn);
    print("Gmap setState");
  }

  // @override
  // void deactivate() {
  //   super.deactivate();
  // }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
              new CameraPosition(target: currentPosition, zoom: 14.0),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          markers: _markers,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
        );
      },
    );
  }

  void centerMarker(LatLng currentPosition) async {
    _markers = new Set<Marker>();
    Marker currentMarker = new Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId("currentPosition"),
      position: currentPosition,
      infoWindow: InfoWindow(
        title: 'Nuestra Ubicacion',
        snippet: 'Se actualiza automaticamente',
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.add(currentMarker);

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: currentPosition,
          zoom: 15.0,
        ),
      ));
    }
  }
}
