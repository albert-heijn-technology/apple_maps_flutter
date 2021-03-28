// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

dynamic _offsetToJson(Offset? offset) {
  if (offset == null) {
    return null;
  }
  return <dynamic>[offset.dx, offset.dy];
}

/// Text labels for a [Annotation] info window.
class InfoWindow {
  const InfoWindow({
    this.title,
    this.snippet,
    this.anchor = const Offset(0.5, 0.0),
    this.onTap,
  });

  /// Text labels specifying that no text is to be displayed.
  static const InfoWindow noText = InfoWindow();

  /// Text displayed in an info window when the user taps the annotation.
  ///
  /// A null value means no title.
  final String? title;

  /// Additional text displayed below the [title].
  ///
  /// A null value means no additional text.
  final String? snippet;

  /// The icon image point that will be the anchor of the info window when
  /// displayed.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// onTap callback for this [InfoWindow].
  final VoidCallback? onTap;

  /// Creates a new [InfoWindow] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  InfoWindow copyWith({
    String? titleParam,
    String? snippetParam,
    Offset? anchorParam,
    VoidCallback? onTapParam,
  }) {
    return InfoWindow(
      title: titleParam ?? title,
      snippet: snippetParam ?? snippet,
      anchor: anchorParam ?? anchor,
      onTap: onTapParam ?? onTap,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('title', title);
    addIfPresent('snippet', snippet);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('consumesTapEvents', onTap != null);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InfoWindow) return false;
    final InfoWindow typedOther = other;
    return title == typedOther.title &&
        snippet == typedOther.snippet &&
        anchor == typedOther.anchor &&
        onTap == typedOther.onTap;
  }

  @override
  int get hashCode => hashValues(title.hashCode, snippet, anchor);

  @override
  String toString() {
    return 'InfoWindow{title: $title, snippet: $snippet, anchor: $anchor, consumesTapEvents: ${onTap != null}}';
  }
}

/// Uniquely identifies a [Annotation] among [AppleMap] annotations.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class AnnotationId {
  AnnotationId(this.value);

  /// value of the [AnnotationId].
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnnotationId) return false;
    final AnnotationId typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'AnnotationId{value: $value}';
  }
}

/// Marks a geographical location on the map.
///
/// A annotation icon is drawn oriented against the device's screen rather than
/// the map's surface; that is, it will not necessarily change orientation
/// due to map rotations, tilting, or zooming.
@immutable
class Annotation {
  /// Creates a set of annotation configuration options.
  ///
  /// Default annotation options.
  ///
  /// Specifies a annotation that
  /// * is fully opaque; [alpha] is 1.0
  /// * has default tap handling; [consumeTapEvents] is false
  /// * is stationary; [draggable] is false
  /// * has a default icon; [icon] is default Pin Annotation
  /// * has no info window text; [infoWindowText] is `InfoWindowText.noText`
  /// * is positioned at 0, 0; [position] is `LatLng(0.0, 0.0)`
  /// * is visible; [visible] is true
  const Annotation({
    required this.annotationId,
    this.alpha = 1.0,
    this.anchor = const Offset(0.5, 1.0),
    this.draggable = false,
    this.icon = BitmapDescriptor.defaultAnnotation,
    this.infoWindow = InfoWindow.noText,
    this.position = const LatLng(0.0, 0.0),
    this.onTap,
    this.visible = true,
    this.onDragEnd,
  }) : assert(0.0 <= alpha && alpha <= 1.0);

  /// Uniquely identifies a [Annotation].
  final AnnotationId annotationId;

  /// The opacity of the annotation, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// True if the annotation is draggable by user touch events.
  final bool draggable;

  /// A description of the bitmap used to draw the annotation icon.
  final BitmapDescriptor icon;

  /// An Apple Maps InfoWindow.
  ///
  /// The window is displayed when the annotation is tapped.
  final InfoWindow infoWindow;

  /// Geographical location of the annotation.
  final LatLng position;

  /// Callbacks to receive tap events for annotations placed on this map.
  final VoidCallback? onTap;

  /// True if the annotation is visible.
  final bool visible;

  final ValueChanged<LatLng>? onDragEnd;

  /// Creates a new [Annotation] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Annotation copyWith({
    double? alphaParam,
    Offset? anchorParam,
    bool? consumeTapEventsParam,
    bool? draggableParam,
    BitmapDescriptor? iconParam,
    InfoWindow? infoWindowParam,
    LatLng? positionParam,
    bool? visibleParam,
    VoidCallback? onTapParam,
    ValueChanged<LatLng>? onDragEndParam,
  }) {
    return Annotation(
      annotationId: annotationId,
      anchor: anchorParam ?? anchor,
      alpha: alphaParam ?? alpha,
      draggable: draggableParam ?? draggable,
      icon: iconParam ?? icon,
      infoWindow: infoWindowParam ?? infoWindow,
      position: positionParam ?? position,
      onTap: onTapParam ?? onTap,
      visible: visibleParam ?? visible,
      onDragEnd: onDragEndParam ?? onDragEnd,
    );
  }

  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('annotationId', annotationId.value);
    addIfPresent('alpha', alpha);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('draggable', draggable);
    addIfPresent('icon', icon._toJson());
    addIfPresent('infoWindow', infoWindow._toJson());
    addIfPresent('visible', visible);
    addIfPresent('position', position._toJson());
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Annotation) return false;
    final Annotation typedOther = other;
    return annotationId == typedOther.annotationId;
  }

  @override
  int get hashCode => annotationId.hashCode;

  @override
  String toString() {
    return 'Annotation{annotationId: $annotationId, alpha: $alpha, draggable: $draggable,'
        'icon: $icon, infoWindow: $infoWindow, position: $position ,visible: $visible, onTap: $onTap}';
  }
}

Map<AnnotationId, Annotation> _keyByAnnotationId(
    Iterable<Annotation>? annotations) {
  if (annotations == null) {
    return <AnnotationId, Annotation>{};
  }
  return Map<AnnotationId, Annotation>.fromEntries(annotations.map(
      (Annotation annotation) => MapEntry<AnnotationId, Annotation>(
          annotation.annotationId, annotation)));
}

List<Map<String, dynamic>>? _serializeAnnotationSet(
    Set<Annotation>? annotations) {
  if (annotations == null) {
    return null;
  }
  return annotations
      .map<Map<String, dynamic>>((Annotation m) => m._toJson())
      .toList();
}
