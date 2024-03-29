// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

class PlacePolylinePage extends ExamplePage {
  PlacePolylinePage() : super(const Icon(Icons.linear_scale), 'Place polyline');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const PlacePolylineBody(),
    );
  }
}

class PlacePolylineBody extends StatefulWidget {
  const PlacePolylineBody();

  @override
  State<StatefulWidget> createState() => PlacePolylineBodyState();
}

class PlacePolylineBodyState extends State<PlacePolylineBody> {
  PlacePolylineBodyState();

  late AppleMapController controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  Uint8List? _imageBytes;
  PolylineId? selectedPolyline;

  // Values when toggling polyline color
  int colorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  // Values when toggling polyline width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  int jointTypesIndex = 0;
  List<JointType> jointTypes = <JointType>[
    JointType.mitered,
    JointType.bevel,
    JointType.round
  ];

  // Values when toggling polyline start cap type
  int lineCapsIndex = 0;
  List<Cap> lineCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline pattern
  int patternsIndex = 0;
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[],
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)],
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)],
  ];

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolylineTapped(PolylineId polylineId) {
    setState(() {
      selectedPolyline = polylineId;
    });
  }

  void _remove() {
    setState(() {
      if (polylines.containsKey(selectedPolyline)) {
        polylines.remove(selectedPolyline);
      }
      selectedPolyline = null;
    });
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.green,
      width: 5,
      points: _createPoints(),
      onTap: () {
        _onPolylineTapped(polylineId);
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  void _toggleVisible() {
    final Polyline polyline = polylines[selectedPolyline]!;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        visibleParam: !polyline.visible,
      );
    });
  }

  Future<void> _changeZIndex() async {
    final Polyline polyline = polylines[selectedPolyline]!;
    final int current = polyline.zIndex ?? 0;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        zIndexParam: current == 12 ? 0 : current + 1,
      );
    });
  }

  void _changeColor() {
    final Polyline polyline = polylines[selectedPolyline]!;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        colorParam: colors[++colorsIndex % colors.length],
      );
    });
  }

  void _changeWidth() {
    final Polyline polyline = polylines[selectedPolyline]!;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        widthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  void _changeJointType() {
    final Polyline polyline = polylines[selectedPolyline]!;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        jointTypeParam: jointTypes[++jointTypesIndex % jointTypes.length],
      );
    });
  }

  void _changeCaps() {
    final Polyline polyline = polylines[selectedPolyline]!;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        polylineCapParam: lineCaps[++lineCapsIndex % lineCaps.length],
      );
    });
  }

  void _changePattern() {
    final Polyline polyline = polylines[selectedPolyline]!;
    setState(() {
      polylines[selectedPolyline!] = polyline.copyWith(
        patternsParam: patterns[++patternsIndex % patterns.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: AppleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(52.4478, -3.5402),
              zoom: 7.0,
            ),
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: _onMapCreated,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton(child: const Text('add'), onPressed: _add),
              TextButton(
                  child: const Text('remove'),
                  onPressed: (selectedPolyline == null) ? null : _remove),
              TextButton(
                  child: const Text('toggle visible'),
                  onPressed:
                      (selectedPolyline == null) ? null : _toggleVisible),
              TextButton(
                  child: const Text('change zIndex'), onPressed: _changeZIndex),
              TextButton(
                  child: const Text('change width'),
                  onPressed: (selectedPolyline == null) ? null : _changeWidth),
              TextButton(
                  child: const Text('change color'),
                  onPressed: (selectedPolyline == null) ? null : _changeColor),
              TextButton(
                  child: const Text('change polyline caps'),
                  onPressed: (selectedPolyline == null) ? null : _changeCaps),
              TextButton(
                  child: const Text('change joint type'),
                  onPressed:
                      (selectedPolyline == null) ? null : _changeJointType),
              TextButton(
                  child: const Text('change pattern'),
                  onPressed:
                      (selectedPolyline == null) ? null : _changePattern),
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
        ),
      ],
    );
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = _polylineIdCounter.ceilToDouble();
    points.add(_createLatLng(51.4816 + offset, -3.1791));
    points.add(_createLatLng(53.0430 + offset, -2.9925));
    points.add(_createLatLng(53.1396 + offset, -4.2739));
    points.add(_createLatLng(52.4153 + offset, -4.0829));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
