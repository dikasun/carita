import 'package:carita/data/network/api/api_service.dart';
import 'package:carita/data/network/api/dio_exception.dart';
import 'package:dio/dio.dart';

import '../models/base_response.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  Future<LoginResponse> loginAuth(String email, String password) async {
    try {
      final response = await apiService.loginAuth(email, password);
      return LoginResponse.fromJson(response.data);
    } on DioError catch (e) {
      final message = e.response != null
          ? BaseResponse.fromJson(e.response!.data).message
          : DioExceptions().fromDioError(e);
      throw message;
    }
  }

  Future<BaseResponse> registerAuth(
      String name, String email, String password) async {
    try {
      final response = await apiService.registerAuth(name, email, password);
      return BaseResponse.fromJson(response.data);
    } on DioError catch (e) {
      final message = e.response != null
          ? BaseResponse.fromJson(e.response!.data).message
          : DioExceptions().fromDioError(e);
      throw message;
    }
  }
}
