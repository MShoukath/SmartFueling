//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_google_places_sdk_ios/SwiftFlutterGooglePlacesSdkIosPlugin.h>)
#import <flutter_google_places_sdk_ios/SwiftFlutterGooglePlacesSdkIosPlugin.h>
#else
@import flutter_google_places_sdk_ios;
#endif

#if __has_include(<google_maps_flutter_ios/FLTGoogleMapsPlugin.h>)
#import <google_maps_flutter_ios/FLTGoogleMapsPlugin.h>
#else
@import google_maps_flutter_ios;
#endif

#if __has_include(<location/LocationPlugin.h>)
#import <location/LocationPlugin.h>
#else
@import location;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [SwiftFlutterGooglePlacesSdkIosPlugin registerWithRegistrar:[registry registrarForPlugin:@"SwiftFlutterGooglePlacesSdkIosPlugin"]];
  [FLTGoogleMapsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMapsPlugin"]];
  [LocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPlugin"]];
}

@end
