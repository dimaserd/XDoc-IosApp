package com.smartengines.jsmodule;

import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.smartengines.jsmodule.sdk.SmartIDActivity;


import biz.smartengines.smartid.swig.RecognitionResult;

public class SmartIDActivityJS extends SmartIDActivity {

    static ReactApplicationContext react_ctx;

    @Override
    public void sessionDidRecognizeResult(final RecognitionResult result) {
        super.sessionDidRecognizeResult(result);
        WritableMap map = new WritableNativeMap();

        map.putBoolean("terminal", result.IsTerminal());

        WritableMap stringFields = new WritableNativeMap();
        WritableMap imageFields = new WritableNativeMap();

        for (int i = 0; i < result.GetStringFieldNames().size(); ++i) {
            String name = result.GetStringFieldNames().get(i);
            stringFields.putString(name, result.GetStringField(name).GetUtf8Value());
        }

        for (int i = 0; i < result.GetImageFieldNames().size(); ++i) {
            String name = result.GetImageFieldNames().get(i);
            byte[] buff = new byte[result.GetImageField(name).GetValue().GetRequiredBase64BufferLength()];
            result.GetImageField(name).GetValue().CopyBase64ToBuffer(buff);
            imageFields.putString(name, buff.toString());
        }

        map.putMap("stringFields", stringFields);

        map.putMap("imageFields", imageFields);

        ReactContext reactContext = react_ctx;
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).
                emit("DidRecognize", map);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        ReactContext reactContext = react_ctx;
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).
                emit("DidCancel", null);
    }
}
