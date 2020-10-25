# apple_maps_flutter

A Flutter plugin that provides an Apple Maps widget.

The plugin relies on Flutter's mechanism for embedding Android and iOS views. As that mechanism is currently in a developers preview, this plugin should also be considered a developers preview.

This plugin was based on the `google_maps_flutter` plugin. Instead of reinventing the wheel it also uses the Flutter implementation of the `google_maps_flutter` plugin. This was also done to simplify the process of combining the `google_maps_flutter` plugin with `apple_maps_flutter` to create a cross platform implementation for Android/iOS called `flutter_platform_maps`.

# Screenshots

|                                     Example 1                                     |                                     Example 2                                     |
| :-------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------: |
| ![Example 1](https://luisthein.de/apple-maps-plugin-images/example_img01-min.png) | ![Example 2](https://luisthein.de/apple-maps-plugin-images/example_img02-min.png) |

# iOS

To use this plugin on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's Info.plist file, with the key `io.flutter.embedded_views_preview` and the value `YES`. You will also have to add the key `Privacy - Location When In Use Usage Description` with the value of your usage description.

# Android

There is no Android implementation, but there is a package combining apple_maps_flutter and the google_maps_flutter plugin to have the typical map implementations for Android/iOS called platform_maps_flutter.

## Sample Usage

```dart
class AppleMapsExample extends StatelessWidget {
  AppleMapController mapController;

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

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
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          heading: 270.0,
                          target: LatLng(51.5160895, -0.1294527),
                          pitch: 30.0,
                          zoom: 17,
                        ),
                      ),
                    );
                  },
                  child: const Text('newCameraPosition'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.newLatLngZoom(
                        const LatLng(37.4231613, -122.087159),
                        11.0,
                      ),
                    );
                  },
                  child: const Text('newLatLngZoom'),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Text('zoomIn'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Text('zoomOut'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomTo(16.0),
                    );
                  },
                  child: const Text('zoomTo'),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
```

Suggestions and PR's to make this plugin better are always welcome.
