
#if __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#else
#import <React/RCTEventEmitter.h>
#endif

#import <Foundation/Foundation.h>
#import "AudioInputController.h"

@interface RNWebrtcVad : RCTEventEmitter <RCTBridgeModule, AudioInputControllerDelegate>
@property (nonatomic, strong) NSMutableData *audioData;
@end
