import 'package:atlas/atlas.dart';
import 'package:flutter/material.dart';

class ClusteredMap extends StatefulWidget {
  const ClusteredMap({Key? key}) : super(key: key);

  @override
  State<ClusteredMap> createState() => _ClusteredMapState();
}

class _ClusteredMapState extends State<ClusteredMap>{
  final providerSupportsSatellite =
      AtlasProvider.instance!.supportedMapTypes!.length > 1;
  var _mapType = MapType.normal;

  var _currentCameraPosition = const CameraPosition(
    target: LatLng(
      latitude: 49.954008,
      longitude: 11.587917,
    ),
    zoom: 7,
  );

  /// The AtlasController for the small map.
  late AtlasController _controllerSmall;

  /// The AtlasController for the large map.
  late AtlasController _controllerLarge;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Atlas(
        initialCameraPosition: _currentCameraPosition,
        markers: testMarkers,
        mapType: _mapType,
        onCameraPositionChanged: (newCameraPosition) => {
            _currentCameraPosition = newCameraPosition,
          providerSupportsSatellite ? _controllerSmall.moveCamera(_currentCameraPosition) : null,
        },
        onMapCreated: (controller) {
          _controllerLarge = controller;
        },
        //clusterMarkers: true,
      ),
      providerSupportsSatellite ? Positioned(
          bottom: 18,
          left: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _mapType = _mapType == MapType.normal
                    ? MapType.hybrid
                    : MapType.normal;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Stack(children: [
                AbsorbPointer(
                    absorbing: true,
                    child: SizedBox(
                      width: 75,
                      height: 75,
                      child: Atlas(
                        initialCameraPosition: _currentCameraPosition,
                        mapType: _mapType == MapType.normal
                            ? MapType.satellite
                            : MapType.normal,
                        onMapCreated: (controller) {
                          _controllerSmall = controller;
                        },
                      ),
                    )),
                Container(
                  width: 75,
                  height: 75,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _mapType == MapType.normal
                            ? Icons.satellite
                            : Icons.map,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _mapType == MapType.normal ? 'Satellite' : 'Normal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          )) : Container(),
      Positioned(
        top: 18,
        right: 12,
        child: IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: () async {
            _controllerLarge.moveCamera(
                const CameraPosition(
                  target: LatLng(
                    latitude: 49.954008,
                    longitude: 11.587917,
                  ),
                  zoom: 7,
                ));
          },
        ),
      ),
    ]);
  }
}

final Set<Marker> testMarkers = <Marker>{
  Marker(
      id: 'marker-1',
      position: const LatLng(
        latitude: 49.954781,
        longitude: 11.587144,
      ),
      onTap: () {
        print('tapped marker-1');
      },
      icon: const MarkerIcon(assetName: "res/car.png", width: 40, height: 40)),
  Marker(
    id: 'marker-2',
    position: const LatLng(
      latitude: 49.939151,
      longitude: 11.624051,
    ),
    onTap: () {
      print('tapped marker-2');
    },
  ),
  Marker(
    id: 'marker-3',
    position: const LatLng(
      latitude: 49.934111,
      longitude: 11.599209,
    ),
    onTap: () {
      print('tapped marker-3');
    },
  ),
  Marker(
    id: 'marker-4',
    position: const LatLng(
      latitude: 49.929203,
      longitude: 11.585652,
    ),
    onTap: () {
      print('tapped marker-4');
    },
    popupWidget: const Text('This is a popup widget'),
  ),
  Marker(
    id: 'marker-5',
    position: const LatLng(
      latitude: 50.302858,
      longitude: 11.930570,
    ),
    onTap: () {
      print('tapped marker-5');
    },
    popupWidget: const Text('This is a popup widget'),
  ),
  Marker(
    id: 'marker-6',
    position: const LatLng(
      latitude: 50.308131,
      longitude: 11.894853,
    ),
    onTap: () {
      print('tapped marker-6');
    },
    popupWidget: const Text('This is a popup widget'),
  ),
  Marker(
    id: 'marker-7',
    position: const LatLng(
      latitude: 50.318420,
      longitude: 11.937040,
    ),
    onTap: () {
      print('tapped marker-7');
    },
    popupWidget: const Text('This is a popup widget'),
  ),
  Marker(
    id: 'marker-8',
    position: const LatLng(
      latitude: 51.318420,
      longitude: 11.937040,
    ),
    onTap: () {
      print('tapped marker-8');
    },
    isCluster: true,
    pointsSize: 8,
    clusterId: 3,
  )
};

