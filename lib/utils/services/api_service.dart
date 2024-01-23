import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:shaheen_selfie/utils/constants/constants.dart';

final dio = Dio();

class APIService {
  static Future<String> hostImage() async {
    try {
      final response = await dio.post(Constants.imgbbUrl, queryParameters: {
        "expiration": 600,
        "key": dotenv.env["IMG_BB_KEY"]
      });
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

//   static Future<bool> sendWhatsappMessage({required int mobileNo, required String imageUrl})async{

// try{
//   final response = dio.post(Constants.whatsappUrl,options: Options(
//     headers: {
//       "Authorization":
//     }
//   ));
// }

//   }
}
