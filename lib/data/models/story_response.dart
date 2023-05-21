import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_response.freezed.dart';

part 'story_response.g.dart';

StoryResponse storyResponseFromJson(String str) =>
    StoryResponse.fromJson(json.decode(str));

String storyResponseToJson(StoryResponse data) => json.encode(data.toJson());

@freezed
class StoryResponse with _$StoryResponse {
  const factory StoryResponse({
    required bool error,
    required String message,
    required List<ListStory> listStory,
  }) = _StoryResponse;

  factory StoryResponse.fromJson(Map<String, dynamic> json) =>
      _$StoryResponseFromJson(json);
}

@freezed
class ListStory with _$ListStory {
  const factory ListStory({
    required String id,
    required String name,
    required String description,
    required String photoUrl,
    required String createdAt,
    double? lat,
    double? lon,
  }) = _ListStory;

  factory ListStory.fromJson(Map<String, dynamic> json) =>
      _$ListStoryFromJson(json);
}
