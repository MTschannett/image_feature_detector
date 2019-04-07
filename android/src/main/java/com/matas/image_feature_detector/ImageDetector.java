package com.matas.image_feature_detector;

import org.bytedeco.javacpp.helper.opencv_core;
import org.opencv.core.*;
import org.opencv.imgcodecs.Imgcodecs;

import static org.bytedeco.javacpp.opencv_imgproc.COLOR_BGR2GRAY;
import static org.bytedeco.javacpp.opencv_imgproc.cvCvtColor;

public class ImageDetector {
  public static String getVersionString() {
    return Core.getVersionString();
  }

  public static String getBuildInformation() {
    return Core.getBuildInformation();
  }

  public static Object detectRectangles(String filePath) {
    // TODO: Try to implement it with the link below. d
    //https://www.tutorialspoint.com/java_dip/grayscale_conversion_opencv.htm
    Mat image = Imgcodecs.imread(filePath);
    Mat destination = new Mat();

    //cvCvtColor(image, destination, COLOR_BGR2GRAY);
    return null;
  }
}
