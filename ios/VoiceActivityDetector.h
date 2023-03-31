#ifndef WEBRTCVAD__VOICE_ACITIVITY_DETECTOR_H_
#define WEBRTCVAD__VOICE_ACITIVITY_DETECTOR_H_

typedef struct WebRtcVadInst VadInst;

#import <Foundation/Foundation.h>

extern const int DEFAULT_VAD_MODE;

@interface VoiceActivityDetector : NSObject

-(instancetype)initWithMode: (int)mode;
-(instancetype)init;

-(int)isVoice:(const int16_t*)audio_frame sample_rate:(int)fs length:(int) frame_length;
@end

#endif  // WEBRTCVAD__VOICE_ACITIVITY_DETECTOR_H_
