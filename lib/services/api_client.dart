import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode)';
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  static const _timeout = Duration(seconds: 20);
  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path');

  Future<List<Project>> getProjects() async {
    final response = await _client
        .get(
          _uri('/api/v1/projects/'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client
        .post(
          _uri('/api/v1/projects/'),
          headers: {..._jsonHeaders, 'Authorization': 'Token $token'},
          body: jsonEncode(project.toJson()),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    return Project.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client
        .post(
          _uri('/api/v1/auth/token/'),
          headers: _jsonHeaders,
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final token = decoded['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Token tidak valid.');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    final response = await _client
        .post(
          _uri('/api/v1/auth/logout/'),
          headers: {..._jsonHeaders, 'Authorization': 'Token $token'},
        )
        .timeout(_timeout);
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw ApiException(response.statusCode, utf8.decode(response.bodyBytes));
  }

  void close() => _client.close();
}

/// Keep HTML error pages and server internals out of the interface.
String apiErrorMessage(Object error) {
  if (error is ApiException) {
    return switch (error.statusCode) {
      400 =>
        'Data tidak valid. Periksa isian atau username dan password (400).',
      401 => 'Sesi berakhir. Silakan login kembali (401).',
      403 =>
        'Hanya superuser pemilik portofolio yang dapat menyimpan proyek (403).',
      404 => 'Endpoint API tidak ditemukan. Periksa alamat backend (404).',
      _ =>
        'Server gagal memproses permintaan (${error.statusCode}). Coba lagi.',
    };
  }
  if (error is TimeoutException) {
    return 'Server terlalu lama merespons. Coba lagi.';
  }
  if (error is FormatException || error is TypeError) {
    return 'Format data dari server tidak sesuai.';
  }
  return 'Tidak dapat menghubungi server. Periksa koneksi dan alamat backend.';
}
