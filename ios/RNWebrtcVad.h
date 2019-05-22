
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <Foundation/Foundation.h>

@protocol RNWebrtcVadDelegate <NSObject>
- (void) processSampleData:(NSData *) data;
@end

@interface RNWebrtcVad : NSObject <RCTBridgeModule>
  @property (nonatomic, weak) id<RNWebrtcVadDelegate> delegate;

  + (OSStatus) CheckError;
  - (OSStatus) _prepareWithSampleRate:(double)desiredSampleRate;
  - (OSStatus) _start;
  - (OSStatus) _stop;
@end