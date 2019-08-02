/**
 Copyright (c) 2012-2017, Smart Engines Ltd
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of the Smart Engines Ltd nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.smartengines.jsmodule.sdk;

import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import android.view.Display;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import java.util.List;

import static android.content.Context.WINDOW_SERVICE;
import static java.lang.Math.abs;


interface SmartIDCameraListener {
    void CameraSurfaceDidCreated();
}

/**
 * Main recognition activity view
 */
class SmartIDCamera implements
        SurfaceHolder.Callback,
        Camera.AutoFocusCallback,
        Camera.PreviewCallback {

    private Context context;

    private boolean camera_opened = false;
    private Camera camera = null;
    private boolean autofocus = false;
    private static int angle = -1;

    private SurfaceView preview;
    private RelativeLayout drawing;

    private SmartIDWorker worker = new SmartIDWorker();
    private SmartIDCameraListener listener = null;

    ////////////////////////////////////////////////////////////////////////////////////////////////

    public void init(Context context_) {
        context = context_;
    }

    public void setListener(SmartIDVideoProcessingCallback listener) {
        worker.setListener(listener);
    }

    public void setCameraListener(SmartIDCameraListener listener_) {
        listener = listener_;
    }

    public void setSurface(SurfaceView preview_, RelativeLayout drawing_) {
        preview = preview_;
        preview.setOnClickListener(onFocus);

        drawing = drawing_;

        SurfaceHolder holder = preview.getHolder();
        holder.addCallback(this);
    }

    private View.OnClickListener onFocus = new View.OnClickListener() {

        public void onClick(View v) {
        if (camera_opened) {
            try {
                Camera.Parameters cparams = camera.getParameters();
                // focus if at least one focus area exists
                if (autofocus && cparams.getMaxNumFocusAreas() > 0) {
                    camera.cancelAutoFocus();
                    cparams.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
                    camera.setParameters(cparams);
                    camera.autoFocus(SmartIDCamera.this);
                }
            } catch (RuntimeException e) {
                // empty body
            }
        }
        }
    };

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        updatePreview();
        listener.CameraSurfaceDidCreated();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        // empty body
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        worker.stop();
        camera.stopPreview();
        // camera.release();
        camera = null;
        camera_opened = false;
    }

    @Override
    public void onAutoFocus(boolean success, Camera camera) {
        // empty body
    }

    public void updatePreview() {
        angle = getOrientationAngle();
        try {
            setView(preview.getWidth(), preview.getHeight());
        } catch (Exception e) {
            // empty body
        }
    }

    Camera.Size getPreviewSize() {
        return camera.getParameters().getPreviewSize();
    }

    int getOrientationAngle() {
        WindowManager wm = (WindowManager)context.getSystemService(WINDOW_SERVICE);
        assert wm != null;
        Display display = wm.getDefaultDisplay();
        android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();
        android.hardware.Camera.getCameraInfo(0, info);

        return (info.orientation - display.getRotation() * 90 + 360) % 360;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    private void setView(int width, int height) throws Exception {
        if (!camera_opened) {
            camera = Camera.open();


            if (camera == null) {
                return;
            }

            camera_opened = true;

            Camera.Parameters params = camera.getParameters();

            List<String> focus_modes = params.getSupportedFocusModes();  // supported focus modes
            String focus_mode = Camera.Parameters.FOCUS_MODE_AUTO;
            autofocus = focus_modes.contains(focus_mode);

            if (autofocus) {  // camera has autofocus
                if (focus_modes.contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE)) {
                    focus_mode = Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE;
                } else if (focus_modes.contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO)) {
                    focus_mode = Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO;
                }
            } else {
                // camera doesn't support autofocus so select the first mode
                focus_mode = focus_modes.get(0);
            }

            params.setFocusMode(focus_mode);
            camera.setParameters(params);
        }

        setPreviewSize(width, height);
        camera.setDisplayOrientation(angle);

        camera.setPreviewDisplay(preview.getHolder());
        camera.setPreviewCallback(this);
        camera.startPreview();
        worker.start();
        camera_opened = true;
    }

    private void setPreviewSize(int width, int height) {
        Camera.Parameters params = camera.getParameters();
        List<Camera.Size> sizes = params.getSupportedPreviewSizes();

        // minimal width of preview (if less - quality of recognition will be low)
        final int minimum_width = 800;
        final float tolerance = 0.1f;

        Camera.Size preview_size = sizes.get(0);

        final boolean landscape = (angle == 0 || angle == 180);

        if (landscape) {
            int tmp = height;
            height = width;
            width = tmp;
        }

        float best_ratio = (float) height / (float) width;
        // difference ratio between preview and best
        float preview_ratio_diff = abs((float) preview_size.width / (
                float) preview_size.height - best_ratio);

        for (int i = 1; i < sizes.size(); i++) {
            Camera.Size tmp_size = sizes.get(i);

            if (tmp_size.width < minimum_width) {
                continue;
            }

            float tmp_ratio_diff = abs((float) tmp_size.width / (float) tmp_size.height - best_ratio);

            if (abs(tmp_ratio_diff - preview_ratio_diff) < tolerance &&
                    tmp_size.width > preview_size.width || tmp_ratio_diff < preview_ratio_diff) {
                preview_size = tmp_size;
                preview_ratio_diff = tmp_ratio_diff;
            }
        }

        params.setPreviewSize(preview_size.width, preview_size.height);
        camera.setParameters(params);

        // recalculate surface size according to preview ratio

        int height_new, width_new;

        height_new = width * preview_size.width / preview_size.height;
        width_new = height * preview_size.height / preview_size.width;

        // select new surface size no more than original size

        if (height_new > height) {
            width = width_new;
        } else {
            height = height_new;
        }

        int preview_width = preview_size.width;
        int preview_height = preview_size.height;

        if (landscape) {
            int tmp = height;
            height = width;
            width = tmp;

            tmp = preview_height;
            preview_height = preview_width;
            preview_width = tmp;
        }

        ViewGroup.LayoutParams layout = preview.getLayoutParams();
        layout.width = width;
        layout.height = height;
        preview.setLayoutParams(layout);

        drawing.setLayoutParams(layout);
    }

    @Override
    public void onPreviewFrame(byte[] bytes, Camera camera) {
        Log.e("SMARTID", "onPreviewFrame on " + Thread.currentThread().getName());
        worker.PushBuffer(bytes);
    }
}
