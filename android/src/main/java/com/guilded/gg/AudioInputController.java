
package com.guilded.gg;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class AudioInputController {
    public interface AudioInputControllerListener {
        public void onProcessSampleData(ByteBuffer buffer);
    }

    private static final int ChannelConfig = AudioFormat.CHANNEL_IN_MONO;
    private static final int AudioFormat = AudioFormat.ENCODING_PCM_16BIT;
    private static final AudioInputController sharedInstance = null;

    private AudioInputControllerListener listener;

    private AudioRecord recorder = null;
    private Thread recordingThread = null;
    private final AtomicBoolean recordingInProgress = new AtomicBoolean(false);

    private double audioSampleRate;
    private int bufferSize;

    private AudioInputController() {

    }

    public synchronized static AudioInputController getInstance() {
        if (sharedInstance == null) {
            sharedInstance = new ClassSingleton();
        }
        return sharedInstance;
    }

    public double sampleRate() {
        return this.audioSampleRate;
    }

    public start() {
        recorder = new AudioRecord(MediaRecorder.AudioSource.DEFAULT, this.audioSampleRate,
                ChannelConfig, AudioFormat, this.bufferSize);

        recorder.startRecording();
        recordingInProgress.set(true);

        recordingThread = new Thread(new RecordingRunnable(), "Voice detector thread");
        recordingThread.start();

    }


    public stop() {
        if (recorder) {
            recorder.stop();
            recorder.release();
            recorder = null;
            recordingThread = null;
        }
    }

    // Assign the listener implementing events interface that will receive the events
    public void setAudioInputControllerListener(AudioInputControllerListener listener) {
        this.listener = listener;
    }

    private prepareWithSampleRate(desiredSampleRate) {
        this.audioSampleRate = desiredSampleRate || 44100;
        this.bufferSize = AudioRecord.getMinBufferSize(this.audioSampleRate,
                ChannelConfig, AudioFormat);
    }


    private class RecordingRunnable implements Runnable {

        @Override
        public void run() {
            final ByteBuffer buffer = ByteBuffer.allocateDirect(BUFFER_SIZE);

            try {
                while (recordingInProgress.get()) {
                    int result = recorder.read(buffer, BUFFER_SIZE);
                    if (result < 0) {
                        throw new RuntimeException("Reading of audio buffer failed: " +
                                getBufferReadFailureReason(result));
                    }

                    if (this.listener != null)
                        // copy data?
                        this.listener.onProcessSampleData(data);
                }
                buffer.clear();
            }
        } catch(
        IOException e)

        {
            throw new RuntimeException("Writing of recorded audio failed", e);
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
