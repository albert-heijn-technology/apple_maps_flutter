// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// [Annotation] update events to be applied to the [AppleMap].
///
/// Used in [AppleMapController] when the map is updated.
class _AnnotationUpdates {
  /// Computes [_AnnotationUpdates] given previous and current [Annotation]s.
  _AnnotationUpdates.from(Set<Annotation>? previous, Set<Annotation>? current) {
    if (previous == null) {
      previous = Set<Annotation>.identity();
    }

    if (current == null) {
      current = Set<Annotation>.identity();
    }

    final Map<AnnotationId, Annotation> previousAnnotations =
        _keyByAnnotationId(previous);
    final Map<AnnotationId, Annotation> currentAnnotations =
        _keyByAnnotationId(current);

    final Set<AnnotationId> prevAnnotationIds =
        previousAnnotations.keys.toSet();
    final Set<AnnotationId> currentAnnotationIds =
        currentAnnotations.keys.toSet();

    Annotation idToCurrentAnnotation(AnnotationId id) {
      return currentAnnotations[id]!;
    }

    final Set<AnnotationId> _annotationIdsToRemove =
        prevAnnotationIds.difference(currentAnnotationIds);

    final Set<Annotation> _annotationsToAdd = currentAnnotationIds
        .difference(prevAnnotationIds)
        .map(idToCurrentAnnotation)
        .toSet();

    final Set<Annotation> _annotationsToChange = currentAnnotationIds
        .intersection(prevAnnotationIds)
        .map(idToCurrentAnnotation)
        .toSet();

    annotationsToAdd = _annotationsToAdd;
    annotationIdsToRemove = _annotationIdsToRemove;
    annotationsToChange = _annotationsToChange;
  }

  late Set<Annotation> annotationsToAdd;
  late Set<AnnotationId> annotationIdsToRemove;
  late Set<Annotation> annotationsToChange;

  Map<String, dynamic> _toMap() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('annotationsToAdd', _serializeAnnotationSet(annotationsToAdd));
    addIfNonNull(
        'annotationsToChange', _serializeAnnotationSet(annotationsToChange));
    addIfNonNull(
        'annotationIdsToRemove',
        annotationIdsToRemove
            .map<dynamic>((AnnotationId m) => m.value)
            .toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _AnnotationUpdates) return false;
    final _AnnotationUpdates typedOther = other;
    return setEquals(annotationsToAdd, typedOther.annotationsToAdd) &&
        setEquals(annotationIdsToRemove, typedOther.annotationIdsToRemove) &&
        setEquals(annotationsToChange, typedOther.annotationsToChange);
  }

  @override
  int get hashCode =>
      hashValues(annotationsToAdd, annotationIdsToRemove, annotationsToChange);

  @override
  String toString() {
    return '_AnnotationUpdates{annotationsToAdd: $annotationsToAdd, '
        'annotationIdsToRemove: $annotationIdsToRemove, '
        'annotationsToChange: $annotationsToChange}';
  }
}
