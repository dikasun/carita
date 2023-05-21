import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_response.g.dart';
part 'base_response.freezed.dart';

BaseResponse baseResponseFromJson(String str) =>
    BaseResponse.fromJson(json.decode(str));

String baseResponseToJson(BaseResponse data) => json.encode(data.toJson());

@freezed
class BaseResponse with _$BaseResponse {
  const factory BaseResponse({
    required bool error,
    required String message,
  }) = _BaseResponse;

  factory BaseResponse.fromJson(Map<String, dynamic> json) => _$BaseResponseFromJson(json);
}
