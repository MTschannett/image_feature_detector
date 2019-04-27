import './entity/contour.dart';
import 'entity/image_dimensions.dart';

class RelativeCoordianteHelper {
  static int calculateDistance(double relativeCoordinate, int axisLength) {
    return (relativeCoordinate * axisLength).round();
  }

  static Point calculatePointDinstances(
      Point relativeValues, ImageDimensions dimensions) {
    var temp = Point();

    temp.x = (relativeValues.x * dimensions.width).roundToDouble();
    temp.y = relativeValues.y * dimensions.height.roundToDouble();

    return temp;
  }
}
