#ifndef ANDROID_VOICEACTIVITYDETECTOR_H
#define ANDROID_VOICEACTIVITYDETECTOR_H

typedef struct WebRtcVadInst VadInst;

class VoiceActivityDetector {
  private:
      VadInst *vad;
  public:
      bool isVoice(const int16_t* audio_frame, int sample_rate, int frame_lenght);

};
#endif //ANDROID_VOICEACTIVITYDETECTOR_H
