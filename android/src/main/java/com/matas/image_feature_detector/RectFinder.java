package com.matas.image_feature_detector;

import android.graphics.Bitmap;
import android.util.Log;

import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Source Code was found in this example application: https://github.com/shuhei/Rectify
 */
public class RectFinder {
    private static final String DEBUG_TAG = "RectFinder";
    private static final int N = 5; // 11 in the original sample.
    private static final int CANNY_THRESHOLD = 200;
    private static final int CANNY_TRESHOLD_MIN = 75;
    private static final double DOWNSCALE_IMAGE_SIZE = 600f;

    /*
    private double areaLowerThresholdRatio;
    private double areaUpperThresholdRatio;
    double areaLowerThresholdRatio, double areaUpperThresholdRatio
    */
    public RectFinder() {

       /*
        this.areaLowerThresholdRatio = areaLowerThresholdRatio;
        this.areaUpperThresholdRatio = areaUpperThresholdRatio;
         */
    }

    public MatOfPoint2f findRectangle(Mat src) {
        // Downscale image for better performance.
        double ratio = DOWNSCALE_IMAGE_SIZE / Math.max(src.width(), src.height());
        Size downscaledSize = new Size(src.width() * ratio, src.height() * ratio);
        Log.d(DEBUG_TAG, "Before downscaling: " + src.size());
        Mat downscaled = new Mat(downscaledSize, src.type());
        Log.d(DEBUG_TAG, "After downscaling: " + downscaled.size());
        Imgproc.resize(src, downscaled, downscaledSize);

        // Find rectangles.
        List<MatOfPoint2f> rectangles = findRectangles(downscaled);
        Log.d(DEBUG_TAG, rectangles.size() + " rectangles found.");

        if (rectangles.size() == 0) {
            Log.d(DEBUG_TAG, "No rectangles found.");
            return null;
        }

        // Pick up the largest rectangle.
        Collections.sort(rectangles, AreaDescendingComparator);
        Log.d(DEBUG_TAG, "Sorted rectangles.");

        MatOfPoint2f largestRectangle = rectangles.get(0);
        Log.d(DEBUG_TAG, "Before scaling up: " + GeomUtils.pointsToString(largestRectangle));

        // Take back the scale.
        MatOfPoint2f result = GeomUtils.scaleRectangle(largestRectangle, 1f / ratio);
        Log.d(DEBUG_TAG, "After scaling up: " + GeomUtils.pointsToString(result));

        return result;
    }

    // Compare contours by their areas in descending order.
    private static Comparator<MatOfPoint2f> AreaDescendingComparator = new Comparator<MatOfPoint2f>() {
        public int compare(MatOfPoint2f m1, MatOfPoint2f m2) {
            double area1 = Imgproc.contourArea(m1);
            double area2 = Imgproc.contourArea(m2);
            return (int) Math.ceil(area2 - area1);
        }
    };

    public List<MatOfPoint2f> findRectangles(Mat src) {
        // Blur the image to filter out the noise.
        Mat grey = new Mat();
        Imgproc.cvtColor(src, grey, Imgproc.COLOR_BGR2GRAY);

        Mat blur = new Mat(grey.size(), CvType.CV_8U);
        Imgproc.GaussianBlur(grey, blur, new Size(5,5), 0);

        Mat edged = new Mat(blur.size(), CvType.CV_8U);
        Imgproc.Canny(blur, edged, RectFinder.CANNY_TRESHOLD_MIN, CANNY_THRESHOLD);
        Bitmap tempt = ImageUtils.matToBitmap(edged);
        List<MatOfPoint> contours = new ArrayList<>();
        List<MatOfPoint2f> rectangles = new ArrayList<>();

        // To filter rectangles by their areas.
        // int srcArea = src.rows() * src.cols();

        Imgproc.findContours(edged, contours, new Mat(), Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_SIMPLE);

        for (MatOfPoint contour : contours) {
            MatOfPoint2f contourFloat = GeomUtils.toMatOfPointFloat(contour);
            double arcLen = Imgproc.arcLength(contourFloat, true) * 0.02;

            // Approximate polygonal curves.
            MatOfPoint2f approx = new MatOfPoint2f();
            Imgproc.approxPolyDP(contourFloat, approx, arcLen, true);

            if (isRectangle(approx)) {
                rectangles.add(approx);
            }
        }

        return rectangles;
    }

    private boolean isRectangle(MatOfPoint2f polygon) {
        MatOfPoint polygonInt = GeomUtils.toMatOfPointInt(polygon);

        if (polygon.rows() != 4) {
            return false;
        }

        return Imgproc.isContourConvex(polygonInt);
    }
}
