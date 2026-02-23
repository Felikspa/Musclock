# Muscle Clock UI 命名规范与组件文档 (v2.0)

> 用于团队内部标准化交流的界面组件命名参考文档
>
> **核心原则**: 通过名称可直接判断组件类型，名称具有内在逻辑，用户一眼可看出代表哪个组件

---

## 一、 核心命名原则 (Mandatory)

为了保证代码的可读性与维护性，所有 UI 组件必须遵循以下硬性约束：

### 1.1 英文命名规则 (PascalCase)

| 类型 | 后缀 | 定义说明 |
| :--- | :--- | :--- |
| **页面 (Pages)** | `Page` | 指代完整全屏界面，作为导航的顶层入口 |
| **视图 (Views)** | `View` | 指代页面内的大块功能区域或复杂组件 |
| **卡片 (Cards)** | `Card` | 指代带有阴影或边框的独立信息容器 |
| **列表 (Lists)** | `List` | 指代重复条目的集合 |
| **对话框 (Dialogs)** | `Dialog` | 指代居中弹出的模态框 |
| **底部弹窗 (Sheets)** | `BottomSheet` | 指代从底部升起的交互窗 |
| **标签页 (Tabs)** | `TabView` | 指代 TabBarView 内部的内容页 |
| **辅助/工具 (Helpers)** | `Helper` | 指代静态方法或逻辑辅助类 |
| **数据模型 (Data)** | `Data` | 指代仅用于 UI 展示的数据类 |
| **面板 (Panels)** | `Panel` | 指代设置或配置类面板 |
| **选择器 (Selectors)** | `Selector` | 指代水平滚动的选择器组件 |

### 1.2 中文命名规则

* **必须包含类型显式后缀**：页面、视图、卡片、列表、对话框、底部弹窗、标签页、网格、工具类、数据类。
* **严禁简称**：如"弹窗"必须区分是"对话框"还是"底部弹窗"。

### 1.3 命名内在逻辑

* **模块前缀**: 同一模块的组件使用统一前缀，如 `Workout` (训练模块)、`Calendar` (日历模块)、`Plan` (计划模块)
* **功能描述**: 名称应清晰描述功能，如 `TodayWorkoutRecordView` (今日训练记录视图)
* **层次关系**: 子组件名称应继承父组件前缀，如 `WorkoutPlanSelector` → `WorkoutPlanDetailsView` → `WorkoutPlanSetupDialog`

---

## 二、 命名重构对照表

### 2.1 页面级 (Pages)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `home_page.dart` | HomePage | 主页/导航页 | **HomeNavigationPage** | 首页导航页面 |
| `calendar_page.dart` | CalendarPage | 日历页 | **CalendarOverviewPage** | 训练日历页面 |
| `today_page.dart` | TodayPage | 今日训练页 | **TodayWorkoutPage** | 今日训练页面 |
| `analysis_page.dart` | AnalysisPage | 数据分析页 | **WorkoutAnalysisPage** | 训练分析页面 |
| `plan_page.dart` | PlanPage | 计划页 | **WorkoutPlanPage** | 训练计划页面 |
| `settings_page.dart` | SettingsPage | 设置页 | **AppSettingsPage** | 应用设置页面 |
| `login_page.dart` | LoginPage | 登录页 | **LoginPage** | 登录页面 |
| `register_page.dart` | RegisterPage | 注册页 | **RegisterPage** | 注册页面 |

### 2.2 通用组件 (Common Widgets)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `common/async_value_builder.dart` | AsyncValueBuilder | 异步值构建器 | **AsyncValueBuilder** | 异步值构建器 |
| `musclock_app_bar.dart` | MusclockAppBar | 顶部导航栏 | **MusclockAppBar** | 顶部导航栏 |
| `settings_bottom_sheet.dart` | SettingsBottomSheet | 设置底部弹窗 | **SettingsBottomSheet** | 设置底部弹窗 |

### 2.3 Today 模块组件 (Workout Module)

#### 视图 (Views)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `active_workout_view.dart` | ActiveWorkoutView | 活跃训练视图 | **ActiveWorkoutView** | 活跃训练视图 |
| `today_session_view.dart` | TodaySessionView | 今日训练记录视图 | **TodayWorkoutRecordView** | 今日训练记录视图 |

#### 卡片 (Cards)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `exercise_card.dart` | ExerciseCard | 训练项目卡片 | **ExerciseCard** | 训练项目卡片 |

#### 底部弹窗 (BottomSheets)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `add_exercise_sheet.dart` | AddExerciseSheet | 添加训练项目弹窗 | **AddExerciseBottomSheet** | 添加训练项目底部弹窗 |

#### 对话框 (Dialogs)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `training_details_dialog.dart` | TrainingDetailsDialog | 训练详情弹窗 | **TrainingDetailsDialog** | 训练详情对话框 |

#### 数据模型 (Data)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `training_set_data.dart` | TrainingSetData | 训练组数据类 | **TrainingSetData** | 训练组数据类 |

### 2.4 Calendar 模块组件 (Calendar Module)

