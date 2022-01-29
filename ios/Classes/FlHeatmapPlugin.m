#import "FlHeatmapPlugin.h"
#if __has_include(<fl_heatmap/fl_heatmap-Swift.h>)
#import <fl_heatmap/fl_heatmap-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fl_heatmap-Swift.h"
#endif

@implementation FlHeatmapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlHeatmapPlugin registerWithRegistrar:registrar];
}
@end
