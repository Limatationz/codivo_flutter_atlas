import 'dart:async';
import 'dart:typed_data';

import 'package:atlas/atlas.dart';
import 'package:atlas/src/camera_status.dart';
import 'package:google_atlas/src/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMaps;
import 'package:rxdart/src/subjects/behavior_subject.dart';

class GoogleAtlasController implements AtlasController {
  final GoogleMaps.GoogleMapController _controller;

  @override
  BehaviorSubject<CameraStatus> cameraStatusStream;

  GoogleAtlasController({required GoogleMaps.GoogleMapController controller})
      : _controller = controller, cameraStatusStream = BehaviorSubject.seeded(CameraStatus.idle);

  @override
  Future<void> moveCamera(CameraPosition cameraPosition,
      {MoveCameraAnimation? animation}) {
    return _controller.moveCamera(
      GoogleMaps.CameraUpdate.newCameraPosition(
        CameraUtils.toGoogleCameraPosition(cameraPosition),
      ),
    );
  }

  @override
  Future<void> rotateCamera(double rotation) async {
    final visibleRegion = await _controller.getVisibleRegion();
    final center = GoogleMaps.LatLng(
        (visibleRegion.northeast.latitude +
            visibleRegion.southwest.latitude) /
            2,
        (visibleRegion.northeast.longitude +
            visibleRegion.southwest.longitude) /
            2);
    return _controller.moveCamera(
      GoogleMaps.CameraUpdate.newCameraPosition(
          GoogleMaps.CameraPosition(target: center, zoom: await _controller.getZoomLevel(), bearing: rotation)),
    );
  }

  @override
  Future<void> updateBounds(BoundingBoxData boundingBoxData) {
    return _controller.moveCamera(
      GoogleMaps.CameraUpdate.newLatLngBounds(
        LatLngUtils.toGoogleLatLngBounds(boundingBoxData.bounds),
        boundingBoxData.padding?.top ?? 0,
      ),
    );
  }

  @override
  LatLngBounds getBounds(Rectangle2D rectangle2d) {
    // TODO: implement getBounds
    throw UnimplementedError();
  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinates screenCoordinates) async {
    var googleLatLng = await _controller
        .getLatLng(LatLngUtils.toGoogleScreenCoordinate(screenCoordinates));
    return LatLngUtils.fromGoogleLatLng(googleLatLng);
  }

  @override
  Future<ScreenCoordinates> getScreenCoordinate(LatLng latLng) async {
    var googleScreenCoordinate = await _controller
        .getScreenCoordinate(LatLngUtils.toGoogleLatLng(latLng));
    return LatLngUtils.fromGoogleScreenCoordinate(googleScreenCoordinate);
  }

  @override
  Future<CameraPosition> getCameraPosition() async {
    final visibleRegion = await _controller.getVisibleRegion();
    final center = LatLng(
        latitude: (visibleRegion.northeast.latitude +
                visibleRegion.southwest.latitude) /
            2,
        longitude: (visibleRegion.northeast.longitude +
                visibleRegion.southwest.longitude) /
            2);
    return CameraPosition(target: center, zoom: await _controller.getZoomLevel());
  }

  @override
  Future<LatLngBounds> getVisibleArea() async {
    return LatLngUtils.fromGoogleLatLngBounds(
      await _controller.getVisibleRegion(),
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
