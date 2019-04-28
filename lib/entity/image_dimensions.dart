class ImageDimensions {
  final int height;
  final int width;

  ImageDimensions(this.height, this.width);

  ImageDimensions.fromJson(Map<String, dynamic> data)
      : height = data['height'],
        width = data['width'];
}
