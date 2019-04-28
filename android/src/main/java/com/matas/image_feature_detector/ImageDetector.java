package com.matas.image_feature_detector;

import android.graphics.Bitmap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.imgproc.Imgproc;

import java.util.ArrayList;

class ImageDetector {
  static String getVersionString() {
    return Core.getVersionString();
  }

  static String getBuildInformation() {
    return Core.getBuildInformation();
  }

  static String detectRectangles(String filePath)  {
    Bitmap image = ImageTransformer.loadAndRotateImage(filePath);
    Mat source = new Mat();

    assert image != null;

    Utils.bitmapToMat(image, source);

    source = ImageTransformer.transformToGrey(source);
    source = ImageTransformer.transformSobel(source);
    source = ImageTransformer.cannyEdgeDetect(source);
    source = ImageTransformer.gaussianBlur(source);

    ArrayList<MatOfPoint> contours = new ArrayList<>();

    Imgproc.findContours(
            source,
            contours,
            new Mat(),
            Imgproc.RETR_TREE,
            Imgproc.CHAIN_APPROX_SIMPLE);

    double maxArea = 0;
    MatOfPoint2f maxApprox = null;

    for (MatOfPoint contour : contours) {
      MatOfPoint2f maxContour2f = new MatOfPoint2f(contour.toArray());
      double peri = Imgproc.arcLength(maxContour2f, true);
      MatOfPoint2f approx = new MatOfPoint2f();
      Imgproc.approxPolyDP(maxContour2f, approx, 0.04 * peri, true);

      if (approx.total() == 4) {
        double area = Imgproc.contourArea(contour);

        if (area > maxArea) {
          maxApprox = approx;
          maxArea = area;
        }
      }
    }

    if (maxApprox == null) {
      return null;
    }

    try {
      return ImageDetector.serializeRectangleData(maxApprox,source).toString();
    } catch(JSONException e) {
      return null;
    }
  }

  private static JSONObject serializeRectangleData(MatOfPoint2f approx, Mat source) throws JSONException {
    JSONObject contour = new JSONObject();
    JSONArray points = new JSONArray();
    JSONObject dimensions = new JSONObject();

    for (int i = 0; i < 4; i++) {
      double[] t = approx.get(i, 0);
      JSONObject o = new JSONObject();
      o.put("x", (t[0] / source.cols()));
      o.put("y", (t[1] / source.rows()));

      points.put(o);
    }

    dimensions.put("height", source.rows());
    dimensions.put("width", source.cols());

    contour.put("dimensions", dimensions);
    contour.put("contour", points);

    return contour;
  }
}
