package com.matas.image_feature_detector;

import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class PointHelper {
  /**
   * Sorts points of the found contour.
   *
   * Sorting sequence is top left - top right - bottom right - bottom left;
   *
   * @param points Found points that assemble a rectangular contour
   *
   * @return a sorted list of points
   */
  public static List<Point> sortPoints(MatOfPoint2f points) {
    List<Point> unsorted = points.toList();
    ArrayList<Point> sortedPoints = new ArrayList<>(Collections.nCopies(4, new Point()));

    sortedPoints.set(0, PointHelper.getTopLeftPoint(unsorted));
    sortedPoints.set(2, PointHelper.getBottomRightPoint(unsorted));
    sortedPoints.set(1, PointHelper.getTopRightPoint(unsorted));
    sortedPoints.set(3, PointHelper.getBottomLeft(unsorted));

    return sortedPoints;
  }

  /**
   * Returns top left point of the list
   *
   * @param unsorted unsorted List of points
   *
   * @return Point
   */
  private static Point getTopLeftPoint(List<Point> unsorted) {
    return Collections.min(unsorted, new Comparator<Point>() {
      @Override
      public int compare(Point o1, Point o2) {
        double first = o1.x + o1.y;
        double second = o2.x + o2.y;

        if (first == second) return 0;

        return first < second ? -1 : 1;
      }
    });
  }

  /**
   * Returns bottom right point
   *
   * @param points unsorted List of points
   *
   * @return Point
   */
  private static Point getBottomRightPoint(List<Point> points) {
    return Collections.max(points, new Comparator<Point>() {
      @Override
      public int compare(Point o1, Point o2) {
        double first = o1.x + o1.y;
        double second = o2.x + o2.y;

        if (first == second) return 0;

        return first > second ? 1 : -1;
      }
    });
  }

  /**
   * Finds bottom left point in the list
   *
   * @param points unsorted list of points
   *
   * @return Point
   */
  private static Point getBottomLeft(List<Point> points) {
    return Collections.min(points, new Comparator<Point>() {
      @Override
      public int compare(Point o1, Point o2) {
        double first = o1.x - o1.y;
        double second = o2.x - o2.y;

        if (first == second) return 0;

        return first < second ? -1 : 1;
      }
    });
  }

  /**
   * Finds top right point of a rectangle contour
   *
   * @param points unsorted list of points
   *
   * @return Point
   */
  private static Point getTopRightPoint(List<Point> points) {
    return Collections.max(points, new Comparator<Point>() {
      @Override
      public int compare(Point o1, Point o2) {
        double first = o1.x - o1.y;
        double second = o2.x - o2.y;

        if (first == second) return 0;

        return first > second ? 1 : -1;
      }
    });
  }
}
