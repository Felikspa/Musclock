# Muscle Clock 界面文档

> 用于团队内部标准化交流的界面组件命名参考文档

---

## 一、页面 (Pages)

位于 `lib/presentation/pages/` 目录

| 文件路径 | 英文名 | 中文名 | 功能简介 |
|----------|--------|--------|----------|
| `home_page.dart` | **HomePage** | 主页/导航页 | 应用入口，包含底部导航栏，承载 CalendarPage、TodayPage、AnalysisPage、PlanPage、SettingsPage 五个主页面 |
| `calendar_page.dart` | **CalendarPage** | 日历页 | 按月展示训练历史，热力图风格显示训练强度，点击日期查看详情 |
| `today_page.dart` | **TodayPage** | 今日训练页 | 展示今日训练记录，New Session 入口，包含两个子界面（无训练/有训练/活跃训练） |
| `analysis_page.dart` | **AnalysisPage** | 数据分析页 | 统计分析页面，包含两个 Tab：StatisticsTab（统计）、HeatmapTab（热力图） |
| `plan_page.dart` | **PlanPage** | 计划页 | 训练计划管理页面，展示预设计划和自定义计划，支持创建/编辑计划 |
| `settings_page.dart` | **SettingsPage** | 设置页 | 应用设置，包括主题切换、语言切换、数据导出/导入 |

---

## 二、组件 (Widgets)

### 2.1 通用组件 (Common)

位于 `lib/presentation/widgets/common/`

| 文件路径 | 英文名 | 中文名 | 功能简介 |
|----------|--------|--------|----------|
| `common/async_value_builder.dart` | **AsyncValueBuilder** | 异步值构建器 | 通用的 AsyncValue 包装组件，用于简化 loading/error/data 状态处理 |

### 2.2 Today 模块组件

位于 `lib/presentation/widgets/`

| 文件路径 | 英文名 | 中文名 | 功能简介 |
|----------|--------|--------|----------|
| `active_workout_view.dart` | **ActiveWorkoutView** | 活跃训练视图 | New Session 激活后显示的训练界面，展示当前训练项目和添加项目按钮 |
| `today_session_view.dart` | **TodaySessionView** | 今日训练记录视图 | 展示今日已保存的训练历史列表 |
| `today_session_view.dart` | **SavedSessionCard** | 已保存训练卡片 | 展示单个历史训练 session 的卡片组件 |
| `today_session_view.dart` | **ExerciseItemWidget** | 训练项目组件 | 展示单个训练项目（部位+动作+组数） |
| `exercise_card.dart` | **ExerciseCard** | 训练项目卡片 | 活跃训练中显示的单个训练项目卡片，支持显示部位标签、动作名、组数 |
| `add_exercise_sheet.dart` | **AddExerciseSheet** | 添加训练项目弹窗 | 底部弹窗，用于选择训练部位和动作，支持多选 |
| `training_details_dialog.dart` | **TrainingDetailsDialog** | 训练详情弹窗 | 查看/编辑训练详情的对话框，显示动作、组数、重量，可编辑 |
| `training_set_data.dart` | **TrainingSetData** | 训练组数据类 | 数据类，用于在训练详情中管理单组数据（重量、次数） |

### 2.3 Calendar 模块组件

位于 `lib/presentation/widgets/calendar/`

| 文件路径 | 英文名 | 中文名 | 功能简介 |
|----------|--------|--------|----------|
| `calendar/day_detail_card.dart` | **DayDetailCard** | 日期详情卡片 | 日历页点击日期后显示的详情卡片，展示当天训练记录 |
| `calendar/exercise_records_list.dart` | **ExerciseRecordsList** | 训练记录列表 | 展示某天所有训练记录的列表组件 |
| `calendar/exercise_record_card.dart` | **ExerciseRecordCard** | 训练记录卡片 | 展示单个训练记录的卡片组件 |

### 2.4 Plan 模块组件

位于 `lib/presentation/widgets/plan/`

| 文件路径 | 英文名 | 中文名 | 功能简介 |
|----------|--------|--------|----------|
| `plan/plan_selector.dart` | **PlanSelector** | 计划选择器 | 展示预设计划（PPL/Upper/Lower/Bro Split）和自定义计划的水平滚动选择器 |
| `plan/plan_details_widget.dart` | **PlanDetailsWidget** | 计划详情组件 | 显示计划详情，包括每周训练安排、当前休息天数 |
| `plan/plan_setup_dialog.dart` | **PlanSetupDialog** | 计划设置弹窗 | 创建/编辑自定义计划的对话框，支持设置计划名称、周期长度、每日训练部位 |
| `plan/custom_plan_day_item.dart` | **CustomPlanDayItem** | 自定义计划日期项 | 计划设置中单个日期的训练部位选择组件 |

