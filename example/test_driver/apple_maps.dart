// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apple_map_inspector.dart';
import 'test_widgets.dart';

const LatLng _kInitialMapCenter = LatLng(0, 0);
const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: _kInitialMapCenter);

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);

  tearDownAll(() => allTestsCompleter.complete(null));

  test('testCompassToggle', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool compassEnabled = (await inspector.isCompassEnabled())!;
    expect(compassEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: true,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    compassEnabled = (await inspector.isCompassEnabled())!;
    expect(compassEnabled, true);
  });

  test('updateMinMaxZoomLevels', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    const MinMaxZoomPreference initialZoomLevel = MinMaxZoomPreference(2, 4);
    const MinMaxZoomPreference finalZoomLevel = MinMaxZoomPreference(3, 8);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: initialZoomLevel,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    MinMaxZoomPreference zoomLevel = await inspector.getMinMaxZoomLevels();
    expect(zoomLevel, equals(initialZoomLevel));

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: finalZoomLevel,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    zoomLevel = await inspector.getMinMaxZoomLevels();
    expect(zoomLevel, equals(finalZoomLevel));
  });

  test('testZoomGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        zoomGesturesEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool zoomGesturesEnabled = (await inspector.isZoomGesturesEnabled())!;
    expect(zoomGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        zoomGesturesEnabled: true,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    zoomGesturesEnabled = (await inspector.isZoomGesturesEnabled())!;
    expect(zoomGesturesEnabled, true);
  });

  test('testRotateGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        rotateGesturesEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool rotateGesturesEnabled = (await inspector.isRotateGesturesEnabled())!;
    expect(rotateGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        rotateGesturesEnabled: true,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    rotateGesturesEnabled = (await inspector.isRotateGesturesEnabled())!;
    expect(rotateGesturesEnabled, true);
  });

  test('testTiltGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        pitchGesturesEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool pitchGesturesEnabled = (await inspector.isPitchGesturesEnabled())!;
    expect(pitchGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        pitchGesturesEnabled: true,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    pitchGesturesEnabled = (await inspector.isPitchGesturesEnabled())!;
    expect(pitchGesturesEnabled, true);
  });

  test('testScrollGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        scrollGesturesEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool scrollGesturesEnabled = (await inspector.isScrollGesturesEnabled())!;
    expect(scrollGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        scrollGesturesEnabled: true,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    scrollGesturesEnabled = (await inspector.isScrollGesturesEnabled())!;
    expect(scrollGesturesEnabled, true);
  });

  // test('testGetVisibleRegion', () async {
  //   final Key key = GlobalKey();
  //   final LatLngBounds zeroLatLngBounds = LatLngBounds(
  //       southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

  //   final Completer<AppleMapController> mapControllerCompleter =
  //       Completer<AppleMapController>();

  //   await pumpWidget(Directionality(
  //     textDirection: TextDirection.ltr,
  //     child: AppleMap(
  //       key: key,
  //       initialCameraPosition: _kInitialCameraPosition,
  //       onMapCreated: (AppleMapController controller) {
  //         mapControllerCompleter.complete(controller);
  //       },
  //     ),
  //   ));
  //   final AppleMapController mapController =
  //       await mapControllerCompleter.future;

  //   await Future<dynamic>.delayed(const Duration(seconds: 3));

  //   final LatLngBounds firstVisibleRegion =
  //       await mapController.getVisibleRegion();

  //   expect(firstVisibleRegion, isNotNull);
  //   expect(firstVisibleRegion.southwest, isNotNull);
  //   expect(firstVisibleRegion.northeast, isNotNull);
  //   expect(firstVisibleRegion, isNot(zeroLatLngBounds));
  //   expect(firstVisibleRegion.contains(_kInitialMapCenter), isTrue);

  //   const LatLng southWest = LatLng(60, 75);
  //   const LatLng northEast = LatLng(65, 80);
  //   final LatLng newCenter = LatLng(
  //     (northEast.latitude + southWest.latitude) / 2,
  //     (northEast.longitude + southWest.longitude) / 2,
  //   );

  //   expect(firstVisibleRegion.contains(northEast), isFalse);
  //   expect(firstVisibleRegion.contains(southWest), isFalse);

  //   final LatLngBounds latLngBounds =
  //       LatLngBounds(southwest: southWest, northeast: northEast);

  //   // TODO(iskakaushik): non-zero padding is needed for some device configurations
  //   // https://github.com/flutter/flutter/issues/30575
  //   final double padding = 0;
  //   await mapController
  //       .moveCamera(CameraUpdate.newLatLngBounds(latLngBounds, padding));

  //   final LatLngBounds secondVisibleRegion =
  //       await mapController.getVisibleRegion();

  //   expect(secondVisibleRegion, isNotNull);
  //   expect(secondVisibleRegion.southwest, isNotNull);
  //   expect(secondVisibleRegion.northeast, isNotNull);
  //   expect(secondVisibleRegion, isNot(zeroLatLngBounds));

  //   expect(firstVisibleRegion, isNot(secondVisibleRegion));
  //   expect(secondVisibleRegion.contains(newCenter), isTrue);
  // });

  test('testMyLocationButtonToggle', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool myLocationButtonEnabled =
        (await inspector.isMyLocationButtonEnabled())!;
    expect(myLocationButtonEnabled, true);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        onMapCreated: (AppleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    myLocationButtonEnabled = (await inspector.isMyLocationButtonEnabled())!;
    expect(myLocationButtonEnabled, false);
  });

  test('testMyLocationButton initial value false', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    final bool myLocationButtonEnabled =
        (await inspector.isMyLocationButtonEnabled())!;
    expect(myLocationButtonEnabled, false);
  });

  test('testMyLocationButton initial value true', () async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: AppleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        onMapCreated: (AppleMapController controller) {
          final AppleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              AppleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final AppleMapInspector inspector = await inspectorCompleter.future;
    final bool myLocationButtonEnabled =
        (await inspector.isMyLocationButtonEnabled())!;
    expect(myLocationButtonEnabled, false);
  });
}
