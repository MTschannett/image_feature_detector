import 'package:image_feature_detector/entity/contour.dart';

/// Holds information about the found features (which were used to transform the image) and the new file path
class TransformedImage {
  final Contour foundFeatures;
  final String filePath;

  TransformedImage(this.foundFeatures, this.filePath);

  TransformedImage.fromJson(Map<String, dynamic> data)
      : filePath = data['filePath'],
        foundFeatures = Contour.fromJson(data['foundFeatures']);
}
