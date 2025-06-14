import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/constants/constants.dart';
import 'dart:math';
import 'package:intl/intl.dart';

// add interceptor to dio for last "/"
class TrailingSlashInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String path = options.path;
    if (!path.endsWith('/')) {
      options.path = '$path/';
    }
    return super.onRequest(options, handler);
  }
}

final dio = Dio();

// get unique string for file name
String generateUniqueString() {
  // Create a random number generator
  final Random random = Random();
  String randomString =
      List.generate(10, (_) => random.nextInt(256).toRadixString(16)).join();
  String timestamp = DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
  return '$timestamp-$randomString';
}

class APIService {
  static Future<String> hostImage(File image) async {
    final imgBBKey = dotenv.env["IMG_BB_KEY"];
    var formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        image.path,
        filename: generateUniqueString(),
      ),
    });
    try {
      final response = await dio.post(
          "${Constants.imgbbUrl}?expiration=600&key=$imgBBKey",
          // queryParameters: {"expiration": 600, "key": dotenv.env["IMG_BB_KEY"]},
          data: formData,
          options: Options(contentType: "multipart/form-data"));

      return response.data["data"]["display_url"];
    } on DioException catch (err) {
      logger.e("Error from hostImage: ${err.response?.headers.map}",
          error: err);
      throw DioException(requestOptions: err.requestOptions);
    }
  }

  static Future<bool> sendWhatsappMessage({
    required String mobileNo,
    required String imageUrl,
  }) async {
    Dio dio = Dio();

    const String apiUrl =
        'https://api.ultramsg.com/instance85658/messages/image';
    final String apiToken = dotenv.env['ULTRAMSG_KEY']!;

    try {
      final response = await dio.post(
        apiUrl,
        data: {
          'token': apiToken,
          'to': mobileNo, // Include the complete phone number with country code
          'image': imageUrl, // URL of the image to send
          'caption': """
Dear parent,

Greetings, Your ward has reached shaheen Campus,  We are pleased to share a special photograph of your ward .

Warm regards,
Shaheen Group of Institutions
          """, // Caption to accompany the image
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Error from sendWhatsappMessage: ${response.data}");
        return false;
      }
    } on DioException catch (err) {
      print(
          "Error from catch block in sendWhatsappMessage: ${err.response?.statusCode}");
      print("Error data: ${err.response?.data}");
      return false;
    }
  }
}
