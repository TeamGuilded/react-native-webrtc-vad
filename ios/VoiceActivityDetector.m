#include "webrtc/common_audio/vad/include/webrtc_vad.h"
#import "VoiceActivityDetector.h"

@implementation VoiceActivityDetector {
    VadInst *vad;
}

- (instancetype)init {

    self = [super init];
    if(self) {
        WebRtcVad_Create(&vad);
        WebRtcVad_Init(vad);
        WebRtcVad_set_mode(vad, 0);
    }
    return self;
}

- (void)dealloc {
    WebRtcVad_Free(vad);
}

- (int)isVoice:(const int16_t*)audio_frame sample_rate:(int)fs length:(int) frame_length {
    int voice = WebRtcVad_Process(vad,fs,audio_frame,frame_length);
    return voice;
}
@end
