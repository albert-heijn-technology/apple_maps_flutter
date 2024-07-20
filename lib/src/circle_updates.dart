// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// [Circle] update events to be applied to the [AppleMap].
///
/// Used in [AppleMapController] when the map is updated.
class _CircleUpdates {
  /// Computes [_CircleUpdates] given previous and current [Circle]s.
  _CircleUpdates.from(Set<Circle>? previous, Set<Circle>? current) {
    if (previous == null) {
      previous = Set<Circle>.identity();
    }

    if (current == null) {
      current = Set<Circle>.identity();
    }

    final Map<CircleId, Circle> previousCircles = _keyByCircleId(previous);
    final Map<CircleId, Circle> currentCircles = _keyByCircleId(current);

    final Set<CircleId> prevCircleIds = previousCircles.keys.toSet();
    final Set<CircleId> currentCircleIds = currentCircles.keys.toSet();

    Circle idToCurrentCircle(CircleId id) {
      return currentCircles[id]!;
    }

    final Set<CircleId> _circleIdsToRemove =
        prevCircleIds.difference(currentCircleIds);

    final Set<Circle> _circlesToAdd = currentCircleIds
        .difference(prevCircleIds)
        .map(idToCurrentCircle)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Circle current) {
      final Circle? previous = previousCircles[current.circleId];
      return current != previous;
    }

    final Set<Circle> _circlesToChange = currentCircleIds
        .intersection(prevCircleIds)
        .map(idToCurrentCircle)
        .where(hasChanged)
        .toSet();

    circlesToAdd = _circlesToAdd;
    circleIdsToRemove = _circleIdsToRemove;
    circlesToChange = _circlesToChange;
  }

  late Set<Circle> circlesToAdd;
  late Set<CircleId> circleIdsToRemove;
  late Set<Circle> circlesToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('circlesToAdd', _serializeCircleSet(circlesToAdd));
    addIfNonNull('circlesToChange', _serializeCircleSet(circlesToChange));
    addIfNonNull('circleIdsToRemove',
        circleIdsToRemove.map<dynamic>((CircleId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _CircleUpdates) return false;
    final _CircleUpdates typedOther = other;
    return setEquals(circlesToAdd, typedOther.circlesToAdd) &&
        setEquals(circleIdsToRemove, typedOther.circleIdsToRemove) &&
        setEquals(circlesToChange, typedOther.circlesToChange);
  }

  @override
  int get hashCode =>
      Object.hash(circlesToAdd, circleIdsToRemove, circlesToChange);

  @override
  String toString() {
    return '_CircleUpdates{circlesToAdd: $circlesToAdd, '
        'circleIdsToRemove: $circleIdsToRemove, '
        'circlesToChange: $circlesToChange}';
  }
}
