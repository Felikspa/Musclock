# 启用云同步功能实施计划

本计划旨在基于现有代码库，打通 MinApp BaaS 的认证与同步功能，使用户能够注册、登录并同步数据。

## 1. 路由配置 (Route Configuration)

**目标**: 在应用层级注册登录与注册页面的路由，确保导航跳转正常。

**涉及文件**:
- [app.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/app.dart)
- [login_page.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/presentation/pages/login_page.dart) (引入)
- [register_page.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/presentation/pages/register_page.dart) (引入)

**任务**:
1.  修改 `MuscleClockApp` 组件。
2.  在 `MaterialApp` 中添加 `routes` 属性，定义 `/login` 对应 `LoginPage`，`/register` 对应 `RegisterPage`。

## 2. 认证功能接入 (Authentication Implementation)

**目标**: 将 UI 表单与后端的 `AuthStateNotifier` 连接，替换现有的模拟逻辑。

### 2.1 登录页面
**涉及文件**: [login_page.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/presentation/pages/login_page.dart)

**任务**:
1.  取消对 `providers.dart` 的注释引用。
2.  在 `_handleLogin` 方法中：
    -   调用 `ref.read(authStateProvider.notifier).login(...)` 替换 `Future.delayed` 模拟代码。
    -   监听 `authStateProvider` 的状态变化，根据 `AuthStatus.authenticated` 判断跳转，根据 `AuthStatus.error` 显示错误。
    -   或者等待 `login` Future 完成（如果 `login` 方法返回 Future），当前 `AuthStateNotifier.login` 是 `Future<void>`，可以直接 await。

### 2.2 注册页面
**涉及文件**: [register_page.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/presentation/pages/register_page.dart)

**任务**:
1.  取消对 `providers.dart` 的注释引用。
2.  在 `_handleRegister` 方法中：
    -   调用 `ref.read(authStateProvider.notifier).register(...)` 替换模拟代码。
    -   注册成功后，通常会自动登录（根据 `MinAppClient` 逻辑），需处理成功后的跳转或提示。

## 3. 设置页入口集成 (Settings Integration)

**目标**: 在设置页面展示真实的用户状态和同步入口。

**涉及文件**: [settings_page.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/presentation/pages/settings_page.dart)

**任务**:
1.  找到 "Cloud Sync" 部分。
2.  取消 `Consumer` 代码块的注释。
3.  移除现有的 Placeholder 代码（提示 "Configure MinApp credentials..." 的 `ListTile`）。
4.  确保 "Sync Now" 按钮调用 `ref.read(syncStateProvider.notifier).syncAll()`。
5.  确保 "Logout" 按钮调用 `ref.read(authStateProvider.notifier).logout()`。

## 4. 应用初始化 (App Initialization)

**目标**: 应用启动时恢复用户的登录状态。

**涉及文件**:
- [main.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/main.dart) 或 [app.dart](file:///c:/Users/24045/Desktop/Muscle%20Clock/lib/app.dart)

**任务**:
1.  在应用启动早期（如 `MuscleClockApp` 的 `initState` 或 `main` 函数中），调用 `ref.read(authStateProvider.notifier).initialize()`。
2.  这将读取本地存储的 Token，如果有效则自动设置状态为 `authenticated`。

## 5. 验证 (Verification)

1.  **编译检查**: 确保所有取消注释的代码没有语法错误。
2.  **功能验证**:
    -   启动应用，检查是否自动尝试恢复登录。
    -   进入设置页，点击登录，跳转至登录页。
    -   使用无效账号登录，应提示错误。
    -   使用有效账号登录，应成功返回设置页，并显示用户信息。
    -   点击 "Sync Now"，应触发同步逻辑（日志或 UI 提示）。
    -   点击 "Logout"，应清除状态并恢复为未登录视图。
