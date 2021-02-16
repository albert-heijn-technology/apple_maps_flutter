// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/services.dart';

import 'page.dart';
import 'dart:ui' as ui;

const imagesToLoad = [
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/34cedfbf-f062-4c52-838d-1a04bdc8f549.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2869fa75-7f7a-4580-8883-81239e96f638.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/60631592-ce00-4287-9bf8-f70f75a05f02.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/bc539a6d-a815-48b6-8ded-011ec740ddcc.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2869fa75-7f7a-4580-8883-81239e96f638.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2869fa75-7f7a-4580-8883-81239e96f638.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/f1327518-c3a1-4b47-9184-44ddfd957d83.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/e5f37117-d587-4d0f-956f-308770608b78.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/8d7d6914-bfa8-43c5-8b51-e11fe231288a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/07cc69bf-797c-4975-8807-f6ccc38ead19.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/701d583c-2ed8-4983-8e38-044a3d1612ab.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/8d7d6914-bfa8-43c5-8b51-e11fe231288a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/0b3d0384-035b-4632-b46d-a91a5fd6b446.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/eada9646-ecd0-46ff-b951-d94dfece9724.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/8d7d6914-bfa8-43c5-8b51-e11fe231288a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/f1327518-c3a1-4b47-9184-44ddfd957d83.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/37d55d11-f8b4-42d9-b98c-cecee6abcd4a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/be1fcb05-504f-4dc9-8f37-96917991ad03.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/6336186a-846f-4441-b6b7-98a8d9a09289.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/01ad4bdb-30f4-4acc-88a6-5a6fd47c975b.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/701d583c-2ed8-4983-8e38-044a3d1612ab.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/1dc6c273-115f-4b34-9b06-7a395b6320c2.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/3df4461b-befd-4bec-926f-bfe57a30091e.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/1b50f05d-7ebc-4cab-afe0-58ec70c62260.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/dd3e00d2-dbb6-4701-8f66-8954b3c4a287.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/11597100-e3b4-4ee9-a62f-e25fcaa6f097.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/d8c6fcc4-76f1-4bbd-a89c-66ef33a75358.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/e5f37117-d587-4d0f-956f-308770608b78.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/1dc6c273-115f-4b34-9b06-7a395b6320c2.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/a4067e66-af8b-4b14-868c-4b3b23174caf.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/d8d92e4b-4632-4052-9f27-0b161b8b1d3a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/f33aa263-93d0-4cc3-a342-9619c1189f15.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/33280744-228b-4a0b-996c-80750e2047d4.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/ce9820ef-659e-42b9-bbee-a0c2ac41e1ff.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/e509d0bd-fdfd-4bef-b7e0-2b4e0898ed06.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/4737eadc-848c-4bc7-b23e-e99d24479413.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/37d55d11-f8b4-42d9-b98c-cecee6abcd4a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/8d7d6914-bfa8-43c5-8b51-e11fe231288a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/37d55d11-f8b4-42d9-b98c-cecee6abcd4a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/f1327518-c3a1-4b47-9184-44ddfd957d83.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/c151d194-e216-4453-abb5-e7b2a3cf7b32.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/dc6b2d0f-623a-441e-80e0-b6e791d41c01.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/01ad4bdb-30f4-4acc-88a6-5a6fd47c975b.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/01ad4bdb-30f4-4acc-88a6-5a6fd47c975b.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/d8c6fcc4-76f1-4bbd-a89c-66ef33a75358.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/d8d92e4b-4632-4052-9f27-0b161b8b1d3a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/aed393a9-cc59-4311-99f5-15d5b25355f5.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/bc539a6d-a815-48b6-8ded-011ec740ddcc.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/be1fcb05-504f-4dc9-8f37-96917991ad03.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2d308a22-9dfe-4c4f-b890-bc49ae4c7f58.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/55efb13a-1439-454e-a77d-89f111593bff.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/8d7d6914-bfa8-43c5-8b51-e11fe231288a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/6336186a-846f-4441-b6b7-98a8d9a09289.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2eb07171-7da9-432b-bd09-3f0c42649c5d.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/0b3d0384-035b-4632-b46d-a91a5fd6b446.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/8d7d6914-bfa8-43c5-8b51-e11fe231288a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/aed393a9-cc59-4311-99f5-15d5b25355f5.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/be1fcb05-504f-4dc9-8f37-96917991ad03.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/07cc69bf-797c-4975-8807-f6ccc38ead19.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/5da965c9-7642-4272-91ef-4e1477dae834.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/60631592-ce00-4287-9bf8-f70f75a05f02.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/701d583c-2ed8-4983-8e38-044a3d1612ab.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2eb07171-7da9-432b-bd09-3f0c42649c5d.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/aec6d1a9-fae1-455b-abee-1e56826693f1.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/f33aa263-93d0-4cc3-a342-9619c1189f15.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/a015e854-6491-4a1c-966d-0c3658df81c6.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/701d583c-2ed8-4983-8e38-044a3d1612ab.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2869fa75-7f7a-4580-8883-81239e96f638.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/07cc69bf-797c-4975-8807-f6ccc38ead19.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/9a922db3-0bca-43d6-8db8-d5ca46e6517f.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/37d55d11-f8b4-42d9-b98c-cecee6abcd4a.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/e509d0bd-fdfd-4bef-b7e0-2b4e0898ed06.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/eada9646-ecd0-46ff-b951-d94dfece9724.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/ce9820ef-659e-42b9-bbee-a0c2ac41e1ff.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/aed393a9-cc59-4311-99f5-15d5b25355f5.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/0b3d0384-035b-4632-b46d-a91a5fd6b446.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/aed393a9-cc59-4311-99f5-15d5b25355f5.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/a015e854-6491-4a1c-966d-0c3658df81c6.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/0b3d0384-035b-4632-b46d-a91a5fd6b446.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/60cad65c-af8a-47d1-869b-f882bde6740d.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/96086d9a-e02a-46bd-ac26-88bedfec4609.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/3fd6518f-1f58-47d0-9639-9033fd11cc04.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/bc539a6d-a815-48b6-8ded-011ec740ddcc.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/e5f37117-d587-4d0f-956f-308770608b78.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/4737eadc-848c-4bc7-b23e-e99d24479413.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/55efb13a-1439-454e-a77d-89f111593bff.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/2eb07171-7da9-432b-bd09-3f0c42649c5d.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/55efb13a-1439-454e-a77d-89f111593bff.jpg",
  "https://d33hh7uv6ggn2z.cloudfront.net/image/zpp128/aec6d1a9-fae1-455b-abee-1e56826693f1.jpg"
];

