import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_service.dart';

/// 认证状态
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// 认证状态数据
class AuthState {
  final AuthStatus status;
  final CloudUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    CloudUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 认证状态管理
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState());

  /// 初始化认证状态
  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _authService.initialize();
      
      if (_authService.isLoggedIn) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: _authService.currentUser,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 登录
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 注册
  Future<void> register({
    required String email,
    required String password,
    String? username,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        username: username,
      );
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 登出
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _authService.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(
      status: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
}
