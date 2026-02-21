# Muscle Clock 项目档案

> **最后更新**: 2026-02-21
> **版本**: v1.2.0 (Refactored)
> **状态**: 维护与优化阶段

## 1. 项目概览 (Overview)

**Muscle Clock** 是一款基于 Flutter 的轻量级力量训练记录与分析工具。它采用 Clean Architecture 架构，旨在帮助用户科学地记录训练内容、追踪肌肉恢复状态、分析训练频率，并制定周期性训练计划。

### 核心功能
- **训练记录 (Today)**: 实时记录训练动作、组数、重量与次数，支持自动计算容量。
- **日历视图 (Calendar)**: 按月展示训练历史，热力图风格直观呈现训练强度。
- **数据分析 (Analysis)**: 多维度统计（部位训练频率、休息天数、总容量），辅助科学训练。
- **计划管理 (Plan)**: 支持 PPL、Upper/Lower 等经典分化计划及自定义计划。
- **本地优先**: 数据完全存储在本地 SQLite 数据库，支持 JSON/CSV 导出与备份。

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
- `lib/core`: 核心配置（主题 `theme`、常量 `constants`、枚举 `enums`）。
- `lib/data`: 数据层实现（Drift 数据库 `database`、服务 `services`）。
- `lib/domain`: 业务领域层（实体 `entities`、仓库接口 `repositories`、业务逻辑 `usecases`）。
- `lib/presentation`: UI 层（页面 `pages`、通用组件 `widgets`、状态管理 `providers`）。
- `lib/l10n`: 国际化资源。

### 2.3 关键技术栈
| 领域 | 库/工具 | 说明 |
|------|---------|------|
| **Framework** | Flutter | 跨平台 UI 框架 |
| **Language** | Dart 3 | 强类型、空安全 |
| **State Management** | Flutter Riverpod | 声明式状态管理，依赖注入 |
| **Database** | Drift (SQLite) | 类型安全的 ORM，支持 Stream 响应式查询 |
| **Localization** | flutter_localizations | 官方国际化方案 (ARB) |
| **Utils** | intl, uuid, path_provider | 基础工具库 |

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

---

## 6. 云同步预留 (Cloud Sync)

```dart
abstract class SyncService {
  Future<void> uploadData();
  Future<void> downloadData();
}
```

本地Repository通过接口调用，不直接依赖实现。

---

## 7. 版本历史 (Version History)

| 版本 | 日期 | 类型 | 说明 |
|------|------|------|------|
| **v1.2.1** | 2026-02-21 | **Performance** | **性能优化**<br>- **N+1 查询修复**: 在 `database.dart` 添加 JOIN 聚合查询方法，重构 `exercise_records_list.dart` 和 `day_detail_card.dart` 使用批量查询，查询次数从 32+ 次降至 2-3 次。<br>- **日历构建优化**: 在 `providers.dart` 添加 `sessionsByDateProvider` 索引 Provider，将日历查找复杂度从 O(Days × Sessions) 降为 O(1)。<br>- **依赖清理**: 移除未使用的 `shared_preferences` 依赖，减小包体积。 |
| **v1.2.0** | 2026-02-21 | **Refactoring** | **全架构重构与代码优化**<br>- **架构分层 (Phase 1)**: 实现 Plan/Session Repository 模式，UI层彻底解耦数据库。<br>- **大文件拆分 (Phase 2)**: 重构 `plan_page` (-82%), `calendar_page` (-72%), `today_page` (-92%)，提取了 `plan_selector`, `day_detail_card`, `active_workout_view` 等10+个独立组件。<br>- **代码复用 (Phase 3/4)**: 封装 `entity_mixins.dart` (JSON序列化), `AsyncValueBuilder` (Provider简化), `AppThemeConfig` (主题配置)。<br>- **清理**: 删除冗余代码，合并 Export/Backup 服务，移除死代码约 400 行。 |
| **v1.1.0** | 2026-02-21 | **Feature** | **核心功能增强与体验优化**<br>- **数据**: 新增 Glutes (臀) / Abs (腹) 部位及其中文支持，内置预设经典动作。<br>- **Today页面**: 优化卡片视觉（层级式布局，主次分明）；简化交互流程（New Session 直接添加动作，自动保存，一键完成）；支持点击条目查看/编辑详情。<br>- **Calendar页面**: 统一卡片视觉风格；支持点击日期展开查看及编辑历史记录；优化热力图逻辑。<br>- **Plan页面**: 优化自定义计划创建流程，新增可视化设置弹窗（支持颜色标记部位）。<br>- **Analysis**: 恢复时间显示精确度提升至小时 (Days + Hours)。 |
| | 2026-02-21 | **Bugfix** | **稳定性与细节修复**<br>- **编译/运行**: 修复 table_calendar 依赖及 Drift 类型错误；修复 Theme 重构后的兼容性问题。<br>- **UI/UX**: 修复 Plan 页面颜色对比度问题；优化字体大小与颜色规范。<br>- **逻辑**: 修复新建项目刷新延迟；检测并阻止重复动作名称；修复 Session 归组逻辑。<br>- **国际化**: 补全缺失的中英文翻译键值。 |
| **v1.0.0** | 2026-02-20 | **MVP** | **初始版本**<br>- 基础功能上线：训练记录 (Today)、日历视图 (Calendar)、数据分析 (Analysis)、计划管理 (Plan)。 |
