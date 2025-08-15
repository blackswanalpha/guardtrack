import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.code,
  });
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.code,
  });
}

// Location failures
class LocationFailure extends Failure {
  const LocationFailure({
    required super.message,
    super.code,
  });
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({
    required super.message,
    super.code,
  });
}

class LocationAccuracyFailure extends Failure {
  const LocationAccuracyFailure({
    required super.message,
    super.code,
  });
}

class GeofenceFailure extends Failure {
  const GeofenceFailure({
    required super.message,
    super.code,
  });
}

// Camera failures
class CameraFailure extends Failure {
  const CameraFailure({
    required super.message,
    super.code,
  });
}

class CameraPermissionFailure extends Failure {
  const CameraPermissionFailure({
    required super.message,
    super.code,
  });
}

// Storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
  });
}
