
package com.guilded.gg;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicBoolean;

public class AudioInputController {
    public interface AudioInputControllerListener {
        void onProcessSampleData(ByteBuffer buffer);
    }

    public static final int AudioChannelConfig =  AudioFormat.CHANNEL_IN_MONO;
    public static final int AudioSampleFormat =  AudioFormat.ENCODING_PCM_16BIT;


    private AudioInputControllerListener listener;

    private AudioRecord recorder = null;
    private Thread recordingThread = null;
    private final AtomicBoolean recordingInProgress = new AtomicBoolean(false);

    private int audioSampleRate;
    private int bufferSize;

    private AudioInputController() {
    }

    private static class AudioInputControllerSingleton {
        private static final AudioInputController sharedInstance = new AudioInputController();
    }

    public static AudioInputController getInstance() {
        return AudioInputControllerSingleton.sharedInstance;
    }

    public double sampleRate() {
        return this.audioSampleRate;
    }

    public void start() {
        recorder = new AudioRecord(MediaRecorder.AudioSource.DEFAULT, this.audioSampleRate,
                AudioInputController.AudioChannelConfig, AudioInputController.AudioSampleFormat, this.bufferSize);

        recorder.startRecording();
        recordingInProgress.set(true);

        recordingThread = new Thread(new RecordingRunnable(this.bufferSize, this.listener), "Voice detector thread");
        recordingThread.start();

    }


    public void stop() {
        if (this.recorder != null) {
            this.recorder.stop();
            this.recorder.release();
            this.recorder = null;
            this.recordingThread = null;
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

        this.audioSampleRate = sampleRate;


        this.bufferSize = AudioRecord.getMinBufferSize(this.audioSampleRate,
                AudioChannelConfig, AudioSampleFormat);
    }


    private class RecordingRunnable implements Runnable {
        private final int bufferSize;
        private final AudioInputControllerListener listener;
        public RecordingRunnable(int bufferSize, AudioInputControllerListener listener) {
            this.bufferSize = bufferSize;
            this.listener = listener;
        }

        @Override
        public void run() {
            final ByteBuffer buffer = ByteBuffer.allocateDirect(this.bufferSize);

                while (recordingInProgress.get()) {
                    int result = recorder.read(buffer, this.bufferSize);
                    if (result < 0) {
                        throw new RuntimeException("Reading of audio buffer failed: " +
                                getBufferReadFailureReason(result));
                    }

                    if (this.listener != null)
                        // copy data?
                        this.listener.onProcessSampleData(buffer);
                }
                buffer.clear();
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
