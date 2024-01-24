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
    var formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        image.path,
        filename: generateUniqueString(),
      ),
    });
    try {
      final response = await dio.post(
        Constants.imgbbUrl,
        queryParameters: {"expiration": 600, "key": dotenv.env["IMG_BB_KEY"]},
        data: formData,
      );
      if (response.statusCode == HttpStatus.ok) {
        return response.data["data"]["display_url"];
      } else {
        throw DioException(requestOptions: response.requestOptions);
      }
    } on DioException catch (err) {
      logger.e("Error from hostImage: ${err.response?.data}", error: err);
      throw DioException(requestOptions: err.requestOptions);
    }
  }

  static Future<bool> sendWhatsappMessage(
      {required String mobileNo, required String imageUrl}) async {
    dio.interceptors.add(TrailingSlashInterceptor());
    try {
      final response = await dio.post(
        Constants.whatsappUrl,
        data: {
          "countryCode": "+91",
          "phoneNumber": mobileNo,
          "type": "Template",
          "template": {
            "name": "send_picture",
            "languageCode": "en",
            "headerValues": [
              imageUrl,
            ]
          }
        },
        options: Options(
          headers: {
            "Authorization": "Basic ${dotenv.env["INTERAKT_KEY"]}",
          },
        ),
      );
      if (response.statusCode == HttpStatus.created) {
        return true;
      } else {
        logger.e("Error from sendWhatsappMessage: ", error: response.data);
        return false;
      }
    } on DioException catch (err) {
      logger.e(
          "Error from catch block in sendWhatsAppMessage: status code: ${err.response!.statusCode} ",
          error: err.response?.data);
      return false;
    }
  }
}
