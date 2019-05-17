package com.matas.image_feature_detector;

import org.opencv.core.CvType;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class GeomUtils {
    public static MatOfPoint toMatOfPointInt(MatOfPoint2f mat) {
        MatOfPoint matInt = new MatOfPoint();
        mat.convertTo(matInt, CvType.CV_32S);
        return matInt;
    }

    public static MatOfPoint2f toMatOfPointFloat(MatOfPoint mat) {
        MatOfPoint2f matFloat = new MatOfPoint2f();
        mat.convertTo(matFloat, CvType.CV_32FC2);
        return matFloat;
    }

    public static double angle(Point p1, Point p2, Point p0) {
        double dx1 = p1.x - p0.x;
        double dy1 = p1.y - p0.y;
        double dx2 = p2.x - p0.x;
        double dy2 = p2.y - p0.y;
        return (dx1 * dx2 + dy1 * dy2) / Math.sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
    }

    public static MatOfPoint2f scaleRectangle(MatOfPoint2f original, double scale) {
        List<Point> originalPoints = original.toList();
        List<Point> resultPoints = new ArrayList<Point>();

        for (Point point : originalPoints) {
            resultPoints.add(new Point(point.x * scale, point.y * scale));
        }

        MatOfPoint2f result = new MatOfPoint2f();
        result.fromList(resultPoints);
        return result;
    }

    public static String pointsToString(MatOfPoint2f rectangle) {
        StringBuilder builder = new StringBuilder();

        List<Point> points = rectangle.toList();
        Iterator<Point> iterator = points.iterator();

        while (iterator.hasNext()) {
            boolean isNotLast = iterator.hasNext();
            Point point = iterator.next();
            builder.append(point.toString());
            if (isNotLast) {
                builder.append(" ");
            }
        }

        return builder.toString();
    }
}