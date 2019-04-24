import './entity/contour.dart';

class ImageDimensions {
  final int height;
  final int width;

  ImageDimensions(this.height, this.width);
}

class RelativeCoordianteHelper {
  static double calculateDistance(
      double relativeCoordinate, double axisLength) {
    return relativeCoordinate * axisLength;
  }

  static Point calculatePointDinstances(
      Point relativeValues, ImageDimensions dimensions) {
    var temp = Point();

    temp.x = relativeValues.x * dimensions.width;
    temp.y = relativeValues.y * dimensions.height;

    return temp;
  }
}
