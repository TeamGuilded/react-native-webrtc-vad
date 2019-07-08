#include "../../../../webrtc/common_audio/vad/include/webrtc_vad.h"
#include "VoiceActivityDetector.h"

using namespace std;

VoiceActivityDetector::VoiceActivityDetector(){
    WebRtcVad_Create(&vad);
    WebRtcVad_Init(vad);
    WebRtcVad_set_mode(vad, 0);
}

~VoiceActivityDetector::VoiceActivityDetector(){
   WebRtcVad_Free(vad);
}

bool VoiceActivityDetector::isVoice(const int16_t* audio_frame, int sample_rate, int frame_lenght){
   int voice = WebRtcVad_Process(vad,fs,audio_frame,frame_length);
    return (bool)voice;
}
