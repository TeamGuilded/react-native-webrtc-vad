
package com.guilded.gg;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNWebrtcVadModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private MyCustomObjectListener listener;

    public RNWebrtcVadModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNWebrtcVad";
    }

    @ReactMethod
    public start() {
        AudioInputController inputController = AudioInputController.getInstance();

        inputController.setAudioInputControllerListener(new AudioInputController.AudioInputControllerListener() {
            @Override
            public void onProcessSampleData(ByteBuffer data) {
                // Code to handle object ready
            }
        });

        // If not specified, will match HW sample, which could be too high.
        // Ex: Most devices run at 48000,41000 (or 48kHz/44.1hHz). So cap at highest vad supported sample rate supported
        // See: https://github.com/TeamGuilded/react-native-webrtc-vad/blob/master/webrtc/common_audio/vad/include/webrtc_vad.h#L75
        inputController.prepareWithAudioSampleRate(32000);
        inputController.start();

    }

    @ReactMethod
    public stop() {
        AudioInputController inputController = AudioInputController.getInstance();
        inputController.setAudioInputControllerListener(null);
        inputController.stop();
    }

}