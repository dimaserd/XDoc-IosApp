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

import android.Manifest;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.hardware.Camera.Size;
import android.view.Gravity;
import android.view.SurfaceView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.smartengines.jsmodule.R;

import biz.smartengines.smartid.swig.ImageOrientation;
import biz.smartengines.smartid.swig.RecognitionSession;

/**
 * Main sample activity for documents recognition with Smart IDReader Android SDK
 */
public abstract class SmartIDActivityBase
        extends
        AppCompatActivity
        implements
        SmartIDVideoProcessingCallback,
        SmartIDCallback {

    protected final int REQUEST_CAMERA_PERMISSION = 1;

    protected SmartIDCamera camera;
    protected RelativeLayout drawing;
    protected RecognitionSession session;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        makeLayout();

        camera = new SmartIDCamera();
        camera.init(this);
        camera.setListener(this);

        SurfaceView preview = findViewById(R.id.preview);
        drawing = findViewById(R.id.drawing);

        camera.setSurface(preview, drawing);

        if (permission(Manifest.permission.CAMERA)) {
            request(Manifest.permission.CAMERA, REQUEST_CAMERA_PERMISSION);
        }
    }

    protected void makeLayout() {
        setContentView(R.layout.smartid_base);
    }

    //================================================================================
    // Helper functions
    //================================================================================

    protected void toast(String message) {
        Toast t = Toast.makeText(getApplicationContext(), message, Toast.LENGTH_LONG);
        t.setGravity(Gravity.CENTER, 0, 0);
        t.show();
    }

    //================================================================================
    // Permissions
    //================================================================================


    public boolean permission(String permission) {
        int result = ContextCompat.checkSelfPermission(this, permission);
        return result != PackageManager.PERMISSION_GRANTED;
    }

    public void request(String permission, int request_code) {
        ActivityCompat.requestPermissions(this, new String[]{permission}, request_code);
    }

    @Override
    public void onRequestPermissionsResult(
            int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case REQUEST_CAMERA_PERMISSION: {
                boolean granted = false;
                for (int grantResult : grantResults) {
                    if (grantResult == PackageManager.PERMISSION_GRANTED) { // Permission is granted
                        granted = true;
                    }
                }
                if (granted) {
                    camera.updatePreview();
                } else {
                    toast("Please enable Camera permission.");
                }
            }
            default: {
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
            }
        }
    }

    //================================================================================
    // SmartIDVideoProcessingCallback impl
    //================================================================================

    @Override
    public void workerDidOutputBuffer(byte[] buffer) {
        if (isSessionRunning()) {
            int angle = camera.getOrientationAngle();
            Size size = camera.getPreviewSize();
            ImageOrientation orientation;

            switch (angle) {
                case 0:
                    orientation = ImageOrientation.Landscape;
                    break;
                case 180:
                    orientation = ImageOrientation.InvertedLandscape;
                    break;
                case 270:
                    orientation = ImageOrientation.InvertedPortrait;
                    break;
                default:
                    orientation = ImageOrientation.Portrait;
            }
            sessionWillRecognizeResult(session, buffer, size, orientation);

        }
    }
}
