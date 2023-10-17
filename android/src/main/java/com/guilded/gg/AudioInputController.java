
package com.guilded.gg;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.concurrent.atomic.AtomicBoolean;

public class AudioInputController {
    public interface AudioInputControllerListener {
        void onProcessSampleData(ByteBuffer buffer);
        void onProcessingError(String error);
    }

    public static final int AudioChannelConfig = AudioFormat.CHANNEL_IN_MONO;
    public static final int AudioSampleFormat = AudioFormat.ENCODING_PCM_8BIT;


    private AudioInputControllerListener listener;

    private AudioRecord recorder = null;
    private Thread recordingThread = null;
    private final AtomicBoolean recordingInProgress = new AtomicBoolean(false);

    private int sampleRate;
    private int bufferSize;

    private AudioInputController() {
    }

    private static class AudioInputControllerSingleton {
        private static final AudioInputController sharedInstance = new AudioInputController();
    }

    public static AudioInputController getInstance() {
        return AudioInputControllerSingleton.sharedInstance;
    }

    public int sampleRate() {
        return this.sampleRate;
    }

    public int bufferSize() {
        return this.bufferSize;
    }

    public void start() {
        recorder = new AudioRecord(MediaRecorder.AudioSource.DEFAULT, sampleRate,
                AudioInputController.AudioChannelConfig, AudioInputController.AudioSampleFormat, bufferSize);

        recorder.startRecording();
        recordingInProgress.set(true);

        recordingThread = new Thread(new RecordingRunnable(this), "Voice detector thread");
        recordingThread.start();

    }


    public void stop() {
        if (recorder != null) {
            recordingInProgress.set(false);
            recorder.release();
            recorder = null;
            recordingThread = null;
        }
    }

    // Assign the listener implementing events interface that will receive the events
    public void setAudioInputControllerListener(AudioInputControllerListener listener) {
        this.listener = listener;
    }

    public void prepareWithSampleRate(int desiredSampleRate) {
        int sampleRate = 44100; // default sample rate: supported on most android devices

        if (desiredSampleRate > 0) {
            sampleRate = desiredSampleRate;
        }

        this.sampleRate = sampleRate;


        bufferSize = AudioRecord.getMinBufferSize(sampleRate,
                AudioChannelConfig, AudioSampleFormat);
    }


    private class RecordingRunnable implements Runnable {
        private final AudioInputController inputController;

        public RecordingRunnable(AudioInputController inputController) {
            this.inputController = inputController;
        }

        @Override
        public void run() {
            final ByteBuffer buffer = ByteBuffer.allocateDirect(inputController.bufferSize);
            buffer.order(ByteOrder.nativeOrder());

            while (recordingInProgress.get()) {
                int result = recorder.read(buffer, inputController.bufferSize);
                if (result < 0) {
                    String error = "Reading of audio buffer failed: " +
                            getBufferReadFailureReason(result);
                    if (inputController.listener != null)
                        inputController.listener.onProcessingError(error);
                    return;
                }

                if (inputController.listener != null)
                    inputController.listener.onProcessSampleData(buffer);
            }
        }

    }

    private String getBufferReadFailureReason(int errorCode) {
        switch (errorCode) {
            case AudioRecord.ERROR_INVALID_OPERATION:
                return "ERROR_INVALID_OPERATION";
            case AudioRecord.ERROR_BAD_VALUE:
                return "ERROR_BAD_VALUE";
            case AudioRecord.ERROR_DEAD_OBJECT:
                return "ERROR_DEAD_OBJECT";
            case AudioRecord.ERROR:
                return "ERROR";
            default:
                return "Unknown (" + errorCode + ")";
        }
    }
}
