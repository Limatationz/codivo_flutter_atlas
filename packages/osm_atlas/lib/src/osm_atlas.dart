import 'dart:async';

import 'package:atlas/atlas.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as OSM;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart' as OSMLATLNG;
import 'package:osm_atlas/osm_atlas.dart';
import 'package:osm_atlas/src/utils/camera_utils.dart';
import 'package:osm_atlas/src/utils/lat_lng_utils.dart';

import 'utils/cache/map_tile_cache_provider_memory.dart';

const clusterIconSize = 120;
final clusterIconColor = Colors.blue.shade700;
const centerMarkerAnimationDuration = 750;

/// `Atlas` Provider for Open Street Map
class OSMAtlas extends Provider {
  /// set supported maps
  @override
  Set<MapType> get supportedMapTypes => {
        MapType.normal,
      };

  @override
  Widget build({
    CameraPosition? initialCameraPosition,
    Set<Marker>? markers,
    Set<Circle>? circles,
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Callout>? callouts,
    ArgumentCallback<LatLng>? onTap,
    ArgumentCallback<Poi>? onPoiTap,
    ArgumentCallback<LatLng>? onLongPress,
    ArgumentCallback<AtlasController>? onMapCreated,
    ArgumentCallback<CameraPosition>? onCameraPositionChanged,
    ArgumentCallback<LatLng>? onLocationChanged,
    VoidCallback? onPan,
    bool? showMyLocation,
    bool? showMyLocationButton,
    bool? followMyLocation,
    MapType? mapType,
    bool? showTraffic,
    MapLanguage? mapLanguage,
    DeviceLocation? deviceLocation,
    String? deviceLocationIconAsset,
    String? country,
    Set<Cluster>? clusters,
  }) {
    return OSMProvider(
      initialCameraPosition: initialCameraPosition!,
      onTap: onTap,
      onLongPress: onLongPress,
      markers: markers!,
      polygons: polygons!,
      polylines: polylines,
      circles: circles,
      callouts: callouts,
      showMyLocation: showMyLocation!,
      showMyLocationButton: showMyLocationButton!,
      onCameraPositionChanged: onCameraPositionChanged,
      onMapCreated: onMapCreated,
      mapType: mapType!,
      showTraffic: showTraffic!,
      mapLanguage: mapLanguage,
      onPan: onPan,
      deviceLocation: deviceLocation,
      deviceLocationIconAsset: deviceLocationIconAsset,
      country: country,
    );
  }
}

class OSMProvider extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final ArgumentCallback<LatLng>? onTap;
  final ArgumentCallback<Poi>? onPoiTap;
  final ArgumentCallback<LatLng>? onLongPress;
  final ArgumentCallback<CameraPosition>? onCameraPositionChanged;
  final VoidCallback? onPan;
  final Set<Marker> markers;
  final Set<Polyline>? polylines;
  final Set<Polygon> polygons;
  final Set<Circle>? circles;
  final Set<Callout>? callouts;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final MapType mapType;
  final bool showTraffic;
  final MapLanguage? mapLanguage;
  final DeviceLocation? deviceLocation;
  final String? deviceLocationIconAsset;
  final String? country;

  final ArgumentCallback<AtlasController>? onMapCreated;

  OSMProvider({
    required this.initialCameraPosition,
    required this.markers,
    required this.polygons,
    required this.showMyLocation,
    required this.showMyLocationButton,
    required this.mapType,
    required this.showTraffic,
    this.circles,
    this.polylines,
    this.callouts,
    this.onCameraPositionChanged,
    this.onMapCreated,
    this.onLongPress,
    this.onPoiTap,
    this.onTap,
    this.onPan,
    this.mapLanguage,
    this.deviceLocation,
    this.deviceLocationIconAsset,
    this.country,
  });

  State<OSMProvider> createState() => _OSMProviderState();
}

