package com.matas.image_feature_detector;

import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

public class ImageTransformer {
  public static Mat transformToGrey(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());

    Imgproc.cvtColor(source, destination, Imgproc.COLOR_BGR2GRAY);

    return destination;
  }

  public static Mat gaussianBlur(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());
    Imgproc.GaussianBlur(source, destination, new Size(3, 3), 0);

    return destination;
  }

  public static Mat treshold(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());
    Imgproc.threshold(source, destination, 60, 255, Imgproc.THRESH_BINARY);
    return destination;
  }

  public static Mat adaptiveThreshold(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());
    Imgproc.adaptiveThreshold(source, destination, 255, Imgproc.ADAPTIVE_THRESH_MEAN_C, Imgproc.THRESH_BINARY_INV, 15, 2);

    return destination;
  }

  private static Mat createMat(int width, int height) {
    return new Mat(width, height, CvType.CV_8UC1);
  }
}
