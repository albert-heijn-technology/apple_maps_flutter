import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('apple_maps_flutter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
