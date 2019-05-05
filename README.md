# image_feature_detector

A image feature detector using opencv for IOs and Android.

This plugin uses native versions of OpenCV to detect shapes in given images.

## What does it do?

For now it only detects rectangles in given images. It uses native implementations for both IOs and Android for this task.

## Usage

To use this package add following import to your file:

```dart
import 'package:image_feature_detector/image_feature_detector.dart';
```

The API for this package is fairly simple. We can only detect rectangles for now.

If you need more functionalities, feel free to contribute or open an issue in the code repository.

To detect a rectangle in an image save it to a local file and call the `ImageFeatureDetector`:

```dart
var rectangle = ImageFeatureDetector.detectRectangles(_filePath);

// Access the points of the contour
rectangle.contour[0].x; // Access X
rectangle.contour[0].y; // Access the y value.
```

To detect and transform the image into a normalized image use following api:

```dart
var imageData = ImageFeatureDetector.detectAndTransformRectangle(_filePath);
```

### Quick Aside: Relative Coordiantes

To be as size independent as possible this package uses relative coordinates. 

Absolute coordinates would look likes this:

```dart
// This values are in Pixels.
var p = Point(x: 25, y: 25); 
```

This coordinates are only correct for the original width and height of the image.

If it gets scaled for some reason the above point won't be correct anymore.

To work around this we use relative coordinates. These are values between 0 and 1.

```dart
// Would be 25 in a image width 500 width or height
var relativePoint = Point(x: 0.05, y: 0.05);
```

## RelativeCoordianteHelper

To revert the relative coordinates back to absolute values we can use this helper.

### Usage

We have to easy methods. One for calculating a single value another for calculating a whole Point.

Calculating one point:
```dart
var p = Point(x: 0.05, y: 0.05);
var absoluteX = RelativeCoordianteHelper.calculateDistance(p.x, 500); // p.x = 0.05

// absolute value would be 25
```

Calculating a whole point:
```dart
var absolutePoint = RelativeCoordianteHelper.calculatePointDinstances(
          Point(x: 0.05, y: 0.05), ImageDimensions(500, 500));

// Result Point -> x = 25; y = 25;
```
