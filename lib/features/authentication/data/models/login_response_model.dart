import 'auth_model.dart';

class ErrorDetail {
  final String tag;
  final String message;
  final int type;
  final String typeName;

  ErrorDetail({
    required this.tag,
    required this.message,
    required this.type,
    required this.typeName,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      tag: json['tag'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 0,
      typeName: json['typeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'message': message,
      'type': type,
      'typeName': typeName,
    };
  }
}

class LoginResponseModel {
  final bool success;
  final String? message;
  final AuthModel? data;
  final List<ErrorDetail>? errors;

  LoginResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? AuthModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null
          ? List<ErrorDetail>.from(
              json['errors'].map((error) => ErrorDetail.fromJson(error)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors != null
          ? errors!.map((error) => error.toJson()).toList()
          : [],
    };
  }
}
