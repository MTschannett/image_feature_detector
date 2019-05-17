package com.matas.image_feature_detector;


import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;

import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Scalar;

import java.io.IOException;

public class ImageUtils {
    public static Bitmap loadAndRotateImage(String path) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inPreferredConfig = Bitmap.Config.ARGB_8888;

        try {
            return ImageUtils.rotateImageAccordingToExif(BitmapFactory.decodeFile(path, options), path);
        } catch(IOException e) {
            return null;
        }
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

    public static Mat bitmapToMat(Bitmap bitmap) {
        Mat mat = new Mat(bitmap.getHeight(), bitmap.getWidth(), CvType.CV_8U, new Scalar(4));
        Bitmap bitmap32 = bitmap.copy(Bitmap.Config.ARGB_8888, true);
        Utils.bitmapToMat(bitmap32, mat);
        return mat;
    }

    public static Bitmap matToBitmap(Mat mat) {
        Bitmap bitmap = Bitmap.createBitmap(mat.cols(), mat.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(mat, bitmap);
        return bitmap;
    }
}
