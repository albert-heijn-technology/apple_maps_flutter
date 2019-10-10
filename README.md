# apple_maps_flutter

A Flutter plugin that provides an Apple Maps widget.
This plugin was based on the [google_maps_flutter]("https://pub.dev/packages/google_maps_flutter") plugin. Instead of reinventing the wheel it also uses the Flutter implementation of the [google_maps_flutter]("https://pub.dev/packages/google_maps_flutter") plugin. This was also done to simplify the process of combining the [google_maps_flutter]("https://pub.dev/packages/google_maps_flutter") plugin with apple_maps_flutter to create a cross platform implementation of typical map implementations for Android/iOS (coming soon).

# Android

There is no Android implementation, but there will be a package to combine apple_maps_flutter and the [google_maps_flutter]("https://pub.dev/packages/google_maps_flutter") plugin to have the typical map implementations for Android/iOS.

# iOS

To use this plugin on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's Info.plist file, with the key io.flutter.embedded_views_preview and the value YES. You will also have to add the key Privacy - Location When In Use Usage Description with the value of your usage description.

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
                      CameraUpdate.newLatLng(
                        const LatLng(56.1725505, 10.1850512),
                      ),
                    );
                  },
                  child: const Text('newLatLng'),
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
                      CameraUpdate.zoomBy(
                        -0.5,
                        const Offset(30.0, 20.0),
                      ),
                    );
                  },
                  child: const Text('zoomBy with focus'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomBy(-0.5),
                    );
                  },
                  child: const Text('zoomBy'),
                ),
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
