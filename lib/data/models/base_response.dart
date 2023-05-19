import 'dart:convert';

BaseResponse baseResponseFromJson(String str) =>
    BaseResponse.fromJson(json.decode(str));

String baseResponseToJson(BaseResponse data) => json.encode(data.toJson());

class BaseResponse {
  BaseResponse({
    required this.error,
    required this.message,
  });

  bool error;
  String message;

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
        error: json["error"] as bool,
        message: json["message"] as String,
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
      };
}
