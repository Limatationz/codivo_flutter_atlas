import 'package:atlas/atlas.dart';
import 'package:flutter/material.dart';

class SingleMarkerMap extends StatefulWidget {
  const SingleMarkerMap({Key? key}) : super(key: key);

  @override
  State<SingleMarkerMap> createState() => _SingleMarkerMapState();
}

class _SingleMarkerMapState extends State<SingleMarkerMap> {
  final _mapType =
      AtlasProvider.instance!.supportedMapTypes!.length > 1
          ? MapType.hybrid
          : MapType.normal;

  var _currentCameraPosition = CameraPosition(
    target: LatLng(
      latitude: testMarker.position.latitude,
      longitude: testMarker.position.longitude,
    ),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Atlas(
      initialCameraPosition: _currentCameraPosition,
      markers: {testMarker},
      mapType: _mapType,
      onCameraPositionChanged: (newCameraPosition) =>
          {_currentCameraPosition = newCameraPosition},
      interactionEnabled: true,
    );
  }
}

final Marker testMarker = Marker(
    id: 'marker-1',
    position: const LatLng(
      latitude: 49.954781,
      longitude: 11.587144,
    ),
    onTap: () {
      print('tapped marker-1');
    },
    popupWidget: const Text('This is a popup widget'),
    showPopupWidget: true,
    icon: const MarkerIcon(iconWidget: Icon(Icons.location_on_sharp, color: Colors.red, size: 35,)));
