import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../gitlab_client.dart';

/// User endpoints.
class UsersApi {
  const UsersApi(this._dio);

  final Dio _dio;

  /// The user the current token belongs to.
  ///
  /// Also the cheapest way to validate a token during sign-in.
  Future<User> current() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/user');
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the current user',
        );
      }
      return User.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the current user');
    }
  }
}
