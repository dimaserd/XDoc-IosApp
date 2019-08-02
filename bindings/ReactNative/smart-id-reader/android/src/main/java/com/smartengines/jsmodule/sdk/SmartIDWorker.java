package com.smartengines.jsmodule.sdk;

import android.util.Log;
import java.util.concurrent.Semaphore;

interface SmartIDVideoProcessingCallback {
    void workerDidOutputBuffer(byte[] buffer);
}

interface SmartIDVideoProcessingCallbackExtended extends SmartIDVideoProcessingCallback {
    void workerDidStart();
    void workerDidFailedWithMessage(String message);
    void workerDidStop();
}


public class SmartIDWorker {
    private Semaphore frame_waiting;
    private Semaphore frame_ready;
    private boolean processing;
    private volatile SmartIDVideoProcessingCallback listener;
    private VideoProcessingThread videoThread;


    private volatile byte[] buffer = null;

    public SmartIDWorker() {
        videoThread = new VideoProcessingThread();
        videoThread.setName("smartid_video");
    }

    public void setListener(SmartIDVideoProcessingCallback listener) {
        this.listener = listener;
    }

    public void start() {
        this.frame_waiting = new Semaphore(1, true);  // create semaphores
        this.frame_ready = new Semaphore(0, true);
        this.processing = true;
        videoThread.start();
    }

    public void PushBuffer(final byte[] buffer) {
        if (frame_waiting.tryAcquire() && processing) {
            this.buffer = buffer;
            this.frame_ready.release();
        }
    }

    public void stop() {
        if (processing) {
            processing = false;
            buffer = null;

            frame_waiting.release();  // release semaphores
            frame_ready.release();
            if (listener.getClass() == SmartIDVideoProcessingCallbackExtended.class) {
                ((SmartIDVideoProcessingCallbackExtended) listener).workerDidStop();
            }
        }
    }

    public class VideoProcessingThread extends Thread {

        @Override
        public void run() {
            if (listener.getClass() == SmartIDVideoProcessingCallbackExtended.class) {
                ((SmartIDVideoProcessingCallbackExtended) listener).workerDidStart();
            }
            while (processing) {
                try {
                    frame_ready.acquire();
                    if (listener != null) {
                        Log.e("SMARTID", "didOutput on " + Thread.currentThread().getName());
                        listener.workerDidOutputBuffer(buffer);
                    }
                    frame_waiting.release();
                } catch (Exception e) {
                    if (listener.getClass() == SmartIDVideoProcessingCallbackExtended.class) {
                        ((SmartIDVideoProcessingCallbackExtended) listener).workerDidFailedWithMessage(e.toString());
                    }
                }
            }
        }
    }
}