class PlaceAnnotationClusteredPage extends ExamplePage {
  PlaceAnnotationClusteredPage() : super(const Icon(Icons.place), 'Place annotation clustered');

  @override
  Widget build(BuildContext context) {
    return const PlaceAnnotationClusteredBody();
  }
}

class PlaceAnnotationClusteredBody extends StatefulWidget {
  const PlaceAnnotationClusteredBody();

  @override
  State<StatefulWidget> createState() => PlaceAnnotationClusteredBodyState();
}

typedef Annotation AnnotationUpdateAction(Annotation annotation);

class PlaceAnnotationClusteredBodyState extends State<PlaceAnnotationClusteredBody> {
  PlaceAnnotationClusteredBodyState();
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  AppleMapController controller;
  Map<AnnotationId, Annotation> annotations = <AnnotationId, Annotation>{};
  AnnotationId selectedAnnotation;
  int _annotationIdCounter = 1;
  BitmapDescriptor _annotationIcon;
  BitmapDescriptor _iconFromBytes;
  double _devicePixelRatio = 3.0;

  BatchPinImageProcessorAnnotation _processor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _processor = BatchPinImageProcessorAnnotation(
        batchSize: 4,
        onBatchFinished: (list) {
          print("finished batch");
          setState(() {
            list.forEach((a) => annotations[a.annotationId] = a);
          });
        },
        onPinSelect: (p) => print(p.url));
  }

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  final Random _rng = Random();
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              child: AppleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 12,
                ),
                annotations: Set<Annotation>.of(annotations.values),
                enableClustering: true,
              ),
            ),
          ),
          FlatButton(
            child: const Text('customAnnotation from bytes'),
            onPressed: () {
              final pins = imagesToLoad.map((s) {
                // _annotationIdCounter++;
                final end = 0.005;
                final start = 0.05;
                final randlat = _rng.nextDouble() * (end - start) + start;
                final randlng = _rng.nextDouble() * (end - start) + start;
                return Pin(s, LatLng(center.latitude - randlat, center.longitude + randlng));
              }).toList();
              _processor.process(pins);
            },
          ),
        ]);
  }
}

abstract class BatchProcessor<T, R> {
  final Function(List<R>) onBatchFinished;

  BatchProcessor(this.onBatchFinished);

  void process(List<T> items);
}

abstract class BaseBatchProcessor<T, R> implements BatchProcessor<T, R> {
  int get batchSize;
  Function(List<R>) get onBatchFinished;

  List<T> _makeBatch(Queue<T> queue, int batchSizeUsed) {
    final List<T> currentBatch = [];
    while (currentBatch.length < batchSizeUsed && queue.isNotEmpty) {
      currentBatch.add(queue.removeFirst());
    }
    return currentBatch;
  }

  Future<List<R>> processBatch(List<T> batch);

  int determineBatchSize(List<T> items) {
    return batchSize;
  }

  @override
  void process(List<T> items) async {
    if (items.isEmpty) return;
    final int batchSize = determineBatchSize(items);
    final Queue<T> itemsQueue = Queue.from(items);
    while (itemsQueue.isNotEmpty) {
      final batch = _makeBatch(itemsQueue, batchSize);
      final results = await processBatch(batch);
      if (onBatchFinished != null) {
        onBatchFinished(results);
      }
    }
  }
}

class Pin {
  final String url;
  final LatLng position;
  Uint8List icon;

  Pin(this.url, this.position);
}

class BatchPinImageProcessorAnnotation extends BaseBatchProcessor<Pin, Annotation> {
  final int batchSize;
  final Function(List<Annotation>) onBatchFinished;
  final Function(Pin) onPinSelect;

  int thumbnailWidth;

  BatchPinImageProcessorAnnotation({this.batchSize, this.onBatchFinished, this.onPinSelect});

  final HttpClient _httpClient = HttpClient();

  @override
  Future<List<Annotation>> processBatch(List<Pin> batch) async {
    return Future.wait(batch.map((p) => _futureForPin(p).catchError((_) => null)))
        .then((unfilteredList) => unfilteredList.where((e) => e != null).toList());
  }

  Future<Annotation> _futureForPin(Pin pin) async {
    try {
      var request = await _httpClient.getUrl(Uri.parse(pin.url));
      var response = await request.close();
      // handle invalid/empty pin icons
      if (response.statusCode == 200) {
        pin.icon = await consolidateHttpClientResponseBytes(response);
      } else {
        pin.icon = null;
      }
    } catch (_) {
      pin.icon = null;
    }
    return _markerForPin(pin);
  }


final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Annotation _markerForPin(Pin pin) {
    return Annotation(
        annotationId: AnnotationId(getRandomString(8)),
        icon: BitmapDescriptor.fromBytes(pin.icon),
        position: pin.position,
        onTap: () {
          onPinSelect(pin);
        });
  }
}
