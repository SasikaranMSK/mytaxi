class ResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  const ResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJson,
  ) {
    final rawErrors = json['errors'];
    List<String>? parsedErrors;
    if (rawErrors is List) {
      parsedErrors = rawErrors
          .map<String>((e) {
            if (e == null) return '';
            if (e is String) return e;
            if (e is Map && e['message'] != null) {
              return e['message'].toString();
            }
            return e.toString();
          })
          .where((e) => e.isNotEmpty)
          .toList();
      if (parsedErrors.isEmpty) {
        parsedErrors = null;
      }
    }

    final rawData = json['data'];
    T? parsedData;
    if (rawData != null) {
      parsedData = fromJson(rawData);
    }

    return ResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: parsedData,
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }
}
