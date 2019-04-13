package com.matas.image_feature_detector;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.imgproc.Imgproc;

import java.util.ArrayList;
import java.util.Iterator;

public class ImageDetector {
  public static String getVersionString() {
    return Core.getVersionString();
  }

  public static String getBuildInformation() {
    return Core.getBuildInformation();
  }

  public static String detectRectangles(String filePath) throws JSONException {
    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inPreferredConfig = Bitmap.Config.ARGB_8888;

    Mat source = new Mat();

    Utils.bitmapToMat(BitmapFactory.decodeFile(filePath, options), source);

    source = ImageTransformer.transformToGrey(source);
    source = ImageTransformer.gaussianBlur(source);
    source = ImageTransformer.adaptiveTreshold(source);

    ArrayList<MatOfPoint> contours = new ArrayList<>();

    Imgproc.findContours(source, contours, new Mat(), Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);

    double maxArea = 0;
    MatOfPoint maxContour = null;
    Iterator<MatOfPoint> iterator = contours.iterator();

    while (iterator.hasNext()) {
      MatOfPoint contour = iterator.next();
      double area = Imgproc.contourArea(contour);

      if (area > maxArea) {
        maxContour = contour;
        maxArea = area;
      }
    }

    if (maxContour == null) {
      // TODO: maybe we should throw an error here.
      return null;
    }

    MatOfPoint2f maxContour2f = new MatOfPoint2f(maxContour.toArray());
    double peri = Imgproc.arcLength(maxContour2f, true);
    MatOfPoint2f approx = new MatOfPoint2f();
    Imgproc.approxPolyDP(maxContour2f, approx, 0.04 * peri, true);

    if (approx.total() == 4) {
      System.out.print("Rectangle or square found");
      // List<Contour> points = new ArrayList<>();
      JSONObject contour = new JSONObject();
      JSONArray points = new JSONArray();

      for (Point p : approx.toList()) {
        JSONObject o = new JSONObject();
        o.put("x", p.x);
        o.put("y", p.y);

        points.put(o);
      }

      contour.put("contour", points);

      return contour.toString();
    }

    return null;
  }
}
