// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'page.dart';

class PlaceCirclePage extends ExamplePage {
  PlaceCirclePage() : super(const Icon(Icons.linear_scale), 'Place circle');

  @override
  Widget build(BuildContext context) {
    return const PlaceCircleBody();
  }
}

class PlaceCircleBody extends StatefulWidget {
  const PlaceCircleBody();

  @override
  State<StatefulWidget> createState() => PlaceCircleBodyState();
}

class PlaceCircleBodyState extends State<PlaceCircleBody> {
  PlaceCircleBodyState();

  late AppleMapController controller;
  Map<CircleId, Circle> circles = <CircleId, Circle>{};
  int _circleIdCounter = 1;
  CircleId? selectedCircle;

  Uint8List? _imageBytes;

  // Values when toggling circle color
  int fillColorsIndex = 0;
  int strokeColorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  // Values when toggling circle stroke width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCircleTapped(CircleId circleId) {
    setState(() {
      selectedCircle = circleId;
    });
  }

  void _remove() {
    setState(() {
      if (circles.containsKey(selectedCircle)) {
        circles.remove(selectedCircle);
      }
      selectedCircle = null;
    });
  }

  void _add() {
    final int circleCount = circles.length;

    if (circleCount == 12) {
      return;
    }

    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    final CircleId circleId = CircleId(circleIdVal);

    final Circle circle = Circle(
      circleId: circleId,
      consumeTapEvents: true,
      strokeColor: Colors.orange,
      fillColor: Colors.green,
      strokeWidth: 5,
      center: _createCenter(),
      radius: 50000,
      onTap: () {
        _onCircleTapped(circleId);
      },
    );

    setState(() {
      circles[circleId] = circle;
    });
  }

  void _toggleVisible() {
    final Circle circle = circles[selectedCircle]!;
    setState(() {
      circles[selectedCircle!] = circle.copyWith(
        visibleParam: !circle.visible,
      );
    });
  }

  void _changeFillColor() {
    final Circle circle = circles[selectedCircle]!;
    setState(() {
      circles[selectedCircle!] = circle.copyWith(
        fillColorParam: colors[++fillColorsIndex % colors.length],
      );
    });
  }

  void _changeStrokeColor() {
    final Circle circle = circles[selectedCircle]!;
    setState(() {
      circles[selectedCircle!] = circle.copyWith(
        strokeColorParam: colors[++strokeColorsIndex % colors.length],
      );
    });
  }

  void _changeStrokeWidth() {
    final Circle circle = circles[selectedCircle]!;
    setState(() {
      circles[selectedCircle!] = circle.copyWith(
        strokeWidthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: AppleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(52.4478, -3.5402),
                zoom: 7.0,
              ),
              circles: Set<Circle>.of(circles.values),
              onMapCreated: _onMapCreated,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text('add'),
                onPressed: _add,
              ),
              TextButton(
                child: const Text('remove'),
                onPressed: (selectedCircle == null) ? null : _remove,
              ),
              TextButton(
                child: const Text('toggle visible'),
                onPressed: (selectedCircle == null) ? null : _toggleVisible,
              ),
              TextButton(
                child: const Text('change zIndex'),
                onPressed: _changeZIndex,
              ),
              TextButton(
                child: const Text('change stroke width'),
                onPressed: (selectedCircle == null) ? null : _changeStrokeWidth,
              ),
              TextButton(
                child: const Text('change stroke color'),
                onPressed: (selectedCircle == null) ? null : _changeStrokeColor,
              ),
              TextButton(
                child: const Text('change fill color'),
                onPressed: (selectedCircle == null) ? null : _changeFillColor,
              ),
              TextButton(
                child: Text('Take a snapshot'),
                onPressed: () async {
                  final imageBytes = await this
                      .controller
                      .takeSnapshot(SnapshotOptions(showOverlays: true));
                  setState(() {
                    _imageBytes = imageBytes;
                  });
                },
              ),
              Container(
                decoration: BoxDecoration(color: Colors.blueGrey[50]),
                height: 180,
                child: _imageBytes != null ? Image.memory(_imageBytes!) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeZIndex() async {
    final Circle circle = circles[selectedCircle]!;
    final int current = circle.zIndex ?? 0;
    setState(() {
      circles[selectedCircle!] = circle.copyWith(
        zIndexParam: current == 12 ? 0 : current + 1,
      );
    });
  }

  LatLng _createCenter() {
    final double offset = _circleIdCounter.ceilToDouble();
    return _createLatLng(51.4816 + offset * 0.2, -3.1791);
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