#### 视图 (Views)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `calendar/exercise_records_list.dart` | ExerciseRecordsList | 训练记录列表 | **WorkoutRecordList** | 训练记录列表 |

#### 卡片 (Cards)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `calendar/day_detail_card.dart` | DayDetailCard | 日期详情卡片 | **DayWorkoutDetailCard** | 日期训练详情卡片 |
| `calendar/exercise_record_card.dart` | ExerciseRecordCard | 训练记录卡片 | **WorkoutRecordCard** | 训练记录卡片 |

### 2.5 Plan 模块组件 (Plan Module)

#### 选择器 (Selectors)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `plan/plan_selector.dart` | PlanSelector | 计划选择器 | **WorkoutPlanSelector** | 训练计划选择器 |

#### 视图 (Views)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `plan/plan_details_widget.dart` | PlanDetailsWidget | 计划详情组件 | **WorkoutPlanDetailsView** | 训练计划详情视图 |

#### 对话框 (Dialogs)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `plan/plan_setup_dialog.dart` | PlanSetupDialog | 计划设置弹窗 | **WorkoutPlanSetupDialog** | 训练计划设置对话框 |

#### 列表项 (List Items)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `plan/custom_plan_day_item.dart` | CustomPlanDayItem | 自定义计划日期项 | **WorkoutPlanDayItem** | 训练计划日期项 |

### 2.6 Settings 模块组件 (Settings Module)

#### 对话框 (Dialogs)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `settings/settings_dialog.dart` | SettingsDialog | 设置对话框 | **SettingsDialog** | 设置对话框 |

#### 面板 (Panels)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `settings/notification_settings.dart` | NotificationSettings | 通知设置 | **NotificationSettingsPanel** | 通知设置面板 |
| `settings/account_settings.dart` | AccountSettings | 账户设置 | **AccountSettingsPanel** | 账户设置面板 |
| `settings/cloud_settings.dart` | CloudSettings | 云同步设置 | **CloudSettingsPanel** | 云同步设置面板 |
| `settings/data_settings.dart` | DataSettings | 数据设置 | **DataSettingsPanel** | 数据设置面板 |
| `settings/theme_settings.dart` | ThemeSettings | 主题设置 | **ThemeSettingsPanel** | 主题设置面板 |
| `settings/language_settings.dart` | LanguageSettings | 语言设置 | **LanguageSettingsPanel** | 语言设置面板 |
| `settings/shortcuts_settings.dart` | ShortcutsSettings | 快捷键设置 | **ShortcutsSettingsPanel** | 快捷键设置面板 |

#### 菜单 (Menus)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `settings/popover_menu.dart` | PopoverMenu | 弹出菜单 | **SettingsPopoverMenu** | 设置弹出菜单 |

### 2.7 辅助工具类 (Helpers)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 |
| :--- | :--- | :--- | :--- | :--- |
| `muscle_group_helper.dart` | MuscleGroupHelper | 肌肉群辅助类 | **MuscleGroupHelper** | 肌肉群辅助类 |

---

## 三、 组件目录结构

```
lib/presentation/
├── pages/                              # 页面级组件 (Page)
│   ├── home_navigation_page.dart       # [NEW] 首页导航页面
│   ├── calendar_overview_page.dart      # [NEW] 训练日历页面
│   ├── today_workout_page.dart          # [NEW] 今日训练页面
│   ├── workout_analysis_page.dart       # [NEW] 训练分析页面
│   ├── workout_plan_page.dart           # [NEW] 训练计划页面
│   ├── app_settings_page.dart           # [NEW] 应用设置页面
│   ├── login_page.dart                   # 登录页面
│   ├── register_page.dart                # 注册页面
│   └── settings/                         # 设置子页面
│       ├── settings_dialog.dart          # 设置对话框
│       ├── notification_settings_panel.dart
│       ├── account_settings_panel.dart
│       ├── cloud_settings_panel.dart
│       ├── data_settings_panel.dart
│       ├── theme_settings_panel.dart
│       ├── language_settings_panel.dart
│       ├── shortcuts_settings_panel.dart
│       └── settings_popover_menu.dart
│
├── widgets/                             # 通用组件
│   ├── musclock_app_bar.dart            # 顶部导航栏
│   ├── settings_bottom_sheet.dart       # 设置底部弹窗
│   ├── common/                          # 通用组件
│   │   └── async_value_builder.dart
│   │
│   ├── workout/                         # 训练模块组件
│   │   ├── active_workout_view.dart     # 活跃训练视图
│   │   ├── today_workout_record_view.dart  # [NEW] 今日训练记录视图
│   │   ├── exercise_card.dart            # 训练项目卡片
│   │   ├── add_exercise_bottom_sheet.dart  # [NEW] 添加训练底部弹窗
│   │   ├── training_details_dialog.dart # 训练详情对话框
│   │   └── training_set_data.dart        # 训练组数据类
│   │
│   ├── calendar/                        # 日历模块组件
│   │   ├── day_workout_detail_card.dart # [NEW] 日期训练详情卡片
│   │   ├── workout_record_list.dart      # [NEW] 训练记录列表
│   │   └── workout_record_card.dart      # [NEW] 训练记录卡片
│   │
│   └── plan/                            # 计划模块组件
│       ├── workout_plan_selector.dart   # [NEW] 训练计划选择器
│       ├── workout_plan_details_view.dart # [NEW] 训练计划详情视图
│       ├── workout_plan_setup_dialog.dart # [NEW] 训练计划设置对话框
│       └── workout_plan_day_item.dart    # [NEW] 训练计划日期项
│
└── providers/                           # 状态管理
    ├── providers.dart
    └── workout_session_provider.dart
```

