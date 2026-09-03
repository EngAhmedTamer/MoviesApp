import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:movies_app/core/constants/api_constants.dart';

class DioClient {
  DioClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                // On Web, sendTimeout is only supported for requests with body
                sendTimeout: kIsWeb ? null : ApiConstants.sendTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Dio get client => _dio;
}
