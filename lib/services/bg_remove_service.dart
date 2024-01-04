import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';

final dio = Dio();

Future<ByteBuffer> makeImageTransparent(String imagePath) async {
  FormData formData = FormData.fromMap({
    "size": "auto",
    "image_file":
        await MultipartFile.fromFile(imagePath, filename: "upload.jpg"),
  });
  logger.i(imagePath);
  try {
    final response = await dio.post(
      "https://api.remove.bg/v1.0/removebg",
      options: Options(
        headers: {
          "X-Api-Key": "GmFovjpUGZBvtrk5rnyiZkPy",
        },
        responseType: ResponseType.bytes,
      ),
      data: formData,
    );

    return response.data.buffer;
  } catch (err) {
    if (err is DioException) {
      logger.e("Error from makeImageTransparent: ${err.response}");
      throw DioException(requestOptions: err.requestOptions);
    } else {
      logger.e("Error from makeImageTransparent string: $err");
      throw Exception(err);
    }
  }
}
