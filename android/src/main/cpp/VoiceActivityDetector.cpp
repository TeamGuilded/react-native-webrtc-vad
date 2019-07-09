#include "VoiceActivityDetector.h"
#include "webrtc_vad.h"

VoiceActivityDetector::VoiceActivityDetector(){
    WebRtcVad_Create(&this->vad);
    WebRtcVad_Init(this->vad);
    WebRtcVad_set_mode(this->vad, 0);
}

VoiceActivityDetector::~VoiceActivityDetector(){
   WebRtcVad_Free(this->vad);
}

bool VoiceActivityDetector::isVoice(const int16_t* audio_frame, int sample_rate, int frame_length){
   int voice = WebRtcVad_Process(this->vad,sample_rate,audio_frame,frame_length);
    return (bool)voice;
}

