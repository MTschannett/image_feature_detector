package com.matas.image_feature_detector;

import android.graphics.Bitmap;

import org.opencv.android.Utils;
import org.opencv.core.Mat;

class ImageHelper {
  /**
   * Loads image from file and rotates it accordingly to exif data.
   *
   * @param path The file path to the image
   *
   * @return a OpenCV Mat Object.
   */
  static Mat loadImage(String path) {
    Mat source = new Mat();
    Bitmap image = ImageTransformer.loadAndRotateImage(path);

    Utils.bitmapToMat(image, source);

    return source;
  }
}
