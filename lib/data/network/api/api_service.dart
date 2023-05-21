import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  static const Duration _connectionTimeout = Duration(seconds: 180);
  static const Duration _receiveTimeout = Duration(seconds: 180);

  static const String _baseUrl = 'https://story-api.dicoding.dev/v1/';
  static const String _login = 'login';
  static const String _register = 'register';
  static const String _stories = 'stories';

  ApiService(this._dio) {
    _dio
      ..options.baseUrl = _baseUrl
      ..interceptors.add(LogInterceptor(responseBody: true))
      ..options.connectTimeout = _connectionTimeout
      ..options.receiveTimeout = _receiveTimeout;
  }

  Future<dynamic> loginAuth(String email, String password) async {
    try {
      final response = await _dio.request(
        _login,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(method: 'POST'),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> registerAuth(
      String name, String email, String password) async {
    try {
      final response = await _dio.request(
        _register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(method: 'POST'),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createStory(
    List<int> bytes,
    String fileName,
    String description,
    double? lat,
    double? long,
    String accessToken,
  ) async {
    try {
      final formData = FormData.fromMap({
        'description': description,
        'photo': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
        if (lat != null) 'lat': lat,
        if (long != null) 'lon': long,
      });

      final response = await _dio.request(
        _stories,
        data: formData,
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getStories(
    String accessToken,
    int? pageItems,
    int sizeItems,
    int location,
  ) async {
    try {
      final response = await _dio.request(
        _stories,
        queryParameters: {
          'page': pageItems,
          'size': sizeItems,
          'location': location,
        },
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getStoryDetails(
    String id,
    String accessToken,
  ) async {
    try {
      final response = await _dio.request(
        '$_stories/$id',
        options: Options(
          method: 'GET',
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
