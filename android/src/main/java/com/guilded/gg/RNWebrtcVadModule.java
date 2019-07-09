
package com.guilded.gg;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.soloader.SoLoader;

import java.nio.ByteBuffer;

public class RNWebrtcVadModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public RNWebrtcVadModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    static {
        SoLoader.loadLibrary("voice-activity-detector");
        Log.d("AUDIOTAG", "static initializer: " + RNWebrtcVadModule.stringFromJNI());
    }

    private static native String stringFromJNI();
    private static native void initializeVad();
    public static native void stopVad();


    @Override
    public String getName() {
        return "RNWebrtcVad";
    }

    @ReactMethod
    public void start() {
        Log.d("AUDIOTAG", "starting: ");

        RNWebrtcVadModule.initializeVad();
        AudioInputController inputController = AudioInputController.getInstance();

        inputController.setAudioInputControllerListener(new AudioInputController.AudioInputControllerListener() {
            @Override
            public void onProcessSampleData(ByteBuffer data) {
                // Code to handle object ready
                Log.d("AUDIOTAG", "SAMPLES: " + data.limit());
            }
        });

        // If not specified, will match HW sample, which could be too high.
        // Ex: Most devices run at 48000,41000 (or 48kHz/44.1hHz). So cap at highest vad supported sample rate supported
        // See: https://github.com/TeamGuilded/react-native-webrtc-vad/blob/master/webrtc/common_audio/vad/include/webrtc_vad.h#L75
        inputController.prepareWithSampleRate(32000);
        inputController.start();

    }

    @ReactMethod
    public void stop() {
        Log.d("AUDIOTAG", "stopping: ");

        RNWebrtcVadModule.stopVad();
        AudioInputController inputController = AudioInputController.getInstance();
        inputController.stop();
        inputController.setAudioInputControllerListener(null);
    }

}