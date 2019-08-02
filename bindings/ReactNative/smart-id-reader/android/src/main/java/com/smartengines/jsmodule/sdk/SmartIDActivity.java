package com.smartengines.jsmodule.sdk;

import android.hardware.Camera;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.Surface;

import biz.smartengines.smartid.swig.ImageOrientation;
import biz.smartengines.smartid.swig.MatchResultVector;
import biz.smartengines.smartid.swig.Quadrangle;
import biz.smartengines.smartid.swig.RecognitionResult;
import biz.smartengines.smartid.swig.RecognitionSession;
import biz.smartengines.smartid.swig.SegmentationResult;
import biz.smartengines.smartid.swig.SegmentationResultVector;
import biz.smartengines.smartid.swig.SessionSettings;
import biz.smartengines.smartid.swig.StringVector;

public class SmartIDActivity
        extends SmartIDActivityBase
        implements SmartIDCameraListener {

    private SmartIDQuadrangleView quadrangleView;
    private volatile boolean processing;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        camera.setCameraListener(this);

        quadrangleView = new SmartIDQuadrangleView(this);
        drawing.addView(quadrangleView);

        SmartIDEngineService service = SmartIDEngineService.getInstance();
        try {
            service.loadEngine(this, "data");
        } catch (Exception e) {
            e.printStackTrace();
        }
        SessionSettings settings = service.defaultSessionSettings();
        settings.RemoveEnabledDocumentTypes("*");

        for (String mask : getIntent().getStringArrayExtra("documentMask")) {
            settings.AddEnabledDocumentTypes(mask);
        }
        settings.SetOption(
                "common.sessionTimeout",
                Float.toString(getIntent().getFloatExtra(
                        "sessionTimeout",
                        5.0f)
                )
        );

        spawnSession(settings);
        startRecognition();
    }


    //================================================================================
    // SmartIDCallback impl
    //================================================================================

    @Override
    public void spawnSession(SessionSettings settings) {
        session = SmartIDEngineService.getInstance().spawnSession(settings);
    }

    @Override
    public void startRecognition() {
        processing = true;
    }

    @Override
    public boolean isSessionRunning() {
        return processing;
    }

    @Override
    public void cancelRecognition() {
        processing = false;
    }

    @Override
    public boolean isResultTerminal(RecognitionResult result) {
        return result.IsTerminal();
    }

    @Override
    public void sessionWillRecognizeResult(RecognitionSession session,
                                           byte[] data,
                                           Camera.Size size,
                                           ImageOrientation orientation) {
        assert session != null;
        final RecognitionResult result = session.ProcessYUVSnapshot(
                data,
                size.width,
                size.height,
                orientation);
        sessionDidRecognizeResult(result);
    }

    @Override
    public void sessionDidRecognizeTerminalResult(RecognitionResult result) {
        cancelRecognition();
        finish();
    }

    @Override
    public void sessionDidRecognizeResult(final RecognitionResult result) {
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.e("SMARTID", "SHOW BUFFER IN " + Thread.currentThread().getName());

                if (isResultTerminal(result)) {
                    sessionDidRecognizeTerminalResult(result);
                } else {
                    if (null != quadrangleView) {
                        drawQuadrangles(result);
                    }
                }
            }
        });
    }

    //================================================================================
    // Drawing impl
    //================================================================================

    private void drawQuadrangles(RecognitionResult result) {
        try {
            MatchResultVector match = result.GetMatchResults();
            for (int i = 0; i < match.size(); i++) {
                Quadrangle quad = match.get(i).GetQuadrangle();
                quadrangleView.SetQuad(quad);
            }
        } catch (RuntimeException re) {

        }

        SegmentationResultVector segmentationResultVector = result.GetSegmentationResults();
        for (int i = 0; i < segmentationResultVector.size(); i++) {
            SegmentationResult segResult = segmentationResultVector.get(i);
            StringVector zoneNames = segResult.GetRawFieldsNames();
            for (int j = 0; j < zoneNames.size(); j++) {
                Quadrangle quad = segResult.GetRawFieldQuadrangle(zoneNames.get(j));
                quadrangleView.SetQuad(quad);
            }
        }
    }

    //================================================================================
    // SmartIDQuadrangle view orientation update
    //================================================================================

    @Override
    public void CameraSurfaceDidCreated() {
        Display display = getWindowManager().getDefaultDisplay();
        Camera.Size size = camera.getPreviewSize();
        int preview_w = size.width;
        int preview_h = size.height;
        switch (display.getRotation()) {
            case Surface.ROTATION_0: // This is display orientation
                quadrangleView.SetPreviewSize(preview_h, preview_w);
                break;
            case Surface.ROTATION_90:
                quadrangleView.SetPreviewSize(preview_w, preview_h);
                break;
            case Surface.ROTATION_270:
                quadrangleView.SetPreviewSize(preview_w, preview_h);
                break;
            default:
                break;
        }
    }
}
