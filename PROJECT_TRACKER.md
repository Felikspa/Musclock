# Musclock 项目档案

> **最后更新**: 2026-02-23
> **版本**: v1.3.3
> **状态**: Settings 页面化完成

## 1. 项目概览 (Overview)

**Musclock** 是一款基于 Flutter 的轻量级力量训练记录与分析工具。它采用 Clean Architecture 架构，旨在帮助用户科学地记录训练内容、追踪肌肉恢复状态，分析训练频率，并制定周期性训练计划。

### 核心功能
- **训练记录 (Today)**: 实时记录训练动作、组数、重量与次数，支持自动计算容量。
- **日历视图 (Calendar)**: 按月展示训练历史，热力图风格直观呈现训练强度。
- **数据分析 (Analysis)**: 多维度统计（部位训练频率、休息天数、总容量），辅助科学训练。
- **计划管理 (Plan)**: 支持 PPL、Upper/Lower 等经典分化计划及自定义计划。
- **本地优先**: 数据完全存储在本地 SQLite 数据库，支持 JSON/CSV 导出与备份。
- **云同步 (Beta)**: 支持知晓云 BaaS 平台数据同步。

---

## 2. 技术架构 (Architecture)

项目遵循 **Clean Architecture** 分层原则，配合 **Riverpod** 进行状态管理。

### 2.1 架构分层

```mermaid
graph TD
    UI[Presentation Layer] --> Domain[Domain Layer]
    Domain --> Data[Data Layer]
    
    subgraph Presentation [Flutter + Riverpod]
        Pages[Pages]
        Widgets[Widgets]
        Providers[StateNotifiers / Providers]
    end
    
    subgraph Domain [Pure Dart]
        Entities[Entities]
        UseCases[UseCases]
        RepoInterfaces[Repository Interfaces]
    end
    
    subgraph Data [Drift + Services]
        RepoImpl[Repository Implementation]
        Database[Drift Database (SQLite)]
        Services[Backup/Export Services]
    end
```

### 2.2 目录结构

```
Musclock/
├── lib/
│   ├── core/                    # 核心配置
│   │   ├── constants/            # 常量定义
│   │   ├── enums/               # 枚举定义
│   │   └── theme/               # 主题配置
│   │       ├── app_theme.dart           # Flutter 主题
│   │       ├── app_theme_config.dart    # 主题配置
│   │       └── appflowy_theme.dart      # AppFlowy 风格主题
│   ├── data/                    # 数据层实现
│   │   ├── cloud/               # 云同步服务
│   │   ├── database/            # Drift 数据库
│   │   ├── repositories/        # 仓库实现
│   │   └── services/            # 业务服务
│   ├── domain/                  # 业务领域层
│   │   ├── entities/            # 实体定义
│   │   ├── repositories/       # 仓库接口
│   │   └── usecases/           # 业务逻辑
│   ├── l10n/                    # 国际化资源
│   ├── presentation/            # UI 层
│   │   ├── pages/              # 页面组件
│   │   └── widgets/            # 通用组件
│   ├── app.dart                 # 应用入口
│   └── main.dart                # 主入口
├── packages/
│   └── appflowy_ui/            # AppFlowy UI 组件库
├── pubspec.yaml                 # 项目配置
└── PROJECT_TRACKER.md          # 项目档案
```

### 2.3 关键技术栈
||| 领域 | 库/工具 | 说明 |
|||------|---------|------|
||| **Framework** | Flutter | 跨平台 UI 框架 |
||| **Language** | Dart 3 | 强类型、空安全 |
||| **State Management** | Flutter Riverpod | 声明式状态管理，依赖注入 |
||| **Database** | Drift (SQLite) | 类型安全的 ORM，支持 Stream 响应式查询 |
||| **Localization** | flutter_localizations | 官方国际化方案 (ARB) |
||| **UI Components** | appflowy_ui | AppFlowy 风格 UI 组件 |
||| **Utils** | intl, uuid, path_provider | 基础工具库 |

---

## 3. 数据模型 (Data Models)

基于 Drift 定义的 SQLite 表结构，核心实体关系如下：

### 3.1 核心实体
- **BodyPart**: 训练部位（如 Chest, Back）。支持软删除。
- **Exercise**: 训练动作，归属于某个 BodyPart。
- **WorkoutSession**: 一次训练会话，包含开始时间。
- **ExerciseRecord**: 会话中的动作记录，关联 Session 和 Exercise。
- **SetRecord**: 动作下的具体组数据（Weight, Reps, Order）。
- **TrainingPlan**: 周期性训练计划（如 "Push Pull Legs"）。
- **PlanItem**: 计划中的单日安排，定义该日训练哪些 BodyPart。

### 3.2 关键字段说明
- **ID 生成**: 全局使用 UUID v4 字符串。
- **时间存储**: 统一使用 UTC 时间戳。
- **列表存储**: `bodyPartIds` 等字段在数据库中以 JSON 字符串存储，在实体中转为 List。

---

## 4. 核心算法 (Core Algorithms)

### 4.1 部位恢复天数计算

```dart
DateTime? getLastTrainedTime(BodyPart bodyPart) {
  // 找到包含该部位的最新训练Session的开始时间
}

int getRestDays(BodyPart bodyPart) {
  restMinutes = currentTime - lastTrainedTime
  return floor(restMinutes / (24 * 60))
}
```

**UI展示**: 转换为 "x天x小时" 格式

### 4.2 部位训练频率

```dart
double getFrequency(BodyPart bodyPart) {
  totalSessions = 包含该部位的所有Session数量
  totalDays = (当前时间 - 首次训练时间) / 1天
  return totalSessions / totalDays
}
```

