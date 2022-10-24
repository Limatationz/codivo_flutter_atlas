import 'package:atlas/atlas.dart';
import 'package:flutter_map/flutter_map.dart' as OSM;
import 'package:latlong2/latlong.dart' as OSMLATLNG;

class LatLngUtils {
  /// It takes a `LatLngBounds` object and returns an `OSM.BoundingBox` object
  ///
  /// Args:
  ///   bounds (LatLngBounds): The bounds of the map view.
  ///
  /// Returns:
  ///   A bounding box object.
  static OSM.LatLngBounds toOSMBoundingBox(LatLngBounds bounds) {
    return OSM.LatLngBounds(
      toOSMLatLng(bounds.southwest),
      toOSMLatLng(bounds.northeast),
    );
  }

  /// It converts the OSM.BoundingBox object to a LatLngBounds object.
  ///
  /// Args:
  ///   osmBoundingBox (OSM): The bounding box of the map.
  ///
  /// Returns:
  ///   A LatLngBounds object.
  static LatLngBounds fromOSMBoundingBox(OSM.LatLngBounds osmBoundingBox) {
    return LatLngBounds(
      northeast: fromOSMLatLng(osmBoundingBox.northEast!),
      southwest: fromOSMLatLng(osmBoundingBox.southWest!),
    );
  }

  /// It takes a LatLng object and returns an OSM.GeoPoint object
  ///
  /// Args:
  ///   latLng (LatLng): The LatLng object that you want to convert to an
  /// OSM.GeoPoint object.
  ///
  /// Returns:
  ///   A GeoPoint object.
  static OSMLATLNG.LatLng toOSMLatLng(LatLng latLng) {
    return OSMLATLNG.LatLng(latLng.latitude, latLng.longitude);
  }

  /// It takes an OSM.GeoPoint and returns a LatLng
  ///
  /// Args:
  ///   position (OSM): The position of the marker.
  ///
  /// Returns:
  ///   A LatLng object.
  static LatLng fromOSMLatLng(OSMLATLNG.LatLng position) {
    return LatLng(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

/*
  /// Converts an `Atlas.ScreenCoordinates` to a `GoogleMaps.ScreenCoordinate`.
  static OSM.S toGoogleScreenCoordinate(
      ScreenCoordinates atlasCoordinates) {
    return GoogleMaps.ScreenCoordinate(
      x: atlasCoordinates.x,
      y: atlasCoordinates.y,
    );
  }

  /// Converts a `GoogleMaps.ScreenCoordinate` to an `Atlas.ScreenCoordinates`.
  static ScreenCoordinates fromGoogleScreenCoordinate(
      GoogleMaps.ScreenCoordinate googleCoordinate) {
    return ScreenCoordinates(
      x: googleCoordinate.x,
      y: googleCoordinate.y,
    );
  }*/
}
