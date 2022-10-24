import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Optional Marker icon.
class MarkerIcon {
  /// The [assetName] argument must not be null if [assetBytes] and [iconWidget] are null. It should name the main asset
  /// from the set of images to choose from. File should be of type png
  final String? assetName;

  /// The [assetBytes] argument must not be null if [assetName] and [iconWidget] are null.
  /// File should be of type png
  final Uint8List? assetBytes;

  /// The [iconWidget] argument must not be null if [assetName] and [assetBytes] are null.
  /// File should be of type png
  final Icon? iconWidget;

  /// The [width] argument is optional. It is the desired width in pixels.
  final int width;

  /// The [height] argument is optional. It is the desired height in pixels.
  final int height;

  const MarkerIcon({
    this.assetName,
    this.assetBytes,
    this.iconWidget,
    this.width = 0,
    this.height = 0,
  }) : assert(assetName != null || assetBytes != null || iconWidget != null);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is MarkerIcon) {
      return assetName == other.assetName &&
          width == other.width &&
          height == other.height &&
          assetBytes == other.assetBytes &&
          iconWidget == other.iconWidget;
    } else {
      return false;
    }
  }

  @override
  int get hashCode =>
      assetName.hashCode ^
      width.hashCode ^
      height.hashCode ^
      assetBytes.hashCode ^
      iconWidget.hashCode;
}
