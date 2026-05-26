import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../storage/token_storage.dart';
import '../utils/log_utils.dart';
import '../widgets/popup_message_view.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late Dio _dio;
  static const String baseUrl = ApiConstants.apiBaseURL;
  final TokenStorage _tokenStorage;

  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 50000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            final fullUrl = '${options.baseUrl}${options.path}';
            final queryString = options.queryParameters.entries
                .map(
                  (e) =>
                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
                )
                .join('&');
            final fullRequestUrl = queryString.isNotEmpty
                ? '$fullUrl?$queryString'
                : fullUrl;

            print('Request URL: $fullRequestUrl');
            print('Request Method: ${options.method}');
            print('Request Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('Response Code: ${response.statusCode}');
            LoggingUtil.logDebug('ApiClient: Response Data: ${response.data}');
            // print('Response Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('Error: ${e.type}, ${e.message}');
            if (e.response != null) {
              print('Error Response: ${e.response?.data}');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void showDialog(BuildContext context, String title, String content) {
    unawaited(showErrorPopup(context, message: content, title: title));
  }

  Future<dynamic> _handleRequest(
    Future<Response> Function() requestFunction,
    BuildContext context,
  ) async {
    try {
      final response = await requestFunction();
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        if (!context.mounted) return null;
        _handleErrorResponse(response.data, context);
        return null;
      }
    } on DioException catch (e) {
      if (!context.mounted) return null;
      _handleDioException(e, context);
      return null;
    } catch (e) {
      if (!context.mounted) return null;
      showDialog(context, 'Error', 'An unexpected error occurred');
      return null;
    }
  }

  Future<dynamic> _handleRequest2(
    Future<Response> Function() requestFunction,
  ) async {
    try {
      final response = await requestFunction();
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        return _handleErrorResponse2(response.data);
      }
    } on DioException catch (e) {
      return _handleDioException2(e);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return {'error': 'An unexpected error occurred'};
    }
  }

  void _handleErrorResponse(dynamic responseData, BuildContext context) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('errors') &&
          responseData['errors'] is List) {
        final errors = responseData['errors'] as List;
        if (errors.isNotEmpty) {
          final error = errors.first;
          showDialog(
            context,
            error['tag'] ?? 'Error',
            error['message'] ?? 'No details available.',
          );
        }
      } else if (responseData.containsKey('message')) {
        showDialog(
          context,
          'Error',
          responseData['message'] ?? 'An error occurred',
        );
      } else {
        showDialog(context, 'Error', 'An unexpected error occurred');
      }
    } else {
      showDialog(context, 'Error', 'An unexpected error occurred');
    }
  }

  void _handleErrorResponse2(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('errors') &&
          responseData['errors'] is List) {
        final errors = responseData['errors'] as List;
        if (errors.isNotEmpty) {
          final error = errors.first;
          debugPrint(
            'Error: ${error['tag'] ?? 'Error'} - ${error['message'] ?? 'No details available.'}',
          );
        }
      } else if (responseData.containsKey('message')) {
        debugPrint('Error Message: ${responseData['message']}');
      } else {
        debugPrint('Unexpected error structure: $responseData');
      }
    } else {
      debugPrint('Unexpected error format: $responseData');
    }
  }

  void _handleDioException(DioException e, BuildContext context) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        showDialog(
          context,
          'Connection Error',
          'The connection timed out. Please check your internet connection and try again.',
        );
        break;
      case DioExceptionType.connectionError:
        showDialog(
          context,
          'Connection Error',
          'Unable to connect to the server. Please check your internet connection and try again.',
        );
        break;
      case DioExceptionType.badResponse:
        _handleErrorResponse(e.response?.data, context);
        break;
      default:
        showDialog(
          context,
          'Error',
          'An unexpected error occurred. Please try again later.',
        );
    }
  }

  void _handleDioException2(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        debugPrint(
          'Connection timed out. Please check your internet connection and try again.',
        );
        break;

      case DioExceptionType.connectionError:
        debugPrint(
          'Unable to connect to the server. Please check your internet connection and try again.',
        );
        break;

      case DioExceptionType.badResponse:
        _handleErrorResponse2(e.response?.data);
        break;

      default:
        debugPrint('An unexpected error occurred. Please try again later.');
    }
  }

  Future<dynamic> getRequest(
    String path,
    Map<String, dynamic>? queryParameters,
    BuildContext? context,
  ) async {
    return _handleRequest2(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> getRequestWithError(
    String path,
    Map<String, dynamic>? queryParameters,
    BuildContext context,
  ) async {
    return _handleRequest(
      () => _dio.get(path, queryParameters: queryParameters),
      context,
    );
  }

  Future<dynamic> postRequest(
    String path,
    Object? data,
    BuildContext context,
  ) async {
    return _handleRequest(() => _dio.post(path, data: data), context);
  }

  Future<dynamic> putRequest(
    String path,
    Object? data,
    BuildContext context,
  ) async {
    return _handleRequest(() => _dio.put(path, data: data), context);
  }

  Future<dynamic> deleteRequest(String path, BuildContext context) async {
    return _handleRequest(() => _dio.delete(path), context);
  }
}
