## 1.0.0

Tanks to @jonbhanson
* Adds null safety.
* Refreshes the example app.
* Updates .gitignore and removes files that should not be tracked.

## 0.1.4

* Animate to bounds was added. (Thanks to @nghiashiyi)
* Fixed an issue where the user location was only displayed in `authorizationInUse` status. (Thanks to @zgosalvez)

* minor fixes

## 0.1.3

* Thanks to @maxiundtesa the getter for the current zoomLevel was added
* iOS build failure for Flutter modules was fixed

## 0.1.2+5

* Fixed build failure
* Added anchor param to Annotation
* Added missing comparison of Overlay coordinates, which caused
  Circles, Annotations, Polylines and Ploygons to not update correctly
  on coordinate changes.

## 0.1.2+4

* Added configurable Anchor for infoWindows

## 0.1.2+3

* Fixed the offset of custom markers

## 0.1.2+2

* Fixed the onTap event for Annotation Callouts

## 0.1.2+1

* Added custom annotation icons from byte data
* Fixed scaling of icons from assets => see: https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets

## 0.1.2

* Annotation rework:
   * onTap for InfoWindow added
   * Multiline InfoWindow subtitle support
   * Overall Annotation handling refactored
   * Correct UserTracking Button added

## 0.1.1+2

* Fixed map freezing when setState is being called

## 0.1.1+1

* Fixed Polygon and Circle Tap events.

## 0.1.1

* Added markerAnnotation as selectable annotation type.

## 0.1.0

* Added ability to place circles on the map.

## 0.0.7

* Added ability to place polygons on the map.

## 0.0.6+4

* Fixed build issues

## 0.0.6+3

* Fixes issue #6, location permission is only requested if it's actually used.

## 0.0.6+2

* Converted iOS code to swift 5.

## 0.0.6+1

* Changed annotation initialisation, fixes custom annotation icons not showing up on the map.

## 0.0.6

* Added ability to add padding to the map

## 0.0.5

* Added ability to place polylines.

## 0.0.4

* Fixed error when updating Annotations on map.

## 0.0.3

* Added getter for visible map region.

## 0.0.2

* Added zoomBy functionality.
* Added setter for min and max zoom levels.

## 0.0.1

* Initial release.
