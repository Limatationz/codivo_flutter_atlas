import 'package:atlas/atlas.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/widgets.dart';

/// Marks a geographical location on the map.
class Marker extends Clusterable {
  /// Uniquely identifies a `Marker`.
  final String id;

  /// The location where the `Marker` is drawn is represented as `LatLng`.
  final LatLng position;

  /// Optional MarkerIcon used to replace default icon.
  final MarkerIcon? icon;

  /// A `void Function` which is called whenever a `Marker` is tapped.
  final VoidCallback? onTap;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Lower values means drawn earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Specifies the anchor to be at a particular point in the marker image.
  final Anchor? anchor;

  /// Optional heading used to rotate the marker in degrees (eg. 0 to 360).
  final int? heading;

  /// Is the Marker a Cluster?
  final bool isCluster;

  /// Popup widget to show when the marker is tapped.
  final Widget? popupWidget;

  /// Popup widget to show on start
  final bool showPopupWidget;

  /// parent data
  final dynamic parent;

  Marker(
      {required this.id,
      required this.position,
      this.onTap,
      this.icon,
      this.zIndex = 0.0,
      this.anchor,
      this.heading,
      this.isCluster = false,
      this.parent,
      this.popupWidget,
      this.showPopupWidget = false,
      clusterId,
      pointsSize,
      markerId,
      childMarkerId})
      : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is Marker) {
      return id == other.id &&
          position == other.position &&
          parent == other.parent &&
          icon == other.icon &&
          zIndex == other.zIndex &&
          anchor == other.anchor &&
          popupWidget == other.popupWidget &&
          showPopupWidget == other.showPopupWidget &&
          isCluster == other.isCluster &&
          heading == other.heading;
    } else {
      return false;
    }
  }

  @override
  int get hashCode =>
      id.hashCode ^
      position.hashCode ^
      parent.hashCode ^
      icon.hashCode ^
      zIndex.hashCode ^
      anchor.hashCode ^
      heading.hashCode ^
      popupWidget.hashCode ^
      showPopupWidget.hashCode ^
      isCluster.hashCode;

  @override
  String toString() {
    return 'Marker{id: $id, position: $position, icon: $icon, onTap: $onTap, zIndex: $zIndex, anchor: $anchor, heading: $heading, isCluster: $isCluster, showPopupWidget: $showPopupWidget, popupWidget: $popupWidget, parent: $parent}';
  }

  Marker copyWith({
    String? id,
    LatLng? position,
    MarkerIcon? icon,
    VoidCallback? onTap,
    double? zIndex,
    Anchor? anchor,
    int? heading,
    bool? isCluster,
    dynamic parent,
    Widget? popupWidget,
    bool? showPopupWidget,
    String? clusterId,
    int? pointsSize,
    String? markerId,
    String? childMarkerId,
  }) {
    return Marker(
      id: id ?? this.id,
      position: position ?? this.position,
      onTap: onTap ?? this.onTap,
      icon: icon ?? this.icon,
      zIndex: zIndex ?? this.zIndex,
      anchor: anchor ?? this.anchor,
      heading: heading ?? this.heading,
      isCluster: isCluster ?? this.isCluster,
      parent: parent ?? this.parent,
      popupWidget: popupWidget ?? this.popupWidget,
      showPopupWidget: showPopupWidget ?? this.showPopupWidget,
      clusterId: clusterId ?? this.clusterId,
      pointsSize: pointsSize ?? this.pointsSize,
      markerId: markerId ?? this.markerId,
      childMarkerId: childMarkerId ?? this.childMarkerId,
    );
  }
}

/// {@template anchor}
/// Specifies the anchor to be at a particular point in the marker image.
///
/// The anchor specifies the point in the icon image that is anchored
/// to the marker's position on the Earth's surface.
///
/// The anchor point is specified in the continuous space [0.0, 1.0] x [0.0, 1.0],
/// where (0, 0) is the top-left corner of the image, and (1, 1) is the bottom-right corner.
/// The anchoring point in a W x H image is the nearest discrete grid point in a
/// (W + 1) x (H + 1) grid, obtained by scaling the then rounding.
/// For example, in a 4 x 2 image, the anchor point (0.7, 0.6) resolves
/// to the grid point at (3, 1).
/// {@endtemplate}
class Anchor {
  /// u-coordinate of the anchor, as a ratio of the image width (in the range [0, 1])
  final double x;

  /// v-coordinate of the anchor, as a ratio of the image height (in the range [0, 1])
  final double y;

  /// {@macro anchor}
  const Anchor({this.x = 0.5, this.y = 0.5});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is Anchor) {
      return x == other.x && y == other.y;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// Text labels for a [Marker] info window.
class Annotation {
  final String? title;

  final String? subTitle;

  final MarkerIcon? icon;

  /// A `void Function` which is called whenever a `Marker info` is tapped.
  final VoidCallback? onTap;

  final AnnotationType annotationType;

  const Annotation({
    this.title,
    this.subTitle,
    this.icon,
    this.onTap,
    this.annotationType = AnnotationType.destination,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is Annotation) {
      return title == other.title &&
          subTitle == other.subTitle &&
          icon == other.icon &&
          annotationType == other.annotationType;
    } else {
      return false;
    }
  }

  @override
  int get hashCode =>
      title.hashCode ^
      subTitle.hashCode ^
      icon.hashCode ^
      annotationType.hashCode;
}
