

#include "VoiceActivityDetector.h"

#import "RNWebrtcVad.h"
#import "AudioInputController.h"

@implementation RNWebrtcVad {
    VoiceActivityDetector *voiceDetector;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(start:(NSDictionary *)options) {
    NSLog(@"[WebRTCVad] starting = %@", options);
    AudioInputController *inputController = [AudioInputController sharedInstance];
    [inputController prepareWithSampleRate:32000];
    [inputController start];
    voiceDetector = [[VoiceActivityDetector alloc] init];
}

RCT_EXPORT_METHOD(stop) {
    NSLog(@"[WebRTCVad] stopping");
    [[AudioInputController sharedInstance] stop];
    voiceDetector = nil;
    self.audioData = nil;
}

RCT_EXPORT_METHOD(testMethod:(NSDictionary *)options) {
    NSLog(@"[WebRTCVad] options = %@", options);
}

// Needed?
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

-(instancetype)init {
    if (self = [super init]) {
      [AudioInputController sharedInstance].delegate = self;
     self.audioData = [[NSMutableData alloc] init];
    }

    return self;
}

- (void)dealloc {
    voiceDetector = nil;
    self.audioData = nil;
}

- (void) processSampleData:(NSData *)data
{
  [self.audioData appendData:data];
  NSInteger frameCount = [data length] / 2;
  int16_t *samples = (int16_t *) [data bytes];
  int64_t sum = 0;
  for (int i = 0; i < frameCount; i++) {
    sum += abs(samples[i]);
  }
  NSLog(@"audio %d %d", (int) frameCount, (int) (sum * 1.0 / frameCount));
    double sampleRate = [AudioInputController sharedInstance].audioSampleRate;

  // We recommend sending samples in 20ms (!0ms, 20, 30ms) chunks supported
  int chunk_size = 0.02 /* seconds/chunk */ * sampleRate * 2 /* bytes/sample */ ; /* bytes/chunk */
  NSLog(@"Session sample rate %f", sampleRate);

  if ([self.audioData length] > chunk_size) {
    NSLog(@"SENDING = %f", [self.audioData length]);
      const int16_t* audioSample = (const int16_t*) [self.audioData bytes];
   int isVoice = [voiceDetector isVoice:audioSample sample_rate:sampleRate length:chunk_size/2];
   NSLog(@"Processed %d", isVoice);
    self.audioData = [[NSMutableData alloc] init];
  }
}

@end

