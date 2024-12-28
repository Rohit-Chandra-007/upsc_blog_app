class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class UnknownException implements Exception {
  final String message;
  UnknownException({required this.message});
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException({required this.message});
}

 