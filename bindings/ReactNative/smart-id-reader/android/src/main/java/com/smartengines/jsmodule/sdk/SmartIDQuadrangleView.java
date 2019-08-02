package com.smartengines.jsmodule.sdk;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.PointF;
import android.graphics.PorterDuff;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import java.util.ArrayList;
import java.util.List;


import biz.smartengines.smartid.swig.Quadrangle;



public class SmartIDQuadrangleView extends SurfaceView {

    volatile boolean canceled = false;

    private Paint paint;
    private Paint paintGreen;

    private int preview_w = 0;
    private int preview_h = 0;

    private int canvas_w = 0;
    private int canvas_h = 0;

    private int zone_x = 0;
    private int zone_y = 0;

    private int color = Color.parseColor("#ffffb3");
    private int width = (int) ( getContext().getResources().getDisplayMetrics().density * 2);
    private volatile List<QuadRectangle> quadRectangles;

    public boolean is_started = false;


    public SmartIDQuadrangleView(Context context) {
        super(context);
        setZOrderOnTop(true);

        paint = new Paint();
        paint.setColor(color);
        paint.setStrokeWidth(width);
        paintGreen = new Paint();
        paint.setAlpha(128);

        paintGreen.setColor(Color.GREEN);
        paintGreen.setStrokeWidth(width);
        quadRectangles = new ArrayList<>();
        setLayerType(View.LAYER_TYPE_HARDWARE, null);
        setWillNotDraw(false);
    }

    private void updateQuads(double delta) {
        for (int i = 0; i < quadRectangles.size(); ++i) {
            if (quadRectangles.get(i).isActual()) {
                quadRectangles.get(i).alpha += (quadRectangles.get(i).isFading ? -delta : +delta);
                if (quadRectangles.get(i).alpha >= 1.0) {
                    quadRectangles.get(i).isFading = true;
                }
            }
        }
    }

    public List<QuadRectangle> getQuads() {
        return quadRectangles;
    }


    public void SetQuad(Quadrangle quad) {
        PointF lt = new PointF();
        PointF rt = new PointF();
        PointF lb = new PointF();
        PointF rb = new PointF();
        lt.x = (float)canvas_w * (float)quad.GetPoint(0).getX() / (float)preview_w + zone_x;
        lt.y = (float)canvas_h * (float)quad.GetPoint(0).getY() / (float)preview_h + zone_y;

        rt.x = (float)canvas_w * (float)quad.GetPoint(1).getX() / (float)preview_w + zone_x;
        rt.y = (float)canvas_h * (float)quad.GetPoint(1).getY() / (float)preview_h + zone_y;

        rb.x = (float)canvas_w * (float)quad.GetPoint(2).getX() / (float)preview_w + zone_x;
        rb.y = (float)canvas_h * (float)quad.GetPoint(2).getY() / (float)preview_h + zone_y;

        lb.x = (float)canvas_w * (float)quad.GetPoint(3).getX() / (float)preview_w + zone_x;
        lb.y = (float)canvas_h * (float)quad.GetPoint(3).getY() / (float)preview_h + zone_y;

        if (quadRectangles.size() == 0) {
            new DrawThread(getHolder(), quadRectangles).start();
        }

        quadRectangles.add(new QuadRectangle(lt, rt, lb, rb));
    }

    public void drawQuads() {

    }

    public void SetPreviewSize(int preview_w, int preview_h) {

        this.preview_w = preview_w;
        this.preview_h = preview_h;
    }

    public void Clear() {

        quadRectangles.clear();
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        this.canvas_w = w;
        this.canvas_h = h;
    }

    private class QuadRectangle {
        private PointF lt;
        private PointF rt;
        private PointF lb;
        private PointF rb;
        float alpha;
        boolean isFading;

        private QuadRectangle(PointF lt, PointF rt, PointF lb, PointF rb) {
            this.lt = lt;
            this.rt = rt;
            this.lb = lb;
            this.rb = rb;
            alpha = 0;
            isFading = false;
        }

        public boolean isActual() {
            return alpha > 0 || !isFading;
        }

        public Path getPath() {
            Path path = new Path();

            path.moveTo(lt.x, lt.y);
            path.lineTo(rt.x, rt.y);
            path.lineTo(rb.x, rb.y);
            path.lineTo(lb.x, lb.y);
            path.close();

            return path;
        }
    }

    private class DrawThread extends Thread {

        private final SurfaceHolder surfaceHolder;
        private long updatingTime = 30;
        private long iterations = 5;
        Paint p;

        @Override
        public synchronized void start() {
            super.start();
        }

        DrawThread(SurfaceHolder surfaceHolder, List<QuadRectangle> quadRectangles) {
            this.surfaceHolder = surfaceHolder;
            this.surfaceHolder.setFormat(PixelFormat.TRANSPARENT);
            p = new Paint();
            p.setColor(Color.GREEN);
            p.setSubpixelText(true);
            p.setAntiAlias(true);
            p.setStrokeWidth(6.0f);
            p.setStyle(Paint.Style.STROKE);
        }

        @Override
        public void run() {
            Canvas canvas;
            while (!canceled) {
                double transparencyDelta = 1.0 / (double) iterations;
                canvas = null;
                try {
                    canvas = surfaceHolder.lockCanvas(null);
                    if (null != canvas) {
                        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
                        List<QuadRectangle> quads = getQuads();
                        for (int i = 0; i < quads.size(); ++i) {
                            if (quads.get(i).isActual()) {
                                Path current = quads.get(i).getPath();
                                p.setAlpha((int) (Math.pow(quads.get(i).alpha, 0.5) * 255.0));
                                canvas.drawPath(current, p);
                            }
                        }
                        updateQuads(transparencyDelta);
                    }
                } finally {
                    if (canvas != null) {
                        surfaceHolder.unlockCanvasAndPost(canvas);
                    }
                    try {
                        sleep(updatingTime);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
