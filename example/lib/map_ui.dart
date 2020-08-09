// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

import 'page.dart';

final LatLngBounds sydneyBounds = LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

class MapUiPage extends ExamplePage {
  MapUiPage() : super(const Icon(Icons.map), 'User interface');

  @override
  Widget build(BuildContext context) {
    return const MapUiBody();
  }
}

class MapUiBody extends StatefulWidget {
  const MapUiBody();

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState();

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(-33.852, 151.211),
    zoom: 11,
  );

  CameraPosition _position = _kInitialPosition;
  bool _isMapCreated = false;
  bool _isMoving = false;
  bool _compassEnabled = true;
  bool _myLocationButtonEnabled = true;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  MapType _mapType = MapType.standard;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _pitchGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  AppleMapController _controller;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _compassToggler() {
    return FlatButton(
      child: Text('${_compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () {
        setState(() {
          _compassEnabled = !_compassEnabled;
        });
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return FlatButton(
      child: Text(_minMaxZoomPreference.minZoom == null
          ? 'bound zoom'
          : 'release zoom'),
      onPressed: () {
        setState(() {
          _minMaxZoomPreference = _minMaxZoomPreference.minZoom == null
              ? const MinMaxZoomPreference(12.0, 16.0)
              : MinMaxZoomPreference.unbounded;
        });
      },
    );
  }

  Widget _mapTypeCycler() {
    final MapType nextType =
        MapType.values[(_mapType.index + 1) % MapType.values.length];
    return FlatButton(
      child: Text('change map type to $nextType'),
      onPressed: () {
        setState(() {
          _mapType = nextType;
        });
      },
    );
  }

  Widget _rotateToggler() {
    return FlatButton(
      child: Text('${_rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        setState(() {
          _rotateGesturesEnabled = !_rotateGesturesEnabled;
        });
      },
    );
  }

  Widget _scrollToggler() {
    return FlatButton(
      child: Text('${_scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        setState(() {
          _scrollGesturesEnabled = !_scrollGesturesEnabled;
        });
      },
    );
  }

  Widget _tiltToggler() {
    return FlatButton(
      child: Text('${_pitchGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        setState(() {
          _pitchGesturesEnabled = !_pitchGesturesEnabled;
        });
      },
    );
  }

  Widget _zoomToggler() {
    return FlatButton(
      child: Text('${_zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        setState(() {
          _zoomGesturesEnabled = !_zoomGesturesEnabled;
        });
      },
    );
  }

  Widget _myLocationToggler() {
    return FlatButton(
      child: Text(
          '${_myLocationEnabled ? 'disable' : 'enable'} my location annotation'),
      onPressed: () {
        setState(() {
          _myLocationEnabled = !_myLocationEnabled;
        });
      },
    );
  }

  Widget _myLocationButtonToggler() {
    return FlatButton(
      child: Text(
          '${_myLocationButtonEnabled ? 'disable' : 'enable'} my location button'),
      onPressed: () {
        setState(() {
          _myLocationButtonEnabled = !_myLocationButtonEnabled;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppleMap appleMap = AppleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      compassEnabled: _compassEnabled,
      minMaxZoomPreference: _minMaxZoomPreference,
      mapType: _mapType,
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      pitchGesturesEnabled: _pitchGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: _myLocationButtonEnabled,
      onCameraMove: _updateCameraPosition,
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: appleMap,
          ),
        ),
      ),
    ];

    if (_isMapCreated) {
      columnChildren.add(
        Expanded(
          child: ListView(
            children: <Widget>[
              Text('camera bearing: ${_position.heading}'),
              Text(
                  'camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                  '${_position.target.longitude.toStringAsFixed(4)}'),
              Text('camera zoom: ${_position.zoom}'),
              Text('camera tilt: ${_position.pitch}'),
              Text(_isMoving ? '(Camera moving)' : '(Camera idle)'),
              _compassToggler(),
              _mapTypeCycler(),
              _zoomBoundsToggler(),
              _rotateToggler(),
              _scrollToggler(),
              _tiltToggler(),
              _zoomToggler(),
              _myLocationToggler(),
              _myLocationButtonToggler(),
            ],
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  void onMapCreated(AppleMapController controller) {
    setState(() {
      _controller = controller;
      _isMapCreated = true;
    });
  }
}
