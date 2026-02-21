# Muscle Clock 项目跟踪文档

## 项目概述

- **项目名称**: Muscle Clock
- **平台**: Flutter (Android)
- **版本**: MVP 1.1
- **数据存储**: 本地优先（预留云同步接口）
- **最后更新**: 2026-02-20

---

## 一、产品愿景

轻量级力量训练记录与分析工具，帮助用户：
- 记录每次训练内容和强度
- 计算肌肉恢复周期，避免过度训练
- 统计训练频率，追踪训练习惯
- 自定义周期计划，科学安排训练

---

## 二、核心架构设计

### 2.1 架构分层

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│      (Flutter + Riverpod/Bloc)      │
├─────────────────────────────────────┤
│            Domain Layer             │
│        (UseCases + Entities)        │
├─────────────────────────────────────┤
│             Data Layer              │
│  Repository + LocalDataSource(Drift) │
│      RemoteDataSource (预留)         │
└─────────────────────────────────────┘
```

### 2.2 技术选型

| 组件 | 选型 | 理由 |
|------|------|------|
| 状态管理 | Riverpod | 轻量、声明式、易测试 |
| 本地数据库 | Drift (SQLite) | 结构化强、支持复杂查询、适合统计计算 |
| 国际化 | Flutter intl | 官方推荐方案 |
| 主题管理 | ThemeMode + SharedPreferences | 轻量实现 |

---

## 三、数据模型

### 3.1 实体定义

```dart
// BodyPart - 训练部位
class BodyPart {
  String id;          // UUID
  String name;        // 部位名称
  DateTime createdAt; // 创建时间
  bool isDeleted;     // 软删除标记
}

// Exercise - 训练动作
class Exercise {
  String id;          // UUID
  String name;        // 动作名称
  String bodyPartId;  // 关联部位ID
  DateTime createdAt; // 创建时间
}

// WorkoutSession - 训练会话
class WorkoutSession {
  String id;          // UUID
  DateTime startTime; // 开始时间（精确到分钟）
  DateTime createdAt; // 创建时间
}

// ExerciseRecord - 动作记录
class ExerciseRecord {
  String id;           // UUID
  String sessionId;    // 会话ID
  String exerciseId;  // 动作ID
}

// SetRecord - 组记录
class SetRecord {
  String id;               // UUID
  String exerciseRecordId;  // 动作记录ID
  double weight;           // 重量(kg)
  int reps;                // 次数
  int orderIndex;          // 组序号
}

// TrainingPlan - 训练计划
class TrainingPlan {
  String id;               // UUID
  String name;             // 计划名称
  int cycleLengthDays;     // 周期长度(天)
  DateTime createdAt;      // 创建时间
}

