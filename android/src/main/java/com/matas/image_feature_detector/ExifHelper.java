package com.matas.image_feature_detector;

import android.graphics.Matrix;
import android.media.ExifInterface;

public class ExifHelper {
  public static Matrix fromOrientation(final int pExifOrientation) {

    Matrix matrix = new Matrix();
    switch (pExifOrientation) {

      case ExifInterface.ORIENTATION_ROTATE_270: {

        matrix.postRotate(270);

        break;
      }

      case ExifInterface.ORIENTATION_ROTATE_180: {

        matrix.postRotate(180);

        break;
      }

      case ExifInterface.ORIENTATION_ROTATE_90: {

        matrix.postRotate(90);

        break;
      }

      case ExifInterface.ORIENTATION_FLIP_HORIZONTAL: {

        matrix.preScale(-1.0f, 1.0f);

        break;
      }

      case ExifInterface.ORIENTATION_FLIP_VERTICAL: {

        matrix.preScale(1.0f, -1.0f);

        break;
      }

      case ExifInterface.ORIENTATION_TRANSPOSE: {

        matrix.preRotate(-90);
        matrix.preScale(-1.0f, 1.0f);

        break;
      }

      case ExifInterface.ORIENTATION_TRANSVERSE: {

        matrix.preRotate(90);
        matrix.preScale(-1.0f, 1.0f);

        break;
      }

    }

    return matrix;
  }
}
