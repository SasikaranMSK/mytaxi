class ServerException implements Exception {
  ServerException({required String message}) : super();
}

class NotFoundException implements Exception {}

class BadRequestException implements Exception {}

class ClientException implements Exception {
  ClientException({required String? message}) : super();
}
