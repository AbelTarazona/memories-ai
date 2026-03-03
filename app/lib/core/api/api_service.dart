import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final Dio _dio;

  /// Create a new [ApiService] instance with a configurable [baseUrl].
  /// This makes the service reusable for multiple APIs by injecting different URLs.
  ApiService({required String baseUrl, Map<String, String>? headers})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            if (headers != null) ...headers, // allows custom headers
          },
        ),
      ) {
    // Add interceptors (logging, error handling, etc.)
    _dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Example: force logout or refresh token
          }
          return handler.next(e);
        },
      ),
    ]);
  }

  // Allow updating the base URL dynamically
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    final resp = await _dio.get(path, queryParameters: queryParameters);
    return parser != null ? parser(resp.data) : resp.data as T;
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
    Options? options,
  }) async {
    final resp = await _dio.post(path, data: data, options: options);
    return parser != null ? parser(resp.data) : resp.data as T;
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    final resp = await _dio.put(path, data: data);
    return parser != null ? parser(resp.data) : resp.data as T;
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    final resp = await _dio.patch(path, data: data);
    return parser != null ? parser(resp.data) : resp.data as T;
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    final resp = await _dio.delete(path, data: data);
    return parser != null ? parser(resp.data) : resp.data as T;
  }

  Future postMultipart({
    required String endpoint,
    required String filePath,
    required Map<String, String> additionalFields,
  }) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      ...additionalFields,
    });

    final response = await _dio.post(endpoint, data: formData);
    return response;
  }

  Future<Response> postMultipartBytes({
    required String endpoint,
    required Uint8List bytes,
    required String filename,
    Map<String, dynamic>? additionalFields,
    String? mimeType, // ej: "image/png", "application/pdf"
  }) async {
    final file = MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );

    final formData = FormData.fromMap({
      'file': file,
      if (additionalFields != null) ...additionalFields,
    });

    return _dio.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

}
