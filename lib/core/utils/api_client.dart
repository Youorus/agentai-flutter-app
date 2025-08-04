import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/config/api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async => await _storage.read(key: 'access_token');

  // POST
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool auth = false,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final defaultHeaders = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (headers != null) defaultHeaders.addAll(headers);
    if (auth) {
      final token = await getToken();
      if (token != null) defaultHeaders['Authorization'] = 'Bearer $token';
    }

    return await http.post(
      url,
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // GET
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    bool auth = false,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final defaultHeaders = {
      "Accept": "application/json",
    };
    if (headers != null) defaultHeaders.addAll(headers);
    if (auth) {
      final token = await getToken();
      if (token != null) defaultHeaders['Authorization'] = 'Bearer $token';
    }

    return await http.get(
      url,
      headers: defaultHeaders,
    );
  }

  // PATCH (ajoutée pour les updates partiels)
  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool auth = false,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final defaultHeaders = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (headers != null) defaultHeaders.addAll(headers);
    if (auth) {
      final token = await getToken();
      if (token != null) defaultHeaders['Authorization'] = 'Bearer $token';
    }

    return await http.patch(
      url,
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}