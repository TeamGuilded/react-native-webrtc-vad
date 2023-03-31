#ifndef ANDROID_VOICEACTIVITYDETECTOR_H
#define ANDROID_VOICEACTIVITYDETECTOR_H


#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct WebRtcVadInst VadInst;

class VoiceActivityDetector {
private:
    VadInst *vad;
public:
    bool isVoice(const int16_t* audio_frame, int sample_rate, int frame_length);

    VoiceActivityDetector(int mode);

    ~VoiceActivityDetector();

};


#ifdef __cplusplus
}
#endif

#endif //ANDROID_VOICEACTIVITYDETECTOR_H
