package com.smartengines.jsmodule.sdk;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.res.AssetManager;
import android.preference.PreferenceManager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import biz.smartengines.smartid.swig.RecognitionEngine;
import biz.smartengines.smartid.swig.RecognitionSession;
import biz.smartengines.smartid.swig.SessionSettings;

public class SmartIDEngineService {

    private static SmartIDEngineService INSTANCE = null;
    private RecognitionEngine engine = null;

    private SmartIDEngineService() { }

    public static synchronized SmartIDEngineService getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new SmartIDEngineService();
        }
        return INSTANCE;
    }

    public void loadEngine(String bundle_path) throws Exception {
        if (engine == null) {
            System.loadLibrary("jniSmartIdEngine");
            engine = new RecognitionEngine(bundle_path);
        }

    }

    public void loadEngine(Context context, String bundle_dir) throws Exception {
        if (engine == null) {
            loadEngine(prepareBundle(context, bundle_dir));
        }
    }

    public SessionSettings defaultSessionSettings() {
        return engine.CreateSessionSettings();
    }

    public RecognitionSession spawnSession(SessionSettings settings) {
        return engine.SpawnSession(settings);
    }

    public String prepareBundle(Context context, String bundle_dir) throws Exception {
        AssetManager assetManager = context.getAssets();

        String bundle_name = "";
        String[] file_list = assetManager.list(bundle_dir);

        if (file_list.length <= 0) {
            throw new Exception("Assets directory empty: configuration bundle needed!");
        } else {
            for (String file : file_list) {
                if (file.endsWith(".zip")) {
                    bundle_name = file;
                    break;
                }
            }
            if (!bundle_name.endsWith(".zip")) {
                throw new Exception("No configuration bundle found!");
            }
        }

        final String input_bundle_path = bundle_dir + File.separator + bundle_name;
        final String output_bundle_dir = context.getFilesDir().getAbsolutePath() + File.separator;
        final String output_bundle_path = output_bundle_dir + bundle_name;

        PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
        int version_code = packageInfo.versionCode;

        SharedPreferences sPref = PreferenceManager.getDefaultSharedPreferences(context);
        int version_current = sPref.getInt("smartid_bundle_version", -1);
        String bundle_current = sPref.getString("smartid_bundle_name", "");

        if (version_code == version_current && bundle_name.compareTo(bundle_current) == 0) {
            return output_bundle_path;
        }

        InputStream input_stream = assetManager.open(input_bundle_path);
        File output_bundle_file = new File(output_bundle_dir, bundle_name);
        OutputStream output_stream = new FileOutputStream(output_bundle_file);

        int length;
        byte[] buffer = new byte[1024];

        while ((length = input_stream.read(buffer)) > 0) {
            output_stream.write(buffer, 0, length);
        }

        input_stream.close();
        output_stream.close();

        SharedPreferences.Editor ed = sPref.edit();
        ed.putInt("smartid_bundle_version", version_code);
        ed.putString("smartid_bundle_name", bundle_name);

        ed.commit();
        return output_bundle_path;
    }

}