// PlanItem - 计划项目
class PlanItem {
  String id;               // UUID
  String planId;           // 计划ID
  int dayIndex;            // 日期索引(0 ~ cycleLengthDays-1)
  List<String> bodyPartIds; // 部位ID列表
}
```

### 3.2 关键架构决策

| 决策项 | 选择 | 说明 |
|--------|------|------|
| BodyPart删除 | 软删除 | 标记isDeleted=true，历史数据保留但隐藏 |
| Exercise部位修改 | 允许 | 可随时改变归属部位 |
| 同一天多次训练 | 分开展示 | 多个独立Session |
| 历史记录修改 | 有限允许 | 仅当天记录可修改 |
| 时区处理 | UTC | 统一使用UTC时间戳存储 |
| 跨天训练归属 | 开始时间 | 按Session开始日期归属 |

---

## 四、核心算法

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

## 五、功能模块

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

## 六、云同步预留

```dart
abstract class SyncService {
  Future<void> uploadData();
  Future<void> downloadData();
}
```

本地Repository通过接口调用，不直接依赖实现。

---

## 七、开发计划

### 阶段1: 基础架构搭建

- [x] Flutter项目初始化
- [x] Drift数据库配置
- [x] 数据模型实体创建
- [x] 基础Repository实现

### 阶段2: 核心功能开发

- [x] Today模块 - 训练记录
- [x] Calendar模块 - 月视图
- [x] Analysis模块 - 统计分析

### 阶段3: 计划与设置

- [x] Plan模块 - 训练计划
- [x] Settings模块 - 主题/语言

### 阶段4: 数据功能

- [x] 数据导出功能 (JSON/CSV)
- [x] 数据备份功能

### 阶段5: 完善与测试

- [x] Bug修复与优化
- [x] MVP版本发布

---

## 八、版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| MVP 1.0 | 2026-02-20 | 初始版本 - 完整功能实现 |
| | | - 训练记录功能 |
| Bugfix | 2026-02-21 | 修复编译错误 |
| | | - 添加缺失的 table_calendar 依赖 |
| | | - 修复 Drift Value 类型使用错误 |
| | | - 修复 TextButtonThemeData 参数错误 |
| Feature Update | 2026-02-21 | 用户反馈修复 |
| | | - Today页面: 添加动作名称后即时显示 |
| | | - Today页面: 检测重复动作名称避免重复添加 |
| | | - Today页面: Save后显示当天训练记录并可编辑 |
| | | - Today页面: 删除开始时间显示 |
| | | - 新增训练部位: Glutes(臀)、Abs(腹)及其中文支持 |
| | | - 新增部位预设经典动作 |
| | | - Calendar页面: 支持编辑历史训练记录 |
| | | - Plan页面: 自定义计划与预设计划合并展示 |
| Bugfix | 2026-02-21 | Plan页面颜色修复 |
| | | - 修复自定义计划训练部位统一显示为绿色的bug |
| | | - 调整颜色增大对比度: Shoulders紫色、Back蓝绿色、Glutes粉红色 |
| | | - 加深Arms橙色，在浅色主题下更易辨识 |
| | | - 添加Glutes和Abs部位颜色定义 |
| Feature Update | 2026-02-21 | Today页面交互优化 |
| | | - Today页面: 修改显示格式为"部位 → 动作 → sets" |
| | | - Today页面: Add Sets窗口集成部位和动作选择功能 |
| | | - 用户可在Add Sets时选择部位、动作并输入重量和次数 |
| Feature Update | 2026-02-21 | Today和Calendar页面显示优化 |
| | | - Today页面: 保存session后显示当天训练记录 |
| | | - Calendar页面: 训练内容作为标题，时间放次要位置 |
| | | - Today页面: 已保存的训练记录显示训练内容作为标题 |
| Feature Update | 2026-02-21 | Today和Calendar页面UI优化 |
| | | - Today页面: 去掉顶部重复的Today标题 |
| | | - Today页面: 卡片格式改为"部位(大字体左侧) + 时间(灰色小字体右侧)"换行显示动作和组数 |
| | | - Calendar页面: 同样的卡片格式，可点击展开查看详情和编辑 |
| Feature Update | 2026-02-21 | Today页面交互优化 |
| | | - 点击New Session后直接弹出Add Exercise窗口 |
| | | - 删除Start time显示和Add exercise按钮（在ActiveWorkoutView中） |
| | | - 删除Save按钮，添加动作后自动保存到session |
| Feature Update | 2026-02-21 | 部位和动作数据修复 |
| | | - 添加Glutes和Abs训练部位 |
| | | - 添加预设训练动作（每个部位4-5个动作） |
| | | - 修复add exercise保存后刷新sessions列表 |
| | | - 放大Add Exercise页面部位选择标题字体 |
| Feature Update | 2026-02-21 | Today和Calendar页面功能增强 |
| | | - Calendar页按训练项目展示，可展开查看详情和编辑 |
| | | - Today页添加"完成"按钮，返回主界面 |
| | | - 优化session逻辑：一小时内新建session自动归入同一session |
| | | - 添加currentSession和done本地化字符串 |
| Bugfix | 2026-02-21 | 修复本地化字符串缺失导致的编译错误 |
| | | - 添加currentSession和done键到app_en.arb和app_zh.arb |
| Feature Update | 2026-02-21 | Calendar页面训练记录显示优化 |
| | | - Calendar页点击日期显示的训练记录改为彩色框形式展示部位（与Plan页面相同） |
| | | - 动作和组数信息显示在彩色框后面 |
| | | - 时间用灰色小字号显示在右侧 |
| | | - 点击记录项弹出独立Details窗口查看训练详情 |
| | | - Details窗口内允许编辑训练信息（动作名称、添加/编辑/删除组数） |
| | | - 新增TrainingDetailsDialog组件 |
| | | - 新增workoutDetails和saved本地化字符串 |
| Feature Update | 2026-02-21 | Today页面布局优化 |
| | | - 改为层级式布局：Session为大栏目，包含多个训练项目次级栏目 |
| | | - 每栏首行左侧用较大黑色字体显示训练部位名称 |
| | | - 每栏首行右侧用较小灰色字体显示时间 |
| | | - 第二行显示动作名称和组数（绿色实色框样式） |
| | | - Analysis页面休息时间显示优化 |
| | | - 部位休息时间从精确到天改为精确到小时 |
| | | - 格式为 "x days x hours"，例如 "1 days 5 hours" |
| Feature Update | 2026-02-21 | Today页面功能增强和Bug修复 |
| | | - Today页点击训练项目弹出Details窗口（与Calendar相同） |
| | | - Details窗口内允许编辑训练部位、动作和组数 |
| | | - 修复新建部位/动作后不立即显示的bug |
| | | - 修复添加session后不立即显示的bug |
|| Feature Update | 2026-02-21 | Plan页面新建自定义计划交互优化 |
| | | - 新建自定义plan填写名称和周期后点击Save，自动弹出设置窗口 |
| | | - 设置窗口左侧显示Day列表，右侧显示对应训练部位/休息 |
| | | - 点击任意Day可快速设置训练部位或休息日 |
| | | - 训练部位以彩色框显示，休息以灰色框显示 |
| | | - 完成后点击Done自动选中该新建计划 |

---

## 九、UI现代化更新 (2026-02-20)

### 9.1 变更概述

本次更新将旧版Workout tracker的UI样式完整融合到新版Muscle Clock应用：

### 9.2 具体变更

1. **底部导航栏调整**
   - Calendar移至第一位（默认打开界面）
   - Today移至第二位

2. **全局主题更新**
   - 采用旧版深色/浅色主题配色方案
   - 主色: primaryDark (#1A1A1A), primaryLight (#F5F5F5)
   - 强调色: accent (#00D4AA) 薄荷绿
   - 卡片色: cardDark (#252525), cardLight (#FAFAFA)
   - 肌肉颜色映射表（Chest红、Back青、Legs蓝、Shoulders绿、Arms黄）

3. **Calendar页面重构**
   - 顶部显示 "Muscle Clock" 标题
   - 支持滑动切换月份
   - 日历带肌肉颜色标记
   - 选中日期下方显示训练内容

4. **Plan页面重构**
   - 训练计划选择器（内置PPL、Upper/Lower、Bro Split模板）
   - 彩色训练部位框表示不同肌肉
   - 7天训练计划可视化展示
   - 支持自定义训练计划

5. **默认训练部位**
   - 首次启动自动初始化5个默认部位：Chest、Back、Legs、Shoulders、Arms

6. **本地化更新**
   - 添加训练部位、计划模板等翻译键
   - 支持中英文切换