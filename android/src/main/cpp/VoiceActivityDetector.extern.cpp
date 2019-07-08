#include "VoiceActivityDetector.h"
#include <jni.h>
#include <string>

VoiceActivityDetector* vad;

void initialize(){
  vad = new VoiceActivityDetector();
}

void stop(){
 delete vad;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_guilded_gg_VoiceActivityDetector_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

extern "C" JNIEXPORT jsboolean JNICALL
Java_com_guilded_gg_VoiceActivityDetector_isVoice(
        JNIEnv* env,
        jobject /* this */) {
    return true;
}


