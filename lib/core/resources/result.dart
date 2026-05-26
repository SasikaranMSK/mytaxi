class Result<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<ErrorDetail> errors;

  Result({
    required this.success,
    this.message,
    this.data,
    this.errors = const [],
  });

  factory Result.error(String errorMessage) {
    return Result<T>(
      success: false,
      message: errorMessage,
      data: null,
      errors: const [],
    );
  }
}

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
}
