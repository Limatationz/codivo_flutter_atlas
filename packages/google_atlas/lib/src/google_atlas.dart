import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:atlas/atlas.dart';
import 'package:collection/collection.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:custom_marker/marker_icon.dart' as CustomMarkerIcon;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_atlas/google_atlas.dart';
import 'package:google_atlas/src/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMaps;
import 'package:rxdart/rxdart.dart';

const clusterIconSize = 120;
final clusterIconColor = Colors.red;
const centerMarkerAnimationDuration = 750;

/// `Atlas` Provider for Google Maps
class GoogleAtlas extends Provider {
  @override
  Set<MapType> get supportedMapTypes =>
      {
        MapType.normal,
        MapType.satellite,
        MapType.hybrid,
        MapType.terrain,
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
    return GoogleMapsProvider(
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

  /// This method enables/disables the decoding of an asset image
  /// into a byte array. Only for testing purposes.
  @visibleForTesting
  static void setGetBytesFromAssetEnabled(bool enabled) {
    _getBytesFromAssetEnabled = enabled;
  }
}

class GoogleMapsProvider extends StatefulWidget {
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

  GoogleMapsProvider({
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

  State<GoogleMapsProvider> createState() => _GoogleMapsProviderState();
}

bool _getBytesFromAssetEnabled = true;

class _GoogleMapsProviderState extends State<GoogleMapsProvider>
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

  Completer<GoogleMaps.GoogleMapController> _controller = Completer();

  GoogleMaps.CameraPosition? _lastMapPosition;

  BehaviorSubject<CameraStatus>? _cameraStatusStream;

  /// custom info windows
  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  Marker? _popupMarker;

  @override
  void initState() {
    _popupMarker =
        markers.firstWhereOrNull((element) => element.showPopupWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<GoogleMaps.Marker>>(
        future: _toGoogleMarkers(markers),
        initialData: Set<GoogleMaps.Marker>(),
        builder: (context, snapshot) {
          return Stack(children: [
            GoogleMaps.GoogleMap(
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false, // set to true in debug mode
              myLocationEnabled: showMyLocation,
              myLocationButtonEnabled: showMyLocationButton,
              mapType: _toGoogleMapType(mapType),
              trafficEnabled: showTraffic,
              initialCameraPosition:
              CameraUtils.toGoogleCameraPosition(initialCameraPosition),
              markers: snapshot.hasError
                  ? Set<GoogleMaps.Marker>()
                  : snapshot.data ?? Set<GoogleMaps.Marker>(),
              onTap: _toGoogleOnTap(onTap ?? (LatLng) {}),
              onLongPress: _toGoogleOnLongPress(onLongPress ?? (LatLng) {}),
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 500,
              width: 400,
              offset: (markers.firstOrNull?.icon?.iconWidget?.size ?? 35) +
                  (Theme
                      .of(context)
                      .platform == TargetPlatform.iOS ? 25 : 10),
            )
          ]);
        });
  }

  /// Converts an `Atlas.Marker` to a `GoogleMaps.Marker`
  Future<Set<GoogleMaps.Marker>> _toGoogleMarkers(Set<Marker> markers) async {
    /// show popup widget at start
    if (_popupMarker != null && (markers.isNotEmpty)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          _customInfoWindowController.addInfoWindow!(
              Container(
                alignment: Alignment.bottomCenter,
                child: _popupMarker!.popupWidget!,
              ),
              GoogleMaps.LatLng(
                _popupMarker!.position.latitude,
                _popupMarker!.position.longitude,
              )); // Prints after 1 second.
        }
        catch (e) {
          debugPrint("google atlas error: _customInfoWindowController.addInfoWindow (${e.toString()})");
        }
      });
    }

    // convert markers
    Set<GoogleMaps.Marker> googleMarkers = Set();

    for (Marker marker in markers) {
      googleMarkers.add(
        GoogleMaps.Marker(
          markerId: GoogleMaps.MarkerId(marker.id),
          consumeTapEvents: !marker.isCluster,
          position: GoogleMaps.LatLng(
            marker.position.latitude,
            marker.position.longitude,
          ),
          onTap: () {
            _onTapMarker(marker);
          },
          icon: marker.isCluster
              ? await _getClusterBitmap(clusterIconSize,
              text: marker.pointsSize!.toString())
              : await _getIconOfMarker(marker.icon),
          anchor: marker.isCluster ? Offset(0.5, 0.5) : Offset(0.5, 1.0),
        ),
      );
    }

    return googleMarkers;
  }

  /// If the markerIcon is null, return the default marker. Otherwise, if the
  /// assetName is not null, return the bitmap descriptor from the asset name.
  /// Otherwise, if the assetBytes is not null, return the bitmap descriptor from
  /// the asset bytes. Otherwise, if the iconWidget is not null, return the bitmap
  /// descriptor from the icon widget. Otherwise, return the default marker
  ///
  /// Args:
  ///   markerIcon (MarkerIcon): This is the icon that will be used for the marker.
  ///
  /// Returns:
  ///   A Future<GoogleMaps.BitmapDescriptor>
  Future<GoogleMaps.BitmapDescriptor> _getIconOfMarker(
      MarkerIcon? markerIcon) async {
    if (markerIcon == null ||
        (markerIcon.assetName == null &&
            markerIcon.assetBytes == null &&
            markerIcon.iconWidget == null)) {
      return GoogleMaps.BitmapDescriptor.defaultMarker;
    } else {
      if (markerIcon.assetName != null) {
        return await _toBitmapDescriptorFromAssetName(markerIcon);
      } else if (markerIcon.assetBytes != null) {
        return await _toBitmapDescriptorFromBytes(markerIcon);
      } else if (markerIcon.iconWidget != null) {
        return await _toBitmapDescriptorFromIconWidget(markerIcon);
      } else {
        return GoogleMaps.BitmapDescriptor.defaultMarker;
      }
    }
  }

  /// Converts an `Atlas.MapIcon` to an `GoogleMaps.BitmapDescriptor` with `Atlas.MapIcon.assetName
  Future<GoogleMaps.BitmapDescriptor> _toBitmapDescriptorFromAssetName(
      MarkerIcon markerIcon,) async {
    GoogleMaps.BitmapDescriptor? bitmapDescriptor;
    try {
      bitmapDescriptor = GoogleMaps.BitmapDescriptor.fromBytes(
        await _getBytesFromAsset(
          markerIcon.assetName!,
          _getIconWidth(markerIcon.width),
        ),
      );
    } catch (_) {}
    return bitmapDescriptor ?? GoogleMaps.BitmapDescriptor.defaultMarker;
  }

  /// Converts an `Atlas.MapIcon` to an `GoogleMaps.BitmapDescriptor` with `Atlas.MapIcon.assetBytes`
  Future<GoogleMaps.BitmapDescriptor> _toBitmapDescriptorFromBytes(
      MarkerIcon markerIcon,) async {
    GoogleMaps.BitmapDescriptor? bitmapDescriptor;
    try {
      bitmapDescriptor =
          GoogleMaps.BitmapDescriptor.fromBytes(markerIcon.assetBytes!);
    } catch (_) {}
    return bitmapDescriptor ?? GoogleMaps.BitmapDescriptor.defaultMarker;
  }

  /// Converts an `Atlas.MapIcon` to an `GoogleMaps.BitmapDescriptor` with `Atlas.MapIcon.iconWidget'
  Future<GoogleMaps.BitmapDescriptor> _toBitmapDescriptorFromIconWidget(
      MarkerIcon markerIcon,) async {
    return await CustomMarkerIcon.MarkerIcon.markerFromIcon(
        markerIcon.iconWidget!.icon!,
        markerIcon.iconWidget!.color!,
        markerIcon.iconWidget!.size! * 3);
  }

  /// Returns the icon width in pixels according the device screen.
  int _getIconWidth(int width) {
    return (width > 0)
        ? (width * ui.window.devicePixelRatio).round()
        : _getDefaultIconWidth();
  }

  /// Returns the default icon width in pixels according the device screen.
  int _getDefaultIconWidth() {
    final dpr = ui.window.devicePixelRatio;
    final size = dpr * 80;
    return size.round();
  }

  /// Reads the [asset] file and returns an `Uint8List` byte array.
  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    if (_getBytesFromAssetEnabled) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: width,
      );
      final fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
    } else {
      return Uint8List(0);
    }
  }

  /// Converts a `GoogleMaps.onTap` to an `Atlas.onTap` callback.
  void Function(GoogleMaps.LatLng) _toGoogleOnTap(
      ArgumentCallback<LatLng> onTap,) {
    return (GoogleMaps.LatLng position) {
      // custom info window
      _customInfoWindowController.hideInfoWindow!();
      onTap.call(LatLngUtils.fromGoogleLatLng(position));
    };
  }

  /// Converts a `GoogleMaps.onLongPress` to an `Atlas.onLongPress` callback.
  void Function(GoogleMaps.LatLng) _toGoogleOnLongPress(
      ArgumentCallback<LatLng> onLongPress,) {
    return (GoogleMaps.LatLng position) {
      onLongPress.call(LatLngUtils.fromGoogleLatLng(position));
    };
  }

  /// Converts an `Atlas.MapType` enum to a `GoogleMaps.MapType` enum.
  GoogleMaps.MapType _toGoogleMapType(MapType atlasMapType) {
    switch (atlasMapType) {
      case MapType.normal:
        return GoogleMaps.MapType.normal;
      case MapType.satellite:
        return GoogleMaps.MapType.satellite;
      case MapType.hybrid:
        return GoogleMaps.MapType.hybrid;
      case MapType.terrain:
        return GoogleMaps.MapType.terrain;
      default:
        return GoogleMaps.MapType.normal;
    }
  }

  /// Callback method where GoogleMaps passes the map controller
  void _onMapCreated(GoogleMaps.GoogleMapController controller) async {
    // custom info window
    _customInfoWindowController.googleMapController = controller;

    _controller.complete(controller);
    _lastMapPosition =
        CameraUtils.toGoogleCameraPosition(widget.initialCameraPosition);

    final atlasController = GoogleAtlasController(controller: controller);
    _cameraStatusStream = atlasController.cameraStatusStream;

    onMapCreated?.call(atlasController);
  }

  /// Callback method when camera moves
  void _onCameraMove(GoogleMaps.CameraPosition cameraPosition) {
    // custom info window
    _customInfoWindowController.onCameraMove!();

    _cameraStatusStream?.add(CameraStatus.moving);
    _lastMapPosition = cameraPosition;
    onCameraPositionChanged?.call(
      CameraUtils.toAtlasCameraPosition(cameraPosition),
    );
  }

  /// Callback method when camera is idle
  void _onCameraIdle() {
    _cameraStatusStream?.add(CameraStatus.idle);
  }

  /// It takes a size and a text, draws a circle with three different colors, and
  /// then draws the text in the middle of the circle
  ///
  /// Args:
  ///   size (int): The size of the cluster icon.
  ///   text (String): The text to be displayed on the cluster icon.
  ///
  /// Returns:
  ///   A Future<GoogleMaps.BitmapDescriptor>
  Future<GoogleMaps.BitmapDescriptor> _getClusterBitmap(int size,
      {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()
      ..color = clusterIconColor;
    final Paint paint2 = Paint()
      ..color = clusterIconColor.withOpacity(0.7);
    final Paint paint3 = Paint()
      ..color = clusterIconColor.withOpacity(0.4);

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint3);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0 - 12, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0 - 24, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return GoogleMaps.BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  /// _onTapMarker() is called when a marker is tapped. If the marker is a cluster,
  /// the camera zooms in on the cluster. If the marker is not a cluster, the camera
  /// zooms in on the marker and the marker's onTap() function is called
  ///
  /// Args:
  ///   marker (Marker): The marker that was tapped.
  _onTapMarker(Marker marker) async {
    final GoogleMaps.GoogleMapController controller = await _controller.future;
    _animatedMapMove(
        controller,
        LatLngUtils.toGoogleLatLng(marker.position),
        marker.isCluster ? _lastMapPosition!.zoom + 2 : _lastMapPosition!.zoom,
        marker,
        marker.isCluster);
  }

  void _animatedMapMove(GoogleMaps.GoogleMapController controller,
      GoogleMaps.LatLng destLocation,
      double destZoom,
      Marker marker,
      bool isCLuster) async {
    // custom info window
    _customInfoWindowController.hideInfoWindow!();
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _lastMapPosition!.target.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _lastMapPosition!.target.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(
        begin: _lastMapPosition!.zoom,
        end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    AnimationController _animController = AnimationController(
        duration: const Duration(milliseconds: centerMarkerAnimationDuration),
        vsync: this);

    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
    CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn);

    _animController.addListener(() {
      controller.moveCamera(GoogleMaps.CameraUpdate.newCameraPosition(
          GoogleMaps.CameraPosition(
              target: GoogleMaps.LatLng(
                  latTween.evaluate(animation), lngTween.evaluate(animation)),
              zoom: zoomTween.evaluate(animation))));
    });

    // start animation and call onTap if it's completed
    _animController.forward().whenComplete(() {
      marker.onTap?.call();
      _lastMapPosition =
          GoogleMaps.CameraPosition(target: destLocation, zoom: destZoom);
      // custom info window
      if (marker.popupWidget != null) {
        _customInfoWindowController.addInfoWindow!(
            Container(
              alignment: Alignment.bottomCenter,
              child: marker.popupWidget!,
            ),
            GoogleMaps.LatLng(
              marker.position.latitude,
              marker.position.longitude,
            ));
      }
    });
  }

  @override
  void dispose() {
    // custom info window
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
