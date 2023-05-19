import 'package:carita/data/models/story_detail_response.dart';
import 'package:carita/data/network/api/api_service.dart';
import 'package:dio/dio.dart';

import '../models/base_response.dart';
import '../models/story_response.dart';
import '../network/api/dio_exception.dart';

class StoryRepository {
  final ApiService apiService;

  StoryRepository({required this.apiService});

  Future<StoryResponse> fetchStories(String accessToken) async {
    try {
      final response = await apiService.getStories(accessToken);
      return StoryResponse.fromJson(response.data);
    } on DioError catch (e) {
      final message = e.response != null
          ? BaseResponse.fromJson(e.response!.data).message
          : DioExceptions().fromDioError(e);
      throw message;
    }
  }

  Future<StoryDetailResponse> fetchStoryDetails(
      String id, String accessToken) async {
    try {
      final response = await apiService.getStoryDetails(id, accessToken);
      return StoryDetailResponse.fromJson(response.data);
    } on DioError catch (e) {
      final message = e.response != null
          ? BaseResponse.fromJson(e.response!.data).message
          : DioExceptions().fromDioError(e);
      throw message;
    }
  }

  Future<BaseResponse> createStory(
    List<int> bytes,
    String fileName,
    String description,
    double? lat,
    double? long,
    String accessToken,
  ) async {
    try {
      final response = await apiService.createStory(
        bytes,
        fileName,
        description,
        lat,
        long,
        accessToken,
      );
      return BaseResponse.fromJson(response.data);
    } on DioError catch (e) {
      final message = e.response != null
          ? BaseResponse.fromJson(e.response!.data).message
          : DioExceptions().fromDioError(e);
      throw message;
    }
  }
}
