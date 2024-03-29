// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'page.dart';

class PlacePolygonPage extends ExamplePage {
  PlacePolygonPage() : super(const Icon(Icons.linear_scale), 'Place polygon');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const PlacePolygonBody(),
    );
  }
}

class PlacePolygonBody extends StatefulWidget {
  const PlacePolygonBody();

  @override
  State<StatefulWidget> createState() => PlacePolygonBodyState();
}

class PlacePolygonBodyState extends State<PlacePolygonBody> {
  PlacePolygonBodyState();

  late AppleMapController controller;
  Map<PolygonId, Polygon> polygons = <PolygonId, Polygon>{};
  int _polygonIdCounter = 1;
  Uint8List? _imageBytes;
  PolygonId? selectedPolygon;

  // Values when toggling polygon color
  int strokeColorsIndex = 0;
  int fillColorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  // Values when toggling polygon width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolygonTapped(PolygonId polygonId) {
    setState(() {
      selectedPolygon = polygonId;
    });
  }

  void _remove() {
    setState(() {
      if (polygons.containsKey(selectedPolygon)) {
        polygons.remove(selectedPolygon);
      }
      selectedPolygon = null;
    });
  }

  void _add() {
    final int polygonCount = polygons.length;

    if (polygonCount == 12) {
      return;
    }

    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygonIdCounter++;
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon polygon = Polygon(
      polygonId: polygonId,
      consumeTapEvents: true,
      strokeColor: Colors.orange,
      strokeWidth: 5,
      fillColor: Colors.green,
      points: _createPoints(),
      onTap: () {
        _onPolygonTapped(polygonId);
      },
    );

    setState(() {
      polygons[polygonId] = polygon;
    });
  }

  void _toggleVisible() {
    final Polygon polygon = polygons[selectedPolygon]!;
    setState(() {
      polygons[selectedPolygon!] = polygon.copyWith(
        visibleParam: !polygon.visible,
      );
    });
  }

  Future<void> _changeZIndex() async {
    final Polygon polygon = polygons[selectedPolygon]!;
    final int current = polygon.zIndex ?? 0;
    setState(() {
      polygons[selectedPolygon!] = polygon.copyWith(
        zIndexParam: current == 12 ? 0 : current + 1,
      );
    });
  }

  void _changeStrokeColor() {
    final Polygon polygon = polygons[selectedPolygon]!;
    setState(() {
      polygons[selectedPolygon!] = polygon.copyWith(
        strokeColorParam: colors[++strokeColorsIndex % colors.length],
      );
    });
  }

  void _changeFillColor() {
    final Polygon polygon = polygons[selectedPolygon]!;
    setState(() {
      polygons[selectedPolygon!] = polygon.copyWith(
        fillColorParam: colors[++fillColorsIndex % colors.length],
      );
    });
  }

  void _changeWidth() {
    final Polygon polygon = polygons[selectedPolygon]!;
    setState(() {
      polygons[selectedPolygon!] = polygon.copyWith(
        strokeWidthParam: widths[++widthsIndex % widths.length],
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
            polygons: Set<Polygon>.of(polygons.values),
            onMapCreated: _onMapCreated,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text('add'),
                onPressed: _add,
              ),
              TextButton(
                child: const Text('remove'),
                onPressed: (selectedPolygon == null) ? null : _remove,
              ),
              TextButton(
                child: const Text('toggle visible'),
                onPressed: (selectedPolygon == null) ? null : _toggleVisible,
              ),
              TextButton(
                child: const Text('change zIndex'),
                onPressed: _changeZIndex,
              ),
              TextButton(
                child: const Text('change stroke width'),
                onPressed: (selectedPolygon == null) ? null : _changeWidth,
              ),
              TextButton(
                child: const Text('change stroke color'),
                onPressed:
                    (selectedPolygon == null) ? null : _changeStrokeColor,
              ),
              TextButton(
                child: const Text('change fill color'),
                onPressed: (selectedPolygon == null) ? null : _changeFillColor,
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
        ),
      ],
    );
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = _polygonIdCounter.ceilToDouble();
    points.add(_createLatLng(51.2395 + offset, -3.4314));
    points.add(_createLatLng(53.5234 + offset, -3.5314));
    points.add(_createLatLng(52.4351 + offset, -4.5235));
    points.add(_createLatLng(52.1231 + offset, -5.0829));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
