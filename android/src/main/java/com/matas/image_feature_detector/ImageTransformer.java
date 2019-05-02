package com.matas.image_feature_detector;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;

import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

import java.io.IOException;
import java.util.List;

/**
 * Transforms images using OpenCV
 */
public class ImageTransformer {
  /**
   * Loads and rotates images. Exif data is used to determine the correct image rotation.
   *
   * @param path - Path at which the image is stored
   * @return Bitmap loaded image
   */
  public static Bitmap loadAndRotateImage(String path) {
    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inPreferredConfig = Bitmap.Config.ARGB_8888;

    try {
      return ImageTransformer.rotateImageAccordingToExif(BitmapFactory.decodeFile(path, options), path);
    } catch(IOException e) {
      return null;
    }
  }

  /**
   * Executes a sobel edge detection over the source image.
   * @param source Image to perform sobel edge detection
   * @return Image containing result of sobel transformation.
   */
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

  /**
   * Executes a grey scale over the source image.
   * @param source The image to perform the action
   * @return The grey scaled image.
   */
  public static Mat transformToGrey(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());

    Imgproc.cvtColor(source, destination, Imgproc.COLOR_BGR2GRAY);

    return destination;
  }

  /**
   * Executes a gaussian blur over a image.
   * @param source The image to perform the action
   * @return A blurred image.
   */
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

  /**
   * Executes a canny edge detection over the given image.
   * @param source A image to perform the edge detection
   * @return Changed image holding the edge detection.
   */
  public static Mat cannyEdgeDetect(Mat source) {
    Mat destination = ImageTransformer.createMat(source.width(), source.height());
    Imgproc.Canny(source, destination, 10, 100);

    return destination;
  }

  public static Mat transformPerspectiveWarp(Mat image, MatOfPoint2f points) {
    Mat rect = new Mat();
    points.copyTo(rect);

    List<Point> sorted = PointHelper.sortPoints(points);
    Point tl = sorted.get(0);
    Point tr = sorted.get(1);
    Point br = sorted.get(2);
    Point bl = sorted.get(3);

    double widthA = Math.sqrt(Math.pow(br.x - bl.x, 2) + Math.pow(br.y - bl.y, 2));
    double widthB = Math.sqrt(Math.pow(tr.x - tl.x, 2) + Math.pow(tr.y - tl.y, 2));
    int maxWidth = (int)Math.max(widthA, widthB);

    double heightA = Math.sqrt(Math.pow(tr.x - br.x, 2) + Math.pow(tr.y - br.y, 2));
    double heightB = Math.sqrt(Math.pow(tl.x - bl.x, 2) + Math.pow(tl.y - bl.y, 2));
    int maxHeight = (int)Math.max(heightA, heightB);

    MatOfPoint2f dest = new MatOfPoint2f(new Point(0,0), new Point(maxWidth -1, 0), new Point(maxWidth -1, maxHeight -1), new Point(0, maxHeight - 1));

    MatOfPoint2f temp = new MatOfPoint2f(tl, tr, br,bl);

    Mat matrix = Imgproc.getPerspectiveTransform(temp, dest);
    Mat warped = ImageTransformer.createMat(maxWidth, maxHeight);
    Imgproc.warpPerspective(image, warped, matrix, new Size(maxWidth, maxHeight));

    return  warped;
  }

  /**
   * Creates a new MAT Object holding no data, but with a specified height and width.
   * @param width The image width (cols)
   * @param height The image height (rows)
   * @return a empty Mat with specified dimensions
   */
  private static Mat createMat(int width, int height) {
    return ImageTransformer.createMat(width, height, CvType.CV_8UC1);
  }

  private static Mat createMat(int width, int height, int cvType) {
    return new Mat(width, height, cvType);
  }

  /**
   * Rotates image according to stored exif data.
   * This step is needed because otherwise the results wouldn't match the users expectations.
   *
   * For more information:
   * https://de.wikipedia.org/wiki/Exchangeable_Image_File_Format
   *
   * @param image The image which should be rotated
   * @param path The file path of that image.
   * @return new Bitmap containing the rotated image
   * @throws IOException Thrown when either the image or the exif data can't be accessed.
   */
  private static Bitmap rotateImageAccordingToExif(Bitmap image, String path) throws IOException {
    ExifInterface exif = new ExifInterface(path);
    int exifOrientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1);
    Matrix matrix = ExifHelper.fromOrientation(exifOrientation);

   return Bitmap.createBitmap(image, 0, 0, image.getWidth(), image.getHeight(), matrix, true);
  }
}
