package com.smartengines.jsmodule;

import android.content.Intent;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;


import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.smartengines.jsmodule.sdk.SmartIDActivity;
import com.smartengines.jsmodule.sdk.SmartIDEngineService;

import java.util.HashMap;
import java.util.Map;


public class SmartIDModule extends ReactContextBaseJavaModule {

    private HashMap<String, String> params = new HashMap<>();

    public SmartIDModule(ReactApplicationContext context) {
        super(context);
    }

    @Override
    public String getName() {
        return "SmartIDReader";
    }

    @ReactMethod
    public void initEngine(final Promise promise) {
        try {
            SmartIDEngineService.getInstance().loadEngine(getReactApplicationContext(), "data");
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(getName(), "failed to load engine");
        }
    }

    @ReactMethod
    public void startRecognition(final Promise promise) {
        try {
            SmartIDActivityJS.react_ctx = getReactApplicationContext();
            Intent intent = new Intent(getCurrentActivity(), SmartIDActivityJS.class);
            putExtras(intent);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getReactApplicationContext().startActivity(intent);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(getName(), "failed to push activity: " + e.getMessage());
        }
    }

    private void putExtras(Intent intent) {
        if (params.containsKey("sessionTimeout")) {
            intent.putExtra("sessionTimeout", Float.parseFloat(params.get("sessionTimeout")));
        }
        if (params.containsKey("displayZonesQuadrangles")) {
            intent.putExtra("displayZonesQuadrangles",
                    Boolean.valueOf(params.get("displayZonesQuadrangles")));
        }
        if (params.containsKey("displayDocumentQuadrangle")) {
            intent.putExtra("displayDocumentQuadrangle",
                    Boolean.valueOf(params.get("displayDocumentQuadrangle")));
        }
        if (params.containsKey("documentMask")) {
            intent.putExtra("documentMask", new String[]{
                    params.get("documentMask")
            });
        }
    }

    @ReactMethod
    public void setParams(final ReadableMap params_) {
        params = new HashMap<>();
        for (Map.Entry<String, Object> entry : params_.toHashMap().entrySet()) {
            params.put(entry.getKey(), entry.getValue().toString());
        }
    }

    @ReactMethod
    public void cancelRecognition(final Promise promise) {
        if (SmartIDActivityJS.class == getCurrentActivity().getClass()) {
            getCurrentActivity().finish();
        }
        promise.resolve(null);
    }
}