import 'dart:async';
import 'dart:typed_data';

import 'package:atlas/atlas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart' as OSM;
import 'package:osm_atlas/src/utils/camera_utils.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';
import 'package:latlong2/latlong.dart' as OSMLATLNG;

import 'utils/lat_lng_utils.dart';

/// It's a class that implements the AtlasController interface
class OSMAtlasController implements AtlasController {
  final OSM.MapController _controller;

  @override
  BehaviorSubject<CameraStatus> cameraStatusStream = BehaviorSubject.seeded(CameraStatus.idle);

  OSMAtlasController({required OSM.MapController controller})
      : _controller = controller {
    _controller.mapEventStream.listen((event) {
      if (event.source == OSM.MapEventSource.dragStart ||
          event.source == OSM.MapEventSource.onDrag ||
          event.source == OSM.MapEventSource.multiFingerGestureStart ||
          event.source == OSM.MapEventSource.onMultiFinger) {
        cameraStatusStream.add(CameraStatus.moving);
      } else {
        cameraStatusStream.add(CameraStatus.idle);
      }
    });
  }

  /// `_controller.move(LatLngUtils.toOSMLatLng(cameraPosition.target),
  /// cameraPosition.zoom);`
  ///
  /// The `_controller` is the `MapController` object that we created in the
  /// `initState` function. The `move` function takes two parameters: a `LatLng`
  /// object and a `double` value. The `LatLng` object is the target location of the
  /// camera. The `double` value is the zoom level of the camera
  ///
  /// Args:
  ///   cameraPosition (CameraPosition): The new camera position.
  ///   animation (MoveCameraAnimation): The animation to use when moving the
  /// camera.
  ///
  /// Returns:
  ///   Future.value()
  Future<void> moveCamera(CameraPosition cameraPosition,
      {MoveCameraAnimation? animation}) {
    _controller.move(
      LatLngUtils.toOSMLatLng(cameraPosition.target),
      cameraPosition.zoom,
    );
    return Future.value();
  }

  Future<void> rotateCamera(double rotation) {
    _controller.rotate(
      rotation,
    );
    return Future.value();
  }

  /// `_controller.fitBounds(LatLngUtils.toOSMBoundingBox(boundingBoxData.bounds))`
  ///
  /// The `fitBounds` function takes a `BoundingBox` object as a parameter. The
  /// `BoundingBox` object is a class that is defined in the `osmdart` package
  ///
  /// Args:
  ///   boundingBoxData (BoundingBoxData): The bounding box data that you want to
  /// update the map to.
  ///
  /// Returns:
  ///   Future.value()
  @override
  Future<void> updateBounds(BoundingBoxData boundingBoxData) {
    _controller.fitBounds(LatLngUtils.toOSMBoundingBox(boundingBoxData.bounds), options: OSM.FitBoundsOptions(padding: boundingBoxData.padding ?? EdgeInsets.all(0)));
    //final center = boundingBoxData.bounds.getCenter();
    //_controller.move(LatLngUtils.toOSMLatLng(center), 0);
    return Future.value();
  }

  @override
  LatLngBounds getBounds(Rectangle2D rectangle2d) {
    // TODO: implement getBounds
    throw UnimplementedError();
  }

  /// > The function takes in a screen coordinate and returns a LatLng object
  ///
  /// Args:
  ///   screenCoordinates (ScreenCoordinates): The screen coordinates of the point
  /// to get the LatLng of.
  ///
  /// Returns:
  ///   A LatLng object.
  @override
  Future<LatLng> getLatLng(ScreenCoordinates screenCoordinates) async {
    return Future.value(_controller.pointToLatLng(
        OSM.CustomPoint(screenCoordinates.x, screenCoordinates.y))) as LatLng;
  }

  /// > It converts a LatLng to a ScreenCoordinates
  ///
  /// Args:
  ///   latLng (LatLng): The latitude and longitude of the point to get the screen
  /// coordinates for.
  ///
  /// Returns:
  ///   A Future<ScreenCoordinates>
  @override
  Future<ScreenCoordinates> getScreenCoordinate(LatLng latLng) async {
    var point = _controller.latLngToScreenPoint(
      LatLngUtils.toOSMLatLng(latLng),
    );
    if (point != null) {
      return ScreenCoordinates(x: point.x.toInt(), y: point.y.toInt());
    }
    throw NullThrownError();
  }

  /// Get the current camera position of the map
  ///
  /// Returns:
  ///   A CameraPosition object.
  @override
  Future<CameraPosition> getCameraPosition() async {
    return CameraUtils.toAtlasCameraPosition(
         _controller.center, _controller.zoom, _controller.rotation);
  }

  /// `getVisibleArea` returns a `Future<LatLngBounds>` that resolves to the visible
  /// area of the map
  ///
  /// Returns:
  ///   A LatLngBounds object.
  @override
  Future<LatLngBounds> getVisibleArea() async {
    return LatLngUtils.fromOSMBoundingBox(
      await _controller.bounds!,
    );
  }

  @override
  Future<Uint8List> getScreenShot({int? x, int? y, int? width, int? height}) {
    // TODO: implement getScreenShot
    throw UnimplementedError();
  }

  @override
  Future<void> updateMapLogoBottomPadding(int bottomPadding) {
    // TODO: implement updateMapLogoBottomPadding
    throw UnimplementedError();
  }
}
