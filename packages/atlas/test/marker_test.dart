import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/atlas.dart';

main() {
  group('Marker', () {
    test('should have correct properties when no onTap is provided', () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final dynamic expectedOnTap = null;
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        onTap: expectedOnTap,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.onTap, expectedOnTap);
    });

    test('should have correct properties when no zIndex is provided', () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final dynamic expectedOnTap = null;
      final expectedZIndex = 0.0;
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        onTap: expectedOnTap,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.onTap, expectedOnTap);
      expect(marker.zIndex, expectedZIndex);
    });

    test('should have correct properties when zIndex is provided', () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final dynamic expectedOnTap = null;
      final expectedZIndex = 1.0;
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        onTap: expectedOnTap,
        zIndex: 1.0,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.onTap, expectedOnTap);
      expect(marker.zIndex, expectedZIndex);
    });

    test('should have correct properties when onTap is provided', () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final expectedOnTap = () {};
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        onTap: expectedOnTap,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.onTap, expectedOnTap);
    });

    test('should have correct properties when no MarkerAnnotation is provided',
        () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final dynamic expectedPopupWidget = null;
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        popupWidget: expectedPopupWidget,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.popupWidget, expectedPopupWidget);
    });

    test('should have correct properties when MarkerAnnotation is provided',
        () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final expectedPopupWidget = Text('MarkerAnnotation Title'
      );
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        popupWidget: expectedPopupWidget,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.popupWidget!, expectedPopupWidget);
    });

    test('different instances with same properties should be equal', () {
      final onTap = () {};
      final marker1 = Marker(
        id: 'id',
        position: LatLng(
          latitude: 37.42796133580664,
          longitude: -122.085749655962,
        ),
        onTap: onTap,
        zIndex: 1.0,
        anchor: Anchor(),
      );
      final marker2 = Marker(
        id: 'id',
        position: LatLng(
          latitude: 37.42796133580664,
          longitude: -122.085749655962,
        ),
        onTap: onTap,
        zIndex: 1.0,
        anchor: Anchor(),
      );

      expect(marker1, marker2);
    });

    test('should have correct properties when heading is provided', () {
      final expectedId = 'id';
      final expectedPosition = LatLng(
        latitude: 37.42796133580664,
        longitude: -122.085749655962,
      );
      final dynamic expectedOnTap = null;
      final expectedHeading = 180;
      final marker = Marker(
        id: expectedId,
        position: expectedPosition,
        onTap: expectedOnTap,
        heading: 180,
      );
      expect(marker.id, expectedId);
      expect(marker.position, expectedPosition);
      expect(marker.onTap, expectedOnTap);
      expect(marker.heading, expectedHeading);
    });
  });

  group('Anchor', () {
    test('different instances with different properties should NOT be equal',
        () {
      final anchor1 = Anchor(x: 1, y: 2);
      final anchor2 = Anchor(x: 1, y: 3);

      expect(anchor1, isNot(equals(anchor2)));
    });

    test('should override hashCode properly', () {
      final anchor = Anchor(x: 1, y: 2);
      expect(
        1.hashCode ^ 2.hashCode,
        anchor.hashCode,
      );
    });
  });
}
