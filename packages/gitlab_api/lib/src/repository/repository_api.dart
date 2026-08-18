import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';
import 'repository_file.dart';

/// Repository tree and file endpoints.
class RepositoryApi {
  const RepositoryApi(this._dio);

  final Dio _dio;

  /// Lists a directory of the tree on a ref.
  ///
  /// [path] is a directory path, empty for the root. Results are sorted
  /// folders-first. Pagination is by page number; the next cursor comes from
  /// the response headers.
  Future<Paginated<RepositoryEntry>> tree(
    Object projectId, {
    required String ref,
    String path = '',
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/tree',
        queryParameters: {
          'ref': ref,
          if (path.isNotEmpty) 'path': path,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing the tree',
        );
      }
      final entries =
          (response.data as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(RepositoryEntry.fromJson)
              .toList()
            ..sort(RepositoryEntry.compare);
      return Paginated.fromHeaders(entries, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing the tree');
    }
  }

  /// The contents of a file on a ref, or null when it does not exist.
  Future<RepositoryFile?> fileText(
    Object projectId, {
    required String path,
    required String ref,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        // The whole path is one URL segment, so its slashes are encoded.
        '/projects/${_enc(projectId)}/repository/files/${Uri.encodeComponent(path)}/raw',
        queryParameters: {'ref': ref},
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 404) {
        return null;
      }
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading the file',
        );
      }
      final bytes = Uint8List.fromList(response.data ?? const []);
      return RepositoryFile.fromBytes(bytes);
    } on DioException catch (error) {
      throw mapError(error, context: 'reading the file');
    }
  }

  /// Lists the repository's branches.
  Future<Paginated<Branch>> branches(
    Object projectId, {
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/branches',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing branches',
        );
      }
      final branches = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Branch.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(branches, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing branches');
    }
  }

  /// Lists commits on a ref, most recent first.
  Future<Paginated<Commit>> commits(
    Object projectId, {
    required String ref,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/commits',
        queryParameters: {'ref_name': ref, 'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing commits',
        );
      }
      final commits = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Commit.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(commits, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing commits');
    }
  }

  /// A single commit by SHA, including its line-change stats.
  Future<Commit> commit(Object projectId, {required String sha}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/repository/commits/${Uri.encodeComponent(sha)}',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the commit',
        );
      }
      return Commit.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the commit');
    }
  }

  /// The files changed by a commit, as parsed diffs.
  Future<List<FileDiff>> commitDiff(
    Object projectId, {
    required String sha,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/repository/commits/${Uri.encodeComponent(sha)}/diff',
        // unidiff=true returns the diff in unified format, the grammar
        // parseUnifiedDiff accepts. The default (false) is not guaranteed to be
        // that format. Older instances ignore the unknown parameter.
        queryParameters: {'unidiff': true},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the diff',
        );
      }
      return (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(FileDiff.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the diff');
    }
  }

  /// Encodes a project id: numeric ids pass through, `group/project` paths are
  /// URL-encoded.
  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
