import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';

Future<ByteBuffer> removeGreenShades(String imagePath) async {
  Image image = decodeImage(File(imagePath).readAsBytesSync())!;

  int minX = image.width, maxX = 0, minY = image.height, maxY = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      Pixel pixel = image.getPixel(x, y);
      num red = pixel.r;
      num green = pixel.g;
      num blue = pixel.b;

      if (isShadeOfGreen(red, green, blue)) {
        image.setPixelRgba(x, y, red, 0, blue, 0); // Set to transparent
      } else {
        // Update bounding box coordinates
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Crop the image to the bounding box
  Image croppedImage = copyCrop(image,
      x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);

  // Encode the cropped image to PNG
  List<int> png = encodePng(croppedImage);

  return Uint8List.fromList(png).buffer;
}

bool isShadeOfGreen(num red, num green, num blue) {
  // Define your logic to determine if a color is a shade of green
  return green > red && green > blue;
}