---

## 四、 导航结构 (更新后)

```
HomeNavigationPage (首页导航页面)
  └── NavigationBar (底部导航)
        ├── CalendarOverviewPage (训练日历页面)
        │     └── DayWorkoutDetailCard (日期训练详情卡片)
        │           └── WorkoutRecordList (训练记录列表)
        │                 └── WorkoutRecordCard (训练记录卡片)
        │
        ├── TodayWorkoutPage (今日训练页面)
        │     ├── TodayWorkoutRecordView (今日训练记录视图)
        │     │     └── ExerciseCard (训练项目卡片)
        │     └── ActiveWorkoutView (活跃训练视图)
        │           ├── ExerciseCard (训练项目卡片)
        │           └── AddExerciseBottomSheet (添加训练底部弹窗)
        │
        ├── WorkoutAnalysisPage (训练分析页面)
        │     ├── StatisticsTabView (统计标签页)
        │     │     ├── GlobalStatsCard (全局统计卡片)
        │     │     └── BodyPartStatCard (部位统计卡片)
        │     └── HeatmapTabView (热力图标签页)
        │           └── HeatmapGrid (热力图网格)
        │
        ├── WorkoutPlanPage (训练计划页面)
        │     └── WorkoutPlanSelector (训练计划选择器)
        │           └── WorkoutPlanDetailsView (训练计划详情视图)
        │                 └── WorkoutPlanSetupDialog (训练计划设置对话框)
        │
        └── AppSettingsPage (应用设置页面)
              └── SettingsBottomSheet (设置底部弹窗)
                    └── SettingsDialog (设置对话框)
                          ├── ThemeSettingsPanel (主题设置面板)
                          ├── LanguageSettingsPanel (语言设置面板)
                          ├── DataSettingsPanel (数据设置面板)
                          ├── CloudSettingsPanel (云同步设置面板)
                          ├── AccountSettingsPanel (账户设置面板)
                          ├── NotificationSettingsPanel (通知设置面板)
                          └── ShortcutsSettingsPanel (快捷键设置面板)
```

---

## 五、 核心数据 Provider

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

## 六、 术语对照表

| 英文 | 中文 | 说明 |
|------|------|------|
| Page | 页面 | 顶级导航页面 |
| View | 视图 | 页面内的大块功能区域 |
| Widget | 组件 | UI 组成单元 |
| Sheet / BottomSheet | 底部弹窗 | 从底部弹出的选择面板 |
| Dialog | 对话框 | 居中弹出的模态窗口 |
| Card | 卡片 | 带圆角和阴影的内容容器 |
| TabView | 标签页 | 页面内的多标签切换 |
| Panel | 面板 | 设置或配置类面板 |
| Selector | 选择器 | 水平滚动的选择组件 |
| Helper | 辅助类 | 静态工具方法类 |
| Data | 数据类 | 仅用于 UI 展示的数据类 |
| Provider | 数据提供者 | Riverpod 状态管理 |

---

## 七、 命名规范总结

### 7.1 通过名称判断类型

| 名称结尾 | 类型 | 示例 |
|---------|------|------|
| `Page` | 页面 | `TodayWorkoutPage` |
| `View` | 视图 | `ActiveWorkoutView` |
| `Card` | 卡片 | `ExerciseCard` |
| `List` | 列表 | `WorkoutRecordList` |
| `Dialog` | 对话框 | `TrainingDetailsDialog` |
| `BottomSheet` | 底部弹窗 | `AddExerciseBottomSheet` |
| `TabView` | 标签页 | `StatisticsTabView` |
| `Panel` | 面板 | `ThemeSettingsPanel` |
| `Selector` | 选择器 | `WorkoutPlanSelector` |
| `Helper` | 辅助类 | `MuscleGroupHelper` |
| `Data` | 数据类 | `TrainingSetData` |

### 7.2 命名内在逻辑

* **模块前缀**: `Workout` (训练) / `Calendar` (日历) / `App` (应用)
* **功能描述**: 名称描述核心功能，如 `TodayWorkoutRecordView` = 今日 + 训练 + 记录 + 视图
* **层次继承**: 子组件继承父组件前缀，如 `WorkoutPlanSelector` → `WorkoutPlanDetailsView`

---

## 八、 重构进度

| 状态 | 说明 |
|------|------|
| ✅ 已完成 | 命名规范制定完成 |
| ⏳ 待执行 | 需要根据本规范重命名文件 |

> **下一步**: 根据本规范文档，重命名所有相关文件并更新引用。