**注意**: 全周期平均频率，非滚动窗口

### 4.3 训练量 (Volume)

```dart
// 单组Volume
double setVolume = weight × reps

// 单动作Volume
double exerciseVolume = Σ(weight × reps)

// 单SessionVolume
double sessionVolume = Σ(所有动作的volume)

// Heatmap数据
Map<DateTime, double> dailyVolume
```

---

## 5. 功能模块 (Functional Modules)

### 5.1 Calendar 模块

**目标**: 按月视图展示训练情况

**展示内容**:
- 每天是否有训练（布尔标识）
- 当天总训练量 → 颜色强度映射
- 点击进入Session详情
- 显示每个BodyPart当前restDays

**颜色映射**: `intensity = normalize(sessionVolume)`

### 5.2 Today 模块

**交互流程**:
```
New Session → Add Exercise → Add Sets → Save
```

**功能**:
- 创建WorkoutSession
- 选择/新增BodyPart
- 选择/新增Exercise
- 添加多组Set（不同重量/次数）
- 编辑/删除组
- 保存Session

### 5.3 Analysis 模块

**BodyPart统计**:
- 总训练次数
- 平均训练间隔
- 当前恢复时间

**全局统计**:
- 总训练天数
- 总训练次数
- 平均每周训练频率

**Heatmap**:
- 日期 × Volume

### 5.4 Plan 模块

**数据结构**:
- 周期可变长度（不强制按周）
- 支持任意天数循环

**接口预留**: Plan → 自动生成Today建议

### 5.5 Settings 模块

**功能**:
- 主题切换: Light / Dark
- 语言切换: EN / CN
- 数据导出: JSON / 备份文件
- 云同步: 登录/登出/同步

---

## 6. 云同步 (Cloud Sync)

### 6.1 知晓云 BaaS 接入

基于知晓云 BaaS 平台实现用户认证和云数据同步功能。

**技术方案**:
- **接入方式**: REST API (知晓云无官方 Flutter SDK)
- **认证方式**: Email + Password
- **同步策略**: 合并策略 (基于时间戳比较，保留最新修改)
- **多设备支持**: 是

### 6.2 待完成任务

1. **知晓云后台创建数据表** (需手动操作)
2. **配置凭证**: 在 `providers.dart` 中配置 CloudConfig
3. **取消 Provider 注释**: 启用云同步功能

---

## 7. 版本历史 (Version History)

||| 版本 | 日期 | 类型 | 说明 |
|||------|------|------|------|
||| **v1.3.2** | 2026-02-23 | Refactoring | **UI 命名规范化重构**<br>- 制定统一的组件命名规范 (v2.0)<br>- 引入模块前缀体系: `Workout` / `Calendar` / `App`<br>- 明确组件类型后缀: `Page` / `View` / `Card` / `List` / `Dialog` / `BottomSheet` / `Panel` / `Selector` / `Helper` / `Data`<br>- 更新 UI_DOCUMENTATION.md 完整命名对照表 |
| **v1.3.3** | 2026-02-23 | Feature | **Settings 页面化**<br>- 将 Settings 从 Bottom Sheet 改为完整页面导航<br>- 迁移 AppFlowy 卡片样式到 SettingsPage<br>- 添加通知设置模块
||| **v1.3.0-beta.1** | 2026-02-23 | Beta | **AppFlowy UI Beta 版发布**<br>- AppFlowy UI 风格重构<br>- 4-Tab 底部导航 (Calendar/Today/Analysis/Plan)<br>- MusclockAppBar 通用顶部导航<br>- SettingsBottomSheet 设置面板<br>- 品牌色 (#00D4AA) 融入 AppFlowy 主题<br>- 毛玻璃背景效果 |
||| **v1.2.8** | 2026-02-23 | Refactoring | **AppFlowy UI风格重构完成**<br>- **步骤1-3**: 复制appflowy_ui包到Musclock，配置pubspec.yaml依赖，创建AppFlowy风格主题配置 (MusclockBrandColors.primary = #00D4AA)。<br>- **步骤4**: 底部导航栏改为4个Tab (Calendar/Today/Analysis/Plan)，使用NavigationBar+毛玻璃背景效果。<br>- **步骤5**: 创建MusclockAppBar通用顶部导航栏组件，支持滚动时透明度变化。<br>- **步骤6**: 创建SettingsBottomSheet设置底部弹出面板，支持主题切换、语言切换、导出备份、云同步。<br>- **页面迁移**: Calendar/Today/Analysis/Plan页面已统一使用MusclockAppBar。<br>- **代码质量**: flutter analyze通过，无编译错误，仅有info级别弃用警告。 |
||| **v1.0.0 - v1.2.7** | 2026-02-20~22 | Stable | **初始开发阶段**<br>- 基础功能: 训练记录 (Today)、日历视图 (Calendar)、数据分析 (Analysis)、计划管理 (Plan)<br>- 全面中文本地化<br>- 性能优化 (N+1查询修复、日历索引优化)<br>- Bug 修复 (实时更新、多选支持、重复检测等)<br>- 架构重构 (Clean Architecture、Repository 模式)<br>- 新增部位: Glutes (臀)、Abs (腹) |

---

## 8. 未来规划 (Roadmap)

### 8.1 即将推出 (Upcoming)
- [ ] AppFlowy UI 稳定版发布
- [ ] UI 命名规范化实施 (文件重命名)
- [ ] 云同步功能完善
- [ ] 训练提醒通知
- [ ] 训练数据图表可视化

### 8.2 长期目标 (Long-term)
- [ ] 跨平台支持 (iOS/Web)
- [ ] 训练数据分享
- [ ] AI 训练建议
- [ ] Apple Watch / 健康App 集成
