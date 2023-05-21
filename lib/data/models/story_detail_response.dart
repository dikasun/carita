import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_detail_response.freezed.dart';

part 'story_detail_response.g.dart';

StoryDetailResponse storyDetailResponseFromJson(String str) =>
    StoryDetailResponse.fromJson(json.decode(str));

String storyDetailResponseToJson(StoryDetailResponse data) =>
    json.encode(data.toJson());

@freezed
class StoryDetailResponse with _$StoryDetailResponse {
  const factory StoryDetailResponse({
    required bool error,
    required String message,
    required Story story,
  }) = _StoryDetailResponse;

  factory StoryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailResponseFromJson(json);
}

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String name,
    required String description,
    required String photoUrl,
    required String createdAt,
    double? lat,
    double? lon,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}
