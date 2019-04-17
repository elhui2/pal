import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/location_data.dart';

/**
 * Gmap
 * @version 0.7
 * Mapa de google nativo
 */
class Gmap extends StatefulWidget {
  final _GmapState state = _GmapState();

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  void userLocation(LocationData currentLocation) async {
    if (state.mounted && currentLocation != null) {
      state.userLocation(currentLocation);
    }
  }
}

class _GmapState extends State<Gmap> {
  GoogleMapController mapController;

  LatLng currentPosition;
  Marker currentMarker;
  final Set<Marker> _markers = {};

  @override
  void setState(fn) {
    super.setState(fn);
  }

  static CameraPosition mainCamara =
      new CameraPosition(target: LatLng(23.6345005, -102.5527878), zoom: 6.0);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: mainCamara,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      markers: _markers
    );
  }

  void userLocation(LocationData location) {
    if (location != null && mapController!=null) {
      print("Chambiando en esto ${location.latitude} & ${location.latitude}");
      currentPosition = new LatLng(location.latitude, location.longitude);
      setState(() {
        currentMarker = new Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId("current_position"),
          position: currentPosition,
          infoWindow: InfoWindow(
            title: 'Nuestra Ubicacion',
            snippet: 'Se actualiza automaticamente',
          ),
          icon: BitmapDescriptor.defaultMarker,
        );
        _markers.add(currentMarker);
      });

      centerMap(currentPosition);
    }
  }

  void centerMap(LatLng position) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: position,
        zoom: 17.0,
      ),
    ));
  }
}
