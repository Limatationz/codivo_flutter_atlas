import 'package:atlas/atlas.dart';
import 'package:atlas/src/lat_lng_utils.dart';

/// A latitude/longitude aligned rectangle.
///
/// The rectangle conceptually includes all points (lat, lng) where
/// * lat ∈ [`southwest.latitude`, `northeast.latitude`]
/// * lng ∈ [`southwest.longitude`, `northeast.longitude`],
///   if `southwest.longitude` ≤ `northeast.longitude`,
/// * lng ∈ [-180, `northeast.longitude`] ∪ [`southwest.longitude`, 180[,
///   if `northeast.longitude` < `southwest.longitude`
class LatLngBounds {
  final LatLng northeast;
  final LatLng southwest;

  const LatLngBounds({
    required this.northeast,
    required this.southwest,
  });

  LatLngBounds.fromPoints({required List<LatLng> points}) : this(northeast: getNorthEast(points), southwest: getSouthWest(points));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is LatLngBounds) {
      return northeast == other.northeast && southwest == other.southwest;
    } else {
      return false;
    }
  }

  /// If the point is within the bounds, return true
  ///
  /// Args:
  ///   point (LatLng): The point to check.
  ///   offset (double): The offset in degrees to extend the bounds. Defaults to 0.0
  ///
  /// Returns:
  ///   A boolean value.
  bool containsPoint(LatLng point, {double offset = 0.0}) {
    return point.latitude <= northeast.latitude + offset &&
        point.latitude >= southwest.latitude - offset &&
            point.longitude <= northeast.longitude + offset &&
                point.longitude >= southwest.longitude - offset;
  }

  /// It returns the center of the bounding box.
  LatLng getCenter() => LatLng(
      latitude: (northeast.latitude + southwest.latitude) / 2,
      longitude: (northeast.longitude + southwest.longitude) / 2,
    );

  @override
  int get hashCode => northeast.hashCode ^ southwest.hashCode;

  @override
  String toString() {
    return 'LatLngBounds{northeast: $northeast, southwest: $southwest}';
  }

  /// It takes a list of points and returns the point that is furthest north and
  /// east
  ///
  /// Args:
  ///   points (List<LatLng>): A list of LatLng objects that represent the points of
  /// the polygon.
  ///
  /// Returns:
  ///   The north east corner of the bounding box.
  static LatLng getNorthEast(List<LatLng> points) {
    if (points.isNotEmpty) {
      num? minX;
      num? maxX;
      num? minY;
      num? maxY;

      for (final point in points) {
        final num x = degToRadian(point.longitude);
        final num y = degToRadian(point.latitude);

        if (minX == null || minX > x) {
          minX = x;
        }

        if (minY == null || minY > y) {
          minY = y;
        }

        if (maxX == null || maxX < x) {
          maxX = x;
        }

        if (maxY == null || maxY < y) {
          maxY = y;
        }
      }
      return LatLng(latitude: radianToDeg(maxY as double), longitude: radianToDeg(maxX as double));
    }
    else {
      return LatLng(latitude: 0, longitude: 0);
    }
  }

  /// It takes a list of points and returns the point with the lowest latitude and
  /// longitude
  ///
  /// Args:
  ///   points (List<LatLng>): A list of LatLng objects that represent the points of
  /// the polygon.
  ///
  /// Returns:
  ///   The southwest corner of the bounding box.
  static LatLng getSouthWest(List<LatLng> points) {
    if (points.isNotEmpty) {
      num? minX;
      num? maxX;
      num? minY;
      num? maxY;

      for (final point in points) {
        final num x = degToRadian(point.longitude);
        final num y = degToRadian(point.latitude);

        if (minX == null || minX > x) {
          minX = x;
        }

        if (minY == null || minY > y) {
          minY = y;
        }

        if (maxX == null || maxX < x) {
          maxX = x;
        }

        if (maxY == null || maxY < y) {
          maxY = y;
        }
      }
      return LatLng(latitude: radianToDeg(minY as double), longitude: radianToDeg(minX as double));
    }
    else {
      return LatLng(latitude: 0, longitude: 0);
    }
  }
}
