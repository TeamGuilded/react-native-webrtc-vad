#include "VoiceActivityDetector.h"
#include <jni.h>
#include <string>


extern "C" {
VoiceActivityDetector *vad = nullptr;

void initialize() {
    vad = new VoiceActivityDetector();
}

void stop() {
    delete vad;
    vad = nullptr;
}
}

extern "C" JNIEXPORT void JNICALL
Java_com_guilded_gg_RNWebrtcVadModule_initializeVad(
        JNIEnv
        *env,
        jobject /* this */) {
    initialize();

}

extern "C" JNIEXPORT void JNICALL
Java_com_guilded_gg_RNWebrtcVadModule_stopVad(
        JNIEnv
        *env,
        jobject /* this */) {
    stop();

}


extern "C" JNIEXPORT jstring

JNICALL
Java_com_guilded_gg_RNWebrtcVadModule_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

extern "C" JNIEXPORT jboolean
JNICALL
Java_com_guilded_gg_RNWebrtcVadModule_isVoice(
        JNIEnv *env,
        jobject /* this */, jshortArray
        audio_frame,
        int sampleRate,
        int frameLength
) {

    if (vad == nullptr) return jboolean(0);

    return (jboolean) vad->
            isVoice((int16_t
    *) &audio_frame, sampleRate, frameLength);
}


