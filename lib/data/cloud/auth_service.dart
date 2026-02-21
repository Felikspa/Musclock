import 'package:flutter/foundation.dart';
import 'minapp_client.dart';

/// 云端用户模型
class CloudUser {
  final String id;
  final String? email;
  final String? username;
  final DateTime? createdAt;

  CloudUser({
    required this.id,
    this.email,
    this.username,
    this.createdAt,
  });

  factory CloudUser.fromJson(Map<String, dynamic> json) {
    return CloudUser(
      id: json['id'].toString(),
      email: json['email'] as String?,
      username: json['username'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// 认证服务实现
/// 管理用户的登录、注册、登出状态
class AuthService {
  final MinAppClient _client;
  
  CloudUser? _currentUser;
  
  AuthService(this._client);

  /// 获取当前登录用户
  CloudUser? get currentUser => _currentUser;
  
  /// 是否已登录
  bool get isLoggedIn => _client.isLoggedIn;

  /// 初始化认证服务，恢复登录状态
  Future<void> initialize() async {
    await _client.initialize();
    if (_client.isLoggedIn) {
      try {
        final userData = await _client.getCurrentUser();
        _currentUser = CloudUser.fromJson(userData);
      } catch (e) {
        // 如果获取用户信息失败，清除登录状态
        debugPrint('Failed to get current user: $e');
        await _client.clearAuth();
      }
    }
  }

  /// 用户登录
  Future<CloudUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _client.login(email: email, password: password);
    
    // 获取完整用户信息
    final userData = await _client.getCurrentUser();
    _currentUser = CloudUser.fromJson(userData);
    
    return _currentUser!;
  }

  /// 用户注册
  Future<CloudUser> register({
    required String email,
    required String password,
    String? username,
  }) async {
    final result = await _client.register(
      email: email, 
      password: password,
      username: username,
    );
    
    // 注册后自动登录，获取用户信息
    final userData = await _client.getCurrentUser();
    _currentUser = CloudUser.fromJson(userData);
    
    return _currentUser!;
  }

  /// 用户登出
  Future<void> logout() async {
    await _client.logout();
    _currentUser = null;
  }

  /// 检查登录状态
  Future<bool> checkLoginStatus() async {
    if (!_client.isLoggedIn) {
      return false;
    }
    
    try {
      final userData = await _client.getCurrentUser();
      _currentUser = CloudUser.fromJson(userData);
      return true;
    } catch (e) {
      await _client.clearAuth();
      _currentUser = null;
      return false;
    }
  }
}
