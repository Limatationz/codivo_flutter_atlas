import 'package:atlas/atlas.dart';
import 'package:flutter_map/flutter_map.dart' as OSM;
import 'package:latlong2/latlong.dart' as OSMLATLNG;

import 'lat_lng_utils.dart';

class CameraUtils {
  /// Converts an `Atlas.LatLng` to a `GoogleMaps.CameraPosition`
  /*static GoogleMaps.CameraPosition toGoogleCameraPosition(
      CameraPosition position,
      ) {
    return GoogleMaps.CameraPosition(
      target: GoogleMaps.LatLng(
        position.target.latitude,
        position.target.longitude,
      ),
      zoom: position.zoom,
    );
  }*/

  /// Converts a OSM CameraPosition to an `Atlas.CameraPosition`
  static CameraPosition toAtlasCameraPosition(
      OSMLATLNG.LatLng position, double zoom, double rotation
      ) {
    return CameraPosition(
      target: LatLngUtils.fromOSMLatLng(position),
      zoom: zoom,
      rotation: rotation,
    );
  }
}
