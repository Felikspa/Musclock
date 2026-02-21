import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 知晓云 REST API 客户端
/// 用于与知晓云 BaaS 平台进行数据交互
class MinAppClient {
  static const String _baseUrl = 'https://api.minapp.com/api';
  
  final String clientId;
  final String clientSecret;
  String? _accessToken;
  
  final http.Client _httpClient;
  final FlutterSecureStorage _storage;
  
  // Token 存储键
  static const String _tokenKey = 'minapp_access_token';
  static const String _userIdKey = 'minapp_user_id';
  
  MinAppClient({
    required this.clientId,
    required this.clientSecret,
    http.Client? httpClient,
    FlutterSecureStorage? storage,
  }) : _httpClient = httpClient ?? http.Client(),
       _storage = storage ?? const FlutterSecureStorage();

  /// 获取当前 accessToken
  String? get accessToken => _accessToken;
  
  /// 是否已登录
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  /// 初始化客户端，从本地存储恢复 token
  Future<void> initialize() async {
    _accessToken = await _storage.read(key: _tokenKey);
  }

  /// 设置 accessToken
  void setAccessToken(String token, {String? userId}) {
    _accessToken = token;
    _storage.write(key: _tokenKey, value: token);
    if (userId != null) {
      _storage.write(key: _userIdKey, value: userId);
    }
  }

  /// 获取当前用户ID
  Future<String?> getCurrentUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// 清除登录状态
  Future<void> clearAuth() async {
    _accessToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }

  // ============ 用户认证相关 API ============

  /// 用户注册
  /// 文档参考: https://doc.minapp.com/user/Wechat_LOGIN/
  Future<AuthResult> register({
    required String email,
    required String password,
    String? username,
  }) async {
    final response = await _post(
      '/user/register/',
      body: {
        'username': username ?? email,
        'email': email,
        'password': password,
      },
    );
    
    if (response.containsKey('id')) {
      final userId = response['id'].toString();
      // 注册后自动登录
      return await login(email: email, password: password);
    }
    
    throw AuthException(response['error'] ?? '注册失败');
  }

  /// 用户登录
  /// 文档参考: https://doc.minapp.com/user/Wechat_LOGIN/
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // 知晓云使用 Basic Auth 进行登录
    final credentials = base64Encode(utf8.encode('$email:$password'));
    
    final response = await _post(
      '/user/login/',
      headers: {
        'Authorization': 'Basic $credentials',
      },
      body: {
        'client_id': clientId,
      },
    );
    
    if (response.containsKey('token')) {
      final token = response['token'] as String;
      final userId = response['id']?.toString() ?? '';
      
      setAccessToken(token, userId: userId);
      
      return AuthResult(
        userId: userId,
        token: token,
        email: email,
      );
    }
    
    throw AuthException(response['error'] ?? '登录失败');
  }

  /// 用户登出
  Future<void> logout() async {
    if (_accessToken != null) {
      try {
        await _post(
          '/user/logout/',
          authenticated: true,
        );
      } catch (e) {
        // 即使 API 调用失败，也清除本地状态
        debugPrint('Logout API error: $e');
      }
    }
    await clearAuth();
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _get('/user/me/', authenticated: true);
  }

  // ============ 数据表 CRUD 操作 ============

  /// 查询数据表记录
  /// 文档参考: https://doc.minapp.com/js-sdk/schema/
  Future<QueryResult> queryTable({
    required String tableName,
    Map<String, dynamic>? where,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (where != null && where.isNotEmpty) {
      queryParams['where'] = jsonEncode(where);
    }
    if (orderBy != null) {
      queryParams['order_by'] = orderBy;
    }
    if (limit != null) {
      queryParams['limit'] = limit;
    }
    if (offset != null) {
      queryParams['offset'] = offset;
    }
    
    final response = await _get(
      '/hserve/v2/table/$tableName/record/',
      queryParams: queryParams,
      authenticated: true,
    );
    
    return QueryResult.fromJson(response);
  }

  /// 创建数据表记录
  Future<CloudRecord> createRecord({
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    final response = await _post(
      '/hserve/v2/table/$tableName/record/',
      body: data,
      authenticated: true,
    );
    
    return CloudRecord.fromJson(response);
  }

  /// 更新数据表记录
  Future<CloudRecord> updateRecord({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _put(
      '/hserve/v2/table/$tableName/record/$recordId/',
      body: data,
      authenticated: true,
    );
    
    return CloudRecord.fromJson(response);
  }

  /// 删除数据表记录
  Future<void> deleteRecord({
    required String tableName,
    required String recordId,
  }) async {
    await _delete(
      '/hserve/v2/table/$tableName/record/$recordId/',
      authenticated: true,
    );
  }

  /// 获取单条记录
  Future<CloudRecord> getRecord({
    required String tableName,
    required String recordId,
  }) async {
    final response = await _get(
      '/hserve/v2/table/$tableName/record/$recordId/',
      authenticated: true,
    );
    
    return CloudRecord.fromJson(response);
  }

  // ============ HTTP 私有方法 ============

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParams,
    bool authenticated = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
    final headers = await _buildHeaders(authenticated: authenticated);
    
    final response = await _httpClient.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool authenticated = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final requestHeaders = await _buildHeaders(authenticated: authenticated);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
    
    final response = await _httpClient.post(
      uri,
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _buildHeaders(authenticated: authenticated);
    
    final response = await _httpClient.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _delete(
    String path, {
    bool authenticated = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _buildHeaders(authenticated: authenticated);
    
    final response = await _httpClient.delete(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, String>> _buildHeaders({bool authenticated = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'client_id': clientId,
    };
    
    if (authenticated && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    
    final errorMsg = body['error'] ?? body['message'] ?? 'Unknown error';
    throw ApiException(
      message: errorMsg.toString(),
      statusCode: response.statusCode,
    );
  }
}

// ============ 数据模型 ============

/// 认证结果
class AuthResult {
  final String userId;
  final String token;
  final String email;
  String? username;

  AuthResult({
    required this.userId,
    required this.token,
    required this.email,
    this.username,
  });
}

/// 查询结果
class QueryResult {
  final List<CloudRecord> records;
  final int totalCount;
  final int limit;
  final int offset;

  QueryResult({
    required this.records,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  factory QueryResult.fromJson(Map<String, dynamic> json) {
    final objects = json['objects'] as List<dynamic>? ?? [];
    return QueryResult(
      records: objects.map((e) => CloudRecord.fromJson(e as Map<String, dynamic>)).toList(),
      totalCount: json['meta']?['total_count'] as int? ?? objects.length,
      limit: json['meta']?['limit'] as int? ?? 20,
      offset: json['meta']?['offset'] as int? ?? 0,
    );
  }
}

/// 云端记录
class CloudRecord {
  final String id;
  final Map<String, dynamic> data;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CloudRecord({
    required this.id,
    required this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory CloudRecord.fromJson(Map<String, dynamic> json) {
    return CloudRecord(
      id: json['id'].toString(),
      data: json,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

// ============ 异常类 ============

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
