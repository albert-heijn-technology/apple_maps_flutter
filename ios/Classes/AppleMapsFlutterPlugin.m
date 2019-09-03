#import "AppleMapsFlutterPlugin.h"
#import <apple_maps_flutter/apple_maps_flutter-Swift.h>

@implementation AppleMapsFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppleMapsFlutterPlugin registerWithRegistrar:registrar];
}
@end
