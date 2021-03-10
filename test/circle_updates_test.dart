// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_maps_controllers.dart';

Set<Circle> _toSet({Circle? c1, Circle? c2, Circle? c3}) {
  final Set<Circle> res = Set<Circle>.identity();
  if (c1 != null) {
    res.add(c1);
  }
  if (c2 != null) {
    res.add(c2);
  }
  if (c3 != null) {
    res.add(c3);
  }
  return res;
}

Widget _mapWithCircles(Set<Circle>? circles) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: AppleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      circles: circles,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  testWidgets('Initializing a circle', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.circlesToAdd!.length, 1);

    final Circle initializedCircle = platformAppleMap.circlesToAdd!.first;
    expect(initializedCircle, equals(c1));
    expect(platformAppleMap.circleIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.circlesToChange!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Adding a circle", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_2"));

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1, c2: c2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.circlesToAdd!.length, 1);

    final Circle addedCircle = platformAppleMap.circlesToAdd!.first;
    expect(addedCircle, equals(c2));

    expect(platformAppleMap.circleIdsToRemove!.isEmpty, true);

    expect(platformAppleMap.circlesToChange!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Removing a circle", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Circle c1 = Circle(circleId: CircleId("circle_1"));

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(null));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.circleIdsToRemove!.length, 1);
    expect(platformAppleMap.circleIdsToRemove!.first, equals(c1.circleId));

    expect(platformAppleMap.circlesToChange!.isEmpty, true);
    expect(platformAppleMap.circlesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Updating a circle", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_1"), radius: 10);

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.circlesToChange!.length, 1);
    expect(platformAppleMap.circlesToChange!.first, equals(c2));

    expect(platformAppleMap.circleIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.circlesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Updating a circle", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_1"), radius: 10);

    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c1)));
    await tester.pumpWidget(_mapWithCircles(_toSet(c1: c2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.circlesToChange!.length, 1);

    final Circle update = platformAppleMap.circlesToChange!.first;
    expect(update, equals(c2));
    expect(update.radius, 10);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Circle c1 = Circle(circleId: CircleId("circle_1"));
    Circle c2 = Circle(circleId: CircleId("circle_2"));
    final Set<Circle> prev = _toSet(c1: c1, c2: c2);
    c1 = Circle(circleId: CircleId("circle_1"), visible: false);
    c2 = Circle(circleId: CircleId("circle_2"), radius: 10);
    final Set<Circle> cur = _toSet(c1: c1, c2: c2);

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.circlesToChange, cur);
    expect(platformAppleMap.circleIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.circlesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Circle c2 = Circle(circleId: CircleId("circle_2"));
    final Circle c3 = Circle(circleId: CircleId("circle_3"));
    final Set<Circle> prev = _toSet(c2: c2, c3: c3);

    // c1 is added, c2 is updated, c3 is removed.
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    c2 = Circle(circleId: CircleId("circle_2"), radius: 10);
    final Set<Circle> cur = _toSet(c1: c1, c2: c2);

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.circlesToChange!.length, 1);
    expect(platformAppleMap.circlesToAdd!.length, 1);
    expect(platformAppleMap.circleIdsToRemove!.length, 1);

    expect(platformAppleMap.circlesToChange!.first, equals(c2));
    expect(platformAppleMap.circlesToAdd!.first, equals(c1));
    expect(platformAppleMap.circleIdsToRemove!.first, equals(c3.circleId));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Circle c1 = Circle(circleId: CircleId("circle_1"));
    final Circle c2 = Circle(circleId: CircleId("circle_2"));
    Circle c3 = Circle(circleId: CircleId("circle_3"));
    final Set<Circle> prev = _toSet(c1: c1, c2: c2, c3: c3);
    c3 = Circle(circleId: CircleId("circle_3"), radius: 10);
    final Set<Circle> cur = _toSet(c1: c1, c2: c2, c3: c3);

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.circlesToChange, _toSet(c3: c3));
    expect(platformAppleMap.circleIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.circlesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });
}
