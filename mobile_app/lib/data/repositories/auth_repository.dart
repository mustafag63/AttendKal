import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import '../models/user.dart';
import '../remote/dio_client.dart';
import '../../core/error/exceptions.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw ExceptionMapper.fromDioException(e);
      }
      throw NetworkException('Unknown error occurred during registration');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Store token
      await _dioClient.setToken(authResponse.accessToken);

      return authResponse;
    } catch (e) {
      if (e is DioException) {
        throw ExceptionMapper.fromDioException(e);
      }
      throw NetworkException('Unknown error occurred during login');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw ExceptionMapper.fromDioException(e);
      }
      throw NetworkException('Unknown error occurred while fetching user');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/auth/logout');
    } catch (e) {
      // Even if logout fails on server, clear local token
    } finally {
      await _dioClient.clearToken();
    }
  }

  Future<void> refreshToken() async {
    try {
      final response = await _dioClient.dio.post('/auth/refresh');
      final authResponse = AuthResponse.fromJson(response.data);
      await _dioClient.setToken(authResponse.accessToken);
    } catch (e) {
      // If refresh fails, clear token
      await _dioClient.clearToken();
      if (e is DioException) {
        throw ExceptionMapper.fromDioException(e);
      }
      throw NetworkException('Unknown error occurred during token refresh');
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
