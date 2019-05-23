

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

    // If not specified, will match HW sample, which could be too high.
    // Ex: Most devices run at 48000,41000 (or 48kHz/44.1hHz). So cap at highest vad supported sample rate supported
    // See: https://github.com/TeamGuilded/react-native-webrtc-vad/blob/master/webrtc/common_audio/vad/include/webrtc_vad.h#L75
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

  double sampleRate = [AudioInputController sharedInstance].audioSampleRate;

  // Google recommends sending samples (in 10ms, 20, or 30ms) chunk.
  // See: https://github.com/TeamGuilded/react-native-webrtc-vad/blob/master/webrtc/common_audio/vad/include/webrtc_vad.h#L75

  int chunk_size = 0.02 /* seconds/chunk */ * sampleRate * 2 /* bytes/sample */ ; /* bytes/chunk */

  if ([self.audioData length] > chunk_size) {
  #ifdef DEBUG
    NSLog(@"SENDING = %u", [self.audioData length]);
  #endif

  const int16_t* audioSample = (const int16_t*) [self.audioData bytes];

   int isVoice = [voiceDetector isVoice:audioSample sample_rate:sampleRate length:chunk_size/2];

  #ifdef DEBUG
    NSLog(@"Detected Voice %d", isVoice);
  #endif

   // Clear buffer
    [self.audioData setLength:0];
  }
}

@end

