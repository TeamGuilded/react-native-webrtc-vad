# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.

cmake_minimum_required(VERSION 3.4.1)

# Specifies a library name, specifies whether the library is STATIC or
# SHARED, and provides relative paths to the source code. You can
# define multiple libraries by adding multiple add_library() commands,
# and CMake builds them for you. When you build your app, Gradle
# automatically packages shared libraries with your APK.


file(GLOB webrtc_vad_sources
        "../webrtc/*.c"
        "../webrtc/common_audio/*/*.c"
        )

add_library( # Specifies the name of the library.
        voice-activity-detector

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        src/main/cpp/VoiceActivityDetector.cpp
        src/main/cpp/VoiceActivityDetector.extern.cpp
        )

add_library( # Specifies the name of the library.
        webrtc-vad

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ${webrtc_vad_sources}
        )

include_directories(../)
include_directories(../webrtc/common_audio/vad/include/)
include_directories(../webrtc/common_audio/signal_processing/include/)


# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
        voice-activity-detector
        webrtc-vad)

