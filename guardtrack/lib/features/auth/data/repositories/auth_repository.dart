import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../../shared/models/user_model.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login(LoginRequest request);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthUser>> refreshToken();
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Future<Either<Failure, void>> saveAuthUser(AuthUser user);
  Future<Either<Failure, void>> clearAuthData();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SecureStorageService _storageService;

  AuthRepositoryImpl({
    required ApiService apiService,
    required SecureStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  @override
  Future<Either<Failure, AuthUser>> login(LoginRequest request) async {
    try {
      final response = await _apiService.post('/auth/login', data: request.toJson());
      
      final loginResponse = LoginResponse.fromJson(response);
      
      final authUser = AuthUser(
        user: loginResponse.user,
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        tokenExpiresAt: loginResponse.tokenExpiresAt,
      );

      // Save auth data to secure storage
      await _saveAuthUser(authUser);
      
      // Set token in API service
      _apiService.setAuthToken(loginResponse.accessToken);

      return Right(authUser);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Call logout endpoint
      await _apiService.post('/auth/logout');
      
      // Clear local auth data
      await _clearAuthData();
      
      // Clear token from API service
      _apiService.clearAuthToken();

      return const Right(null);
    } on NetworkException catch (e) {
      // Even if network call fails, clear local data
      await _clearAuthData();
      _apiService.clearAuthToken();
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      // Even if server call fails, clear local data
      await _clearAuthData();
      _apiService.clearAuthToken();
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      // Even if unexpected error, clear local data
      await _clearAuthData();
      _apiService.clearAuthToken();
      return Left(ServerFailure(message: 'Logout error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthenticationFailure(message: 'No refresh token found'));
      }

      final response = await _apiService.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final loginResponse = LoginResponse.fromJson(response);
      
      final authUser = AuthUser(
        user: loginResponse.user,
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        tokenExpiresAt: loginResponse.tokenExpiresAt,
      );

      // Save updated auth data
      await _saveAuthUser(authUser);
      
      // Update token in API service
      _apiService.setAuthToken(loginResponse.accessToken);

      return Right(authUser);
    } on AuthenticationException catch (e) {
      // Clear auth data if refresh fails
      await _clearAuthData();
      _apiService.clearAuthToken();
      return Left(AuthenticationFailure(message: e.message, code: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Token refresh error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final token = await _storageService.getToken();
      final refreshToken = await _storageService.getRefreshToken();
      final userData = await _storageService.getUserData();

      if (token == null || refreshToken == null || userData == null) {
        return const Right(null);
      }

      final user = UserModel.fromJson(userData);
      
      // TODO: Get token expiry from storage or decode JWT
      final tokenExpiresAt = DateTime.now().add(const Duration(hours: 1));
      
      final authUser = AuthUser(
        user: user,
        accessToken: token,
        refreshToken: refreshToken,
        tokenExpiresAt: tokenExpiresAt,
      );

      // Set token in API service
      _apiService.setAuthToken(token);

      return Right(authUser);
    } on StorageException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error getting current user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAuthUser(AuthUser user) async {
    try {
      await _saveAuthUser(user);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error saving auth user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAuthData() async {
    try {
      await _clearAuthData();
      _apiService.clearAuthToken();
      return const Right(null);
    } on StorageException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error clearing auth data: $e'));
    }
  }

  // Private helper methods
  Future<void> _saveAuthUser(AuthUser user) async {
    await _storageService.saveToken(user.accessToken);
    await _storageService.saveRefreshToken(user.refreshToken);
    await _storageService.saveUserData(user.user.toJson());
  }

  Future<void> _clearAuthData() async {
    await _storageService.clearToken();
    await _storageService.clearRefreshToken();
    await _storageService.clearUserData();
  }
}
