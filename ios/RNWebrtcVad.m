
#import "RNWebrtcVad.h"
#include "../webrtcvad/WVVad.h"

@implementation RNWebrtcVad

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(testMethod:(NSDictionary *)options)
{
    NSLog(@"[WebRTCVad][test] options = %@", options);
}

@end

