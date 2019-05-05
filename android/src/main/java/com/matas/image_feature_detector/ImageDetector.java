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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;

class ImageDetector {
  /**
   * Returns the version string for the current OpenCV implementation.
   *
   * @return String containing version string
   */
  static String getVersionString() {
    return Core.getVersionString();
  }

  /**
   * Returns the build information for the current OpenCV implementation.
   *
   * @return String containing build information
   */
  static String getBuildInformation() {
    return Core.getBuildInformation();
  }

  static String detectRectangles(String filePath) {
    Mat source = ImageHelper.loadImage(filePath);

    MatOfPoint2f maxApprox = ImageDetector.findContoursFromImage(source);

    try {
      return ImageDetector.serializeRectangleData(maxApprox, source).toString();
    } catch (JSONException e) {
      return null;
    }
  }

  /**
   * Serializes found contour data.
   * Dart object is Contour
   *
   * @param approx Approximated contour data (should be four points)
   * @param source The source image object
   * @return JsonObject
   * @throws JSONException A exception when data cannot be serialized
   */
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

  /**
   * Detects and warps image in perspective to get clear image back.
   *
   * Return object in Dart TransformedImage
   *
   * @param path Path to the original image object.
   *
   * @return a serialized string of json.
   */
  static String detectAndTransformRectangleInImage(String path) {
    Mat image = ImageHelper.loadImage(path);
    MatOfPoint2f foundContours = ImageDetector.findContoursFromImage(image);

    Mat warped = ImageTransformer.transformPerspectiveWarp(
        image, foundContours
    );

    Bitmap b = Bitmap.createBitmap(warped.width(), warped.height(), Bitmap.Config.ARGB_8888);

    Utils.matToBitmap(warped, b);

    String savePath = new File(path).getAbsoluteFile().getParent();
    savePath += "transformed-image" + new Date().getTime() + ".png";


    try {
      FileOutputStream stream = new FileOutputStream(new File(savePath));
      b.compress(Bitmap.CompressFormat.PNG, 100, stream);

      stream.flush();
      stream.close();

      JSONObject outer = new JSONObject();
      outer.put("foundFeatures", ImageDetector.serializeRectangleData(foundContours, image));
      outer.put("filePath", savePath);

      return outer.toString();
    } catch (FileNotFoundException e) {
      return null;
    } catch (IOException e) {
      return null;
    } catch (JSONException e) {
      return null;
    }

  }

  private static MatOfPoint2f findContoursFromImage(Mat source) {
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

    return maxApprox;
  }
}
