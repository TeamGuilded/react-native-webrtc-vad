
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <Foundation/Foundation.h>
#import "AudioInputController.h"

@interface RNWebrtcVad : NSObject <RCTBridgeModule, AudioInputControllerDelegate>
  @property (nonatomic, strong) NSMutableData *audioData;
@end
