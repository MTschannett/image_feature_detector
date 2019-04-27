package com.matas.image_feature_detector;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;

import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

import java.io.IOException;

public class ImageTransformer {
  public static Bitmap loadAndRotateImage(String path) {
    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inPreferredConfig = Bitmap.Config.ARGB_8888;

    try {
      return ImageTransformer.rotateImageAccordingToExif(BitmapFactory.decodeFile(path, options), path);
    } catch(IOException e) {
      return null;
    }
  }

  public static Mat transformSobel(Mat source) {
    int width = source.width();
    int height = source.height();
    Mat destination = ImageTransformer.createMat(source.width(), source.height());
    Mat sobelX = ImageTransformer.createMat(width,height), sobelY  = ImageTransformer.createMat(width,height);
    Mat absSobelX  = ImageTransformer.createMat(width,height), absSobleY = ImageTransformer.createMat(width,height);



    Imgproc.Sobel(source, sobelX, CvType.CV_16S, 1, 0);
    Imgproc.Sobel(source, sobelY, CvType.CV_16S, 0, 1);

    Core.convertScaleAbs(sobelX, absSobelX);
    Core.convertScaleAbs(sobelY, absSobleY);

    Core.addWeighted(absSobelX, 0.5, absSobleY, 0.5, 0, destination);

    return destination;
  }

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

  public static Mat cannyEdgeDetect(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());
    Imgproc.Canny(source, destination, 10, 100);

    return destination;
  }

  private static Mat createMat(int width, int height) {
    return new Mat(width, height, CvType.CV_8UC1);
  }

  private static Bitmap rotateImageAccordingToExif(Bitmap image, String path) throws IOException {
    ExifInterface exif = new ExifInterface(path);
    int exifOrientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1);
    Matrix matrix = ExifHelper.fromOrientation(exifOrientation);

   return Bitmap.createBitmap(image, 0, 0, image.getWidth(), image.getHeight(), matrix, true);
  }
}
