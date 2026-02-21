import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  factory CloudUser.fromSupabase(User user) {
    return CloudUser(
      id: user.id,
      email: user.email,
      username: user.userMetadata?['username'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// 认证服务实现 (Supabase版)
class AuthService {
  final SupabaseClient _client;
  
  AuthService(this._client);

  /// 获取当前登录用户
  CloudUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return CloudUser.fromSupabase(user);
  }
  
  /// 是否已登录
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// 初始化认证服务 (Supabase SDK 自动处理 Session 恢复)
  Future<void> initialize() async {
    // Supabase automatically restores session from secure storage
    final session = _client.auth.currentSession;
    if (session != null) {
      debugPrint('[Auth] Session restored for user: ${session.user.id}');
    }
  }

  /// 用户登录
  Future<CloudUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Login failed: User is null');
    }

    return CloudUser.fromSupabase(response.user!);
  }

  /// 用户注册
  Future<CloudUser> register({
    required String email,
    required String password,
    String? username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: username != null ? {'username': username} : null,
    );
    
    if (response.user == null) {
      throw Exception('Registration failed: User is null');
    }
    
    return CloudUser.fromSupabase(response.user!);
  }

  /// 用户登出
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// 检查登录状态
  Future<bool> checkLoginStatus() async {
    final session = _client.auth.currentSession;
    return session != null;
  }
  
  /// 监听认证状态变化
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
