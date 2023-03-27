#include "webrtc/common_audio/vad/include/webrtc_vad.h"
#import "VoiceActivityDetector.h"

const int DEFAULT_VAD_MODE = 0;

@implementation VoiceActivityDetector {
    VadInst *vad;
}

- (instancetype)initWithMode: (int)mode {
    self = [super init];
    if(self) {
        WebRtcVad_Create(&vad);
        WebRtcVad_Init(vad);
        WebRtcVad_set_mode(vad, mode);
    }
    return self;
}

- (instancetype)init {
    return [self initWithMode:DEFAULT_VAD_MODE];
}

- (void)dealloc {
    WebRtcVad_Free(vad);
}

- (int)isVoice:(const int16_t*)audio_frame sample_rate:(int)fs length:(int) frame_length {
    int voice = WebRtcVad_Process(vad,fs,audio_frame,frame_length);
    return voice;
}
@end
