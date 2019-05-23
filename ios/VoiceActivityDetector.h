#ifndef WEBRTCVAD__VOICE_ACITIVITY_DETECTOR_H_
#define WEBRTCVAD__VOICE_ACITIVITY_DETECTOR_H_

typedef struct WebRtcVadInst VadInst;

#import <Foundation/Foundation.h>

@interface VoiceActivityDetector : NSObject

-(int)isVoice:(const int16_t*)audio_frame sample_rate:(int)fs length:(int) frame_length;
@end

#endif  // WEBRTCVAD__VOICE_ACITIVITY_DETECTOR_H_
