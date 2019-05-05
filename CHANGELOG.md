## 0.2.1
- **Objective C**: added helper to work with points to sort them and refactored opencvwrapper to be able to reuse contour logic for transformation
- **Java**: refactored Opencvwrapper for upcomming image perspective wrapping function, started to add points helper to get list of points sorte
- **General**: new Api has been added: `detectAndTransformRectangle`. 

## 0.2.0
- refactored image detection on java side to work with real images and fixed a logic bug, which found bigger objects that werent rectangles in the end
- lifted the objective c code to the same functionality as the java side

## 0.1.1

Added longer description to pubspec and other fixes from pub

## 0.1.0

This is the initial release fo this package

### Features
* Added `detectRectangles` to `ImageFeatureDetector`
* Added `getVersionString`to `ImageFeatureDetector`
* Added `RelativeCoordianteHelper` to Plugin
* Added example for basic usage.
