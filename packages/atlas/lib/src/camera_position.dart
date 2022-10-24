import 'package:atlas/atlas.dart';

/// The `CameraPosition` represents the position of the map "camera",
/// the view point from which the world is shown in the map view.
/// Aggregates the camera's `target` geographical location and the its `zoom` level.
class CameraPosition {
  /// The camera's `target` position as `LatLng`.
  final LatLng target;

  /// The camera's zoom level as a `double`.
  final double zoom;

  /// The camera's rotation level as a `double`. 0 is north, 90 is east, 180 is south, 270 is west.
  final double rotation;

  const CameraPosition({
    required this.target,
    this.zoom = 0.0,
    this.rotation = 0.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is CameraPosition) {
      return target == other.target && zoom == other.zoom && rotation == other.rotation;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => target.hashCode ^ zoom.hashCode ^ rotation.hashCode;

  @override
  String toString() {
    return 'CameraPosition{target: $target, zoom: $zoom, rotation: $rotation}';
  }

  static const CameraPosition initial = CameraPosition(
    target: LatLng(
      latitude: 49.954008,
      longitude: 11.587917,
    ),
    zoom: 7,
    rotation: 0,
  );

}
