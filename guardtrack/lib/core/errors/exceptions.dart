class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    required this.message,
  });

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    required this.message,
  });

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  const ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  final int? statusCode;

  const AuthenticationException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

class LocationException implements Exception {
  final String message;

  const LocationException({
    required this.message,
  });

  @override
  String toString() => 'LocationException: $message';
}

class LocationPermissionException implements Exception {
  final String message;

  const LocationPermissionException({
    required this.message,
  });

  @override
  String toString() => 'LocationPermissionException: $message';
}

class CameraException implements Exception {
  final String message;

  const CameraException({
    required this.message,
  });

  @override
  String toString() => 'CameraException: $message';
}

class CameraPermissionException implements Exception {
  final String message;

  const CameraPermissionException({
    required this.message,
  });

  @override
  String toString() => 'CameraPermissionException: $message';
}

class StorageException implements Exception {
  final String message;

  const StorageException({
    required this.message,
  });

  @override
  String toString() => 'StorageException: $message';
}

class DatabaseException implements Exception {
  final String message;

  const DatabaseException({
    required this.message,
  });

  @override
  String toString() => 'DatabaseException: $message';
}
