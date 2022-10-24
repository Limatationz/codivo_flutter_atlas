import 'package:latlong2/latlong.dart' as LatLngUtil;

/// A pair of latitude and longitude coordinates.
/// The `latitude` and `longitude` are stored as degrees.
class LatLng {
  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  const LatLng({
    required double latitude,
    required double longitude,
  })  : latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is LatLng) {
      return latitude == other.latitude && longitude == other.longitude;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude}';
  }

  /// Calculates the distance between two points.
  ///
  /// Args:
  ///   other (LatLng): The other LatLng object to calculate the distance to.
  ///
  /// Returns:
  ///   The distance between two points in meters.
  double calculateDistance(LatLng other){
    final LatLngUtil.Distance distance = LatLngUtil.Distance();
    return distance.as(LatLngUtil.LengthUnit.Meter, LatLngUtil.LatLng(latitude, longitude), LatLngUtil.LatLng(other.latitude, other.longitude)).toDouble();
  }
}