class _OSMProviderState extends State<OSMProvider>
    with TickerProviderStateMixin {
  CameraPosition get initialCameraPosition => widget.initialCameraPosition;

  ArgumentCallback<LatLng>? get onTap => widget.onTap;

  ArgumentCallback<AtlasController>? get onMapCreated => widget.onMapCreated;

  ArgumentCallback<LatLng>? get onLongPress => widget.onLongPress;

  ArgumentCallback<CameraPosition>? get onCameraPositionChanged =>
      widget.onCameraPositionChanged;

  Set<Marker> get markers => widget.markers;

  bool get showMyLocation => widget.showMyLocation;

  bool get showMyLocationButton => widget.showMyLocationButton;

  MapType get mapType => widget.mapType;

  bool get showTraffic => widget.showTraffic;

  /// map controller
  OSM.MapController _controller = OSM.MapController();

  /// Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();
  Marker? _popupMarker;

  @override
  void initState() {
    _popupMarker =
        markers.firstWhereOrNull((element) => element.showPopupWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OSM.Marker>>(
        future: _toOSMMarkers(markers),
        builder: (context, snapshot) {
          return OSM.FlutterMap(
            mapController: _controller,
            options: OSM.MapOptions(
              center: LatLngUtils.toOSMLatLng(initialCameraPosition.target),
              zoom: initialCameraPosition.zoom,
              onTap: (_, position) => _onTap(position),
              onLongPress: (_, position) => _onLongPress(position),
              onMapCreated: _onMapCreated,
              maxZoom: 19.0,
              minZoom: 2.0,
              onPositionChanged: (position, hasGesture) =>
                  _onPositionChanged(position),
            ),
            children: [
              OSM.TileLayerWidget(
                options: OSM.TileLayerOptions(
                  // urlTemplate: "https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  tileProvider: MapTileCacheProviderMemory(),
                ),
              ),
              if (showMyLocation) LocationMarkerLayerWidget(),
              PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                popupController: _popupLayerController,
                markers: snapshot.hasData ? snapshot.data! : [],
                markerTapBehavior: MarkerTapBehavior.custom(
                    (marker, popupState, popupController) {
                  popupController.togglePopup(marker);
                  _onMarkerTap(marker);
                }),
                popupBuilder: (context, OSM.Marker marker) {
                  return markers
                          .firstWhereOrNull((element) =>
                              Key(element.id) == marker.key &&
                              !element.isCluster)
                          ?.popupWidget ??
                      Container();
                },
              )),
            ],
          );
        });
  }

  /// Converts an `Atlas.Marker` to a `FlutterMap.Marker`
  Future<List<OSM.Marker>> _toOSMMarkers(Set<Marker> markers) async {
    List<OSM.Marker> osmMarkers = [];

    for (Marker marker in markers) {
      osmMarkers.add(OSM.Marker(
          key: Key(marker.id),
          point: LatLngUtils.toOSMLatLng(marker.position),
          builder: (context) => marker.isCluster
              ? _getClusteredWidget(marker, context)
              : _getIconOfMarker(marker.icon)));
    }

    /// show popup widget at start
    if (_popupMarker != null && (markers.isNotEmpty)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _popupLayerController.togglePopup(osmMarkers
            .firstWhere((element) => element.key == Key(_popupMarker!.id)));
      });
    }

    return osmMarkers;
  }

  /// If the markerIcon is null, return a default icon. If the markerIcon is not
  /// null, return the icon specified by the user
  ///
  /// Args:
  ///   markerIcon (MarkerIcon): This is the icon that will be displayed on the
  /// marker.
  ///
  /// Returns:
  ///   A widget.
  Widget _getIconOfMarker(MarkerIcon? markerIcon) {
    if (markerIcon == null ||
        (markerIcon.assetName == null &&
            markerIcon.assetBytes == null &&
            markerIcon.iconWidget == null)) {
      return Icon(
        Icons.location_on,
        color: Colors.red,
        size: 35,
      );
    } else {
      if (markerIcon.assetName != null) {
        return Image.asset(
          markerIcon.assetName!,
          height: markerIcon.height.toDouble(),
          width: markerIcon.width.toDouble(),
        );
      } else if (markerIcon.assetBytes != null) {
        return Image.memory(
          markerIcon.assetBytes!,
          height: markerIcon.height.toDouble(),
          width: markerIcon.width.toDouble(),
        );
      } else if (markerIcon.iconWidget != null) {
        return markerIcon.iconWidget!;
      } else {
        return Icon(
          Icons.location_on,
          color: Colors.red,
          size: 35,
        );
      }
    }
  }

  /// _onTap is a function that takes an OSMLATLNG.LatLng and calls onTap with a
  /// LatLngUtils.fromOSMLatLng(latLng) if onTap is not null
  ///
  /// Args:
  ///   latLng (OSMLATLNG): The latitude and longitude of the tapped location.
  void _onTap(OSMLATLNG.LatLng latLng) {
    _popupLayerController.hideAllPopups();
    onTap?.call(LatLngUtils.fromOSMLatLng(latLng));
  }

  /// A callback function that is called when the user long presses on the map.
  ///
  /// Args:
  ///   latLng (OSMLATLNG): The latitude and longitude of the point where the user
  /// pressed the map.
  void _onLongPress(OSMLATLNG.LatLng latLng) {
    onLongPress?.call(LatLngUtils.fromOSMLatLng(latLng));
  }

  /// When the map is created, we call the onMapCreated callback, and if there is a
  /// marker with showPopup set to true, we show the popup for that marker
  ///
  /// Args:
  ///   controller (OSM): The controller of the map.
  void _onMapCreated(OSM.MapController controller) {
    onMapCreated?.call(OSMAtlasController(controller: _controller));
  }

  /// When the map position changes, call the onCameraPositionChanged callback with
  /// the new camera position.
  ///
  /// Args:
  ///   position (OSM): The new position of the map.
  void _onPositionChanged(OSM.MapPosition position) {
    onCameraPositionChanged?.call(CameraUtils.toAtlasCameraPosition(
        position.center!, position.zoom!, _controller.rotation));
  }

  /// If the marker is a cluster, zoom in and center the map on the marker. If the
  /// marker is not a cluster, center the map on the marker
  ///
  /// Args:
  ///   marker (Marker): The marker that was tapped.
  void _onMarkerTap(OSM.Marker marker) {
    final atlasMarker =
        widget.markers.firstWhere((m) => Key(m.id) == marker.key);

    // center marker
    atlasMarker.isCluster
        ? _animatedMapMove(
            marker.point, _controller.zoom + 1, atlasMarker.onTap)
        : _animatedMapMove(marker.point, _controller.zoom, atlasMarker.onTap);
  }

  /// It creates an animation controller, adds a listener to it, and then starts the
  /// animation
  ///
  /// Args:
  ///   destLocation (OSMLATLNG): The destination location to move to.
  ///   destZoom (double): The zoom level you want to animate to.
  ///   onTap (void Function()?): This is a callback function that will be called
  /// when the animation is completed.
  void _animatedMapMove(
      OSMLATLNG.LatLng destLocation, double destZoom, void Function()? onTap) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _controller.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _controller.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _controller.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    AnimationController _animController = AnimationController(
        duration: const Duration(milliseconds: centerMarkerAnimationDuration),
        vsync: this);

    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn);

    _animController.addListener(() {
      _controller.move(
          OSMLATLNG.LatLng(
              latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    // start animation and call onTap if it's completed
    _animController.forward().whenComplete(() => {
          onTap?.call(),
        });
  }

  /// `_getClusteredWidget` is a function that returns a `Stack` widget with a
  /// `Container` widget as its child. The `Container` widget has a `Text` widget as
  /// its child. The `Text` widget displays the number of markers in the cluster
  ///
  /// Args:
  ///   text (String): The text to be displayed on the cluster icon.
  ///   context (BuildContext): The context of the map.
  Widget _getClusteredWidget(Marker marker, BuildContext context) => Container(
        // Size seems to be limited in marker builder
        width: clusterIconSize.toDouble(),
        height: clusterIconSize.toDouble(),
        child: Text(marker.pointsSize.toString(),
            style: TextStyle(color: Colors.white)),
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: clusterIconColor),
        alignment: Alignment.center,
      );
}