### 2.5 辅助组件

位于 `lib/presentation/widgets/`

| 文件路径 | 英文名 | 中文名 | 功能简介 |
|----------|--------|--------|----------|
| `muscle_group_helper.dart` | **MuscleGroupHelper** | 肌肉群辅助类 | 静态工具类，提供肌肉群颜色映射、部位分组等功能 |

---

## 三、Today 页的两种界面状态

根据 `workoutSessionProvider.isActive` 状态，Today 页显示不同界面：

### 3.1 非活跃状态 (sessionState.isActive = false)

| 场景 | 显示组件 | 组件名 |
|------|----------|--------|
| 今日无训练记录 | 无训练提示视图 | `_NoWorkoutView` |
| 今日有训练记录 | 训练记录视图 | `TodaySessionView` → `SavedSessionCard` → `ExerciseItemWidget` |

### 3.2 活跃状态 (sessionState.isActive = true)

| 场景 | 显示组件 | 组件名 |
|------|----------|--------|
| 有训练项目 | 活跃训练视图 | `ActiveWorkoutView` → `ExerciseCard` |
| 无训练项目 | 活跃训练视图（空） | `ActiveWorkoutView` |
| 添加项目 | 添加弹窗 | `AddExerciseSheet` |

---

## 四、导航结构

```
HomePage (home_page.dart)
  └── NavigationBar (底部导航)
        ├── CalendarPage (日历页)
        │     └── DayDetailCard (日期详情卡片)
        │           └── ExerciseRecordsList (训练记录列表)
        │                 └── ExerciseRecordCard (训练记录卡片)
        │
        ├── TodayPage (今日训练页)
        │     ├── _NoWorkoutView (无训练提示)
        │     ├── TodaySessionView (历史记录视图)
        │     │     └── SavedSessionCard → ExerciseItemWidget
        │     └── ActiveWorkoutView (活跃训练视图)
        │           └── ExerciseCard
        │           └── AddExerciseSheet (添加弹窗)
        │
        ├── AnalysisPage (数据分析页)
        │     ├── _StatisticsTab (统计 Tab)
        │     │     ├── _GlobalStatsCard (全局统计卡片)
        │     │     └── _BodyPartStatCard (部位统计卡片)
        │     └── _HeatmapTab (热力图 Tab)
        │           └── _HeatmapGrid (热力图网格)
        │
        ├── PlanPage (计划页)
        │     └── PlanSelector (计划选择器)
        │     └── PlanDetailsWidget (计划详情)
        │     └── PlanSetupDialog (计划设置弹窗)
        │
        └── SettingsPage (设置页)
              └── _SettingsSection (设置分组)
```

---

## 五、核心数据 Provider

| Provider 名 | 位置 | 作用 |
|-------------|------|------|
| `workoutSessionProvider` | `providers/workout_session_provider.dart` | 管理当前活跃 session 状态（StateNotifierProvider） |
| `sessionsProvider` | `providers/providers.dart` | 监听所有 session 列表（StreamProvider） |
| `bodyPartsProvider` | `providers/providers.dart` | 监听所有训练部位（StreamProvider） |
| `exercisesProvider` | `providers/providers.dart` | 监听所有训练动作（StreamProvider） |
| `plansProvider` | `providers/providers.dart` | 监听所有自定义计划（StreamProvider） |
| `themeModeProvider` | `providers/providers.dart` | 主题模式状态（StateProvider） |
| `localeProvider` | `providers/providers.dart` | 语言环境状态（StateProvider） |
| `sessionsByDateProvider` | `providers/providers.dart` | 按日期索引的 session 映射（Provider） |

---

## 六、术语对照表

| 英文 | 中文 | 说明 |
|------|------|------|
| Page | 页面 | 顶级导航页面 |
| Widget | 组件 | UI 组成单元 |
| Sheet | 弹窗 | 底部弹出的选择面板 |
| Dialog | 对话框 | 居中弹出的模态窗口 |
| Card | 卡片 | 带圆角和阴影的内容容器 |
| Tab | 标签页 | 页面内的多标签切换 |
| Provider | 数据提供者 | Riverpod 状态管理 |
