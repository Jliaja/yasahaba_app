import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef HeaderMap = Map<String, String>;
typedef JsonMap = Map<String, dynamic>;

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:8000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<HeaderMap> getHeaders({bool withAuth = true}) async {
    final HeaderMap headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(withAuth: withAuth),
    );
  }

  Future<http.Response> post(String endpoint, {JsonMap? body, bool withAuth = true}) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required HeaderMap fields,
    Map<String, File>? files,
    bool withAuth = true,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    request.headers['Accept'] = 'application/json';

    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields.addAll(fields);

    if (files != null) {
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
      }
    }

    return await request.send();
  }
}