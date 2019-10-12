// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

import 'fake_maps_controllers.dart';

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  testWidgets('Initial camera position', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.cameraPosition,
        const CameraPosition(target: LatLng(10.0, 15.0)));
  });

  testWidgets('Initial camera position change is a no-op',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 16.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.cameraPosition,
        const CameraPosition(target: LatLng(10.0, 15.0)));
  });

  testWidgets('Can update compassEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          compassEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.compassEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          compassEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.compassEnabled, true);
  });

  testWidgets('Can update mapType', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapType: MapType.hybrid,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.mapType, MapType.hybrid);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapType: MapType.satellite,
        ),
      ),
    );

    expect(platformAppleMap.mapType, MapType.satellite);
  });

  testWidgets('Can update minMaxZoom', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          minMaxZoomPreference: MinMaxZoomPreference(1.0, 3.0),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.minMaxZoomPreference,
        const MinMaxZoomPreference(1.0, 3.0));

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          minMaxZoomPreference: MinMaxZoomPreference.unbounded,
        ),
      ),
    );

    expect(
        platformAppleMap.minMaxZoomPreference, MinMaxZoomPreference.unbounded);
  });

  testWidgets('Can update rotateGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          rotateGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.rotateGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          rotateGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.rotateGesturesEnabled, true);
  });

  testWidgets('Can update scrollGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scrollGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.scrollGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scrollGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.scrollGesturesEnabled, true);
  });

  testWidgets('Can update pitchGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          pitchGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.pitchGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          pitchGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.pitchGesturesEnabled, true);
  });

  testWidgets('Can update trackCameraPosition', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.trackCameraPosition, false);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition:
              const CameraPosition(target: LatLng(10.0, 15.0)),
          onCameraMove: (CameraPosition position) {},
        ),
      ),
    );

    expect(platformAppleMap.trackCameraPosition, true);
  });

  testWidgets('Can update zoomGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          zoomGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.zoomGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          zoomGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.zoomGesturesEnabled, true);
  });

  testWidgets('Can update myLocationEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.myLocationEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.myLocationEnabled, true);
  });

  testWidgets('Can update myLocationButtonEnabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView;

    expect(platformAppleMap.myLocationButtonEnabled, true);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationButtonEnabled: false,
        ),
      ),
    );

    expect(platformAppleMap.myLocationButtonEnabled, false);
  });
}
