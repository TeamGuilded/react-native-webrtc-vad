//
//  vad.m
//  webrtcvad
//
//  Created by Peiqiang Hao on 16/9/17.
//  Copyright © 2016年 Peiqiang Hao. All rights reserved.
//

#import "VoiceActivityDetector.h"
#include "webrtc/common_audio/vad/include/webrtc_vad.h"

@implementation VoiceActivityDetector {
    VadInst *vad;
}

-(instancetype)init {

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

-(int)isVoice:(const int16_t*)audio_frame sample_rate:(int)fs length:(int) frame_length {

    // VadInst *vad;
    // WebRtcVad_Create(&vad);
    // WebRtcVad_Init(vad);
    // WebRtcVad_set_mode(vad, 0);

    int voice = WebRtcVad_Process(vad,fs,audio_frame,frame_length);
    // WebRtcVad_Free(vad);
    NSLog(@"Voice detection res: %d", voice);
    return voice;
}
@end
