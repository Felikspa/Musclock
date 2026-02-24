# Muscle Clock UI 命名规范与组件文档 (v3.0)

> 用于团队内部标准化交流的界面组件命名参考文档
>
> **核心原则**: 通过名称可直接判断组件类型，名称具有内在逻辑，用户一眼可看出代表哪个组件

---

## 一、 核心命名原则 (Mandatory)

为了保证代码的可读性与维护性，所有 UI 组件必须遵循以下硬性约束：

### 1.1 英文命名规则 (PascalCase)

### 1.2 中文命名规则

* **必须包含类型显式后缀**：页面、视图、卡片、列表、对话框、底部弹窗、标签页、网格、工具类、数据类。
* **严禁简称**：如"弹窗"必须区分是"对话框"还是"底部弹窗"。

### 1.3 命名内在逻辑

* **模块前缀**: 同一模块的组件使用统一前缀，如 `Today` (今日训练)、`Calendar` (日历)、`Plan` (计划)
* **功能描述**: 名称应清晰描述功能，如 `TodaySessionView` (今日训练视图)
* **层次关系**: 子组件名称应继承父组件前缀，如 `PlanSelector` → `PlanDetailView` → `PlanSetupDialog`

### 1.4 命名简化规则

* **消除冗余前缀**: `Workout` 作为前缀冗余，删除（如 `TodayWorkoutPage` → `TodayPage`）
* **统一使用单数**: 中间部分一律使用单数（如 `PlanDetailsView` → `PlanDetailView`）
* **与数据层术语一致**: UI层与数据层术语保持一致，使用 `Session`、`ExerciseRecord`、`Set`

---

## 二、 术语定义（基于数据层）

### 数据层（Database）

| 术语 | 含义 |
|------|------|
| **WorkoutSession** | 一次完整训练（时间块） |
| **ExerciseRecord** | 一个训练项目（动作+所有组） |
| **SetRecord** | 单组训练数据（重量×次数） |

### UI层

| 术语 | 含义 | 使用场景 |
|------|------|---------|
| **Session** | WorkoutSession 的简称 | UI组件中常用 |
| **ExerciseRecord** | 与数据层一致 | ExerciseRecordCard |
| **Set** | SetRecord 的简称 | SetCard, SetInput |

### 层级结构

```
WorkoutSession（一次完整训练）
  └── 多个 ExerciseRecord（训练项目）
        └── 多个 SetRecord（组数）
```

---

## 三、 命名重构对照表

### 3.1 页面级 (Pages)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `home_page.dart` | HomePage | 主页/导航页 | **NavigationPage** | 导航页面 | 底部导航栏容器，包含5个导航tab |
| `calendar_page.dart` | CalendarPage | 日历页 | **CalendarPage** | 日历页面 | 月历视图，显示每天训练状态 |
| `today_page.dart` | TodayPage | 今日训练页 | **TodayPage** | 今日页面 | 显示今日训练或未开始训练的入口 |
| `analysis_page.dart` | AnalysisPage | 数据分析页 | **AnalysisPage** | 分析页面 | 训练数据统计和热力图展示 |
| `plan_page.dart` | PlanPage | 计划页 | **PlanPage** | 计划页面 | 训练计划列表和详情 |
| `settings_page.dart` | SettingsPage | 设置页 | **SettingsPage** | 设置页面 | 应用全局设置入口 |
| `login_page.dart` | LoginPage | 登录页 | **LoginPage** | 登录页面 | 用户登录表单 |
| `register_page.dart` | RegisterPage | 注册页 | **RegisterPage** | 注册页面 | 用户注册表单 |

### 3.2 通用组件 (Common Widgets)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `common/async_value_builder.dart` | AsyncValueBuilder | 异步值构建器 | **AsyncValueBuilder** | 异步值构建器 | 通用异步状态加载器 |
| `musclock_app_bar.dart` | MusclockAppBar | 顶部导航栏 | **MusclockAppBar** | 顶部导航栏 | 带标题和操作按钮的AppBar |
| `settings_bottom_sheet.dart` | SettingsBottomSheet | 设置底部弹窗 | **SettingsBottomSheet** | 设置底部弹窗 | 从底部弹出的设置列表：：：**备注**：检查这个组件是否已经弃用，弃用组件应该删除 |

### 3.3 Today 模块组件 (Today Module)

#### 视图 (Views)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `active_workout_view.dart` | ActiveWorkoutView | 活跃训练视图 | **ActiveSessionView** | 活跃训练视图 | 正在进行中的训练界面，包含动作列表和组数输入 |
| `today_session_view.dart` | TodaySessionView | 今日训练记录视图 | **TodaySessionView** | 今日训练记录视图 | 已完成的训练Session列表卡片 |

#### 卡片 (Cards)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `exercise_card.dart` | ExerciseCard | 训练项目卡片 | **ExerciseRecordCard** | 训练项目卡片 | 单个训练动作卡片，显示动作名+肌肉部位+组数信息 |

#### 底部弹窗 (BottomSheets)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `add_exercise_sheet.dart` | AddExerciseSheet | 添加训练项目弹窗 | **AddExerciseBottomSheet** | 添加训练项目底部弹窗 | 从底部弹出的动作选择器 |

#### 对话框 (Dialogs)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `training_details_dialog.dart` | TrainingDetailsDialog | 训练详情弹窗 | **TrainingDetailDialog** | 训练详情对话框 | 居中弹出的训练详情，包含编辑和删除操作 |

#### 数据模型 (Data)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `training_set_data.dart` | TrainingSetData | 训练组数据类 | **TrainingSetData** | 训练组数据类 | 单组训练数据模型（重量×次数） |

### 3.4 Calendar 模块组件 (Calendar Module)

#### 视图 (Views)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `calendar/exercise_records_list.dart` | ExerciseRecordsList | 训练记录列表 | **ExerciseRecordList** | 训练记录列表 | 某日训练记录的垂直列表 |

#### 卡片 (Cards)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `calendar/day_detail_card.dart` | DayDetailCard | 日期详情卡片 | **DayDetailCard** | 日期详情卡片 | 日历中某一天的训练概览卡片 |
| `calendar/exercise_record_card.dart` | ExerciseRecordCard | 训练记录卡片 | **ExerciseRecordCard** | 训练记录卡片 | 日历视图中显示的单条训练记录 |

### 3.5 Plan 模块组件 (Plan Module)

#### 选择器 (Selectors)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `plan/plan_selector.dart` | PlanSelector | 计划选择器 | **PlanSelector** | 计划选择器 | 水平滚动的计划项选择器 |

#### 视图 (Views)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `plan/plan_details_widget.dart` | PlanDetailsWidget | 计划详情组件 | **PlanDetailView** | 计划详情视图 | 计划的详细信息展示区域 |

#### 对话框 (Dialogs)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `plan/plan_setup_dialog.dart` | PlanSetupDialog | 计划设置弹窗 | **PlanSetupDialog** | 计划设置对话框 | 创建/编辑计划的对话框 |
| `plan/training_day_picker_dialog.dart` | TrainingDayPickerDialog | 训练日选择弹窗 | **TrainingDayPickerDialog** | 训练日选择对话框 | 选择一周中训练日期的对话框 |

#### 列表项 (List Items)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `plan/custom_plan_day_item.dart` | CustomPlanDayItem | 自定义计划日期项 | **PlanDayItem** | 计划日期项 | 计划列表中的单个日期项 |

### 3.6 Settings 模块组件 (Settings Module)

#### 对话框 (Dialogs)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `settings/settings_dialog.dart` | SettingsDialog | 设置对话框 | **SettingsDialog** | 设置对话框 | 设置列表的主对话框 |

#### 面板 (Panels)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `settings/notification_settings.dart` | NotificationSettings | 通知设置 | **NotificationSettingsPanel** | 通知设置面板 | 推送通知相关设置 |
| `settings/account_settings.dart` | AccountSettings | 账户设置 | **AccountSettingsPanel** | 账户设置面板 | 用户账户信息设置 |
| `settings/cloud_settings.dart` | CloudSettings | 云同步设置 | **CloudSettingsPanel** | 云同步设置面板 | iCloud/云同步设置 |
| `settings/data_settings.dart` | DataSettings | 数据设置 | **DataSettingsPanel** | 数据设置面板 | 数据导入导出设置 |
| `settings/theme_settings.dart` | ThemeSettings | 主题设置 | **ThemeSettingsPanel** | 主题设置面板 | 深色/浅色主题切换 |
| `settings/language_settings.dart` | LanguageSettings | 语言设置 | **LanguageSettingsPanel** | 语言设置面板 | 应用语言选择 |
| `settings/shortcuts_settings.dart` | ShortcutsSettings | 快捷键设置 | **ShortcutsSettingsPanel** | 快捷键设置面板 | 快捷键配置 |

#### 菜单 (Menus)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `settings/popover_menu.dart` | PopoverMenu | 弹出菜单 | **SettingsPopoverMenu** | 设置弹出菜单 | 设置项的弹出菜单 |

### 3.7 辅助工具类 (Helpers)

| 文件路径 | 旧英文名 | 旧中文名 | 新英文名 | 新中文名 | 描述 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `muscle_group_helper.dart` | MuscleGroupHelper | 肌肉群辅助类 | **MuscleGroupHelper** | 肌肉群辅助类 | 肌肉群颜色、名称等静态工具方法 |
| `exercise_helper.dart` | ExerciseHelper | 动作辅助类 | **ExerciseHelper** | 动作辅助类 | 动作名称本地化等静态工具方法 |

---

## 四、 组件目录结构

```
lib/presentation/
├── pages/                              # 页面级组件 (Page)
│   ├── home_navigation_page.dart       # 首页导航页面
│   ├── calendar_overview_page.dart    # 训练日历页面
│   ├── today_page.dart                 # 今日训练页面
│   ├── analysis_page.dart              # 数据分析页面
│   ├── plan_page.dart                  # 计划页面
│   ├── app_settings_page.dart          # 应用设置页面
│   ├── login_page.dart                  # 登录页面
│   ├── register_page.dart               # 注册页面
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
│   ├── today/                           # 今日训练模块
│   │   ├── active_session_view.dart      # 活跃训练视图
│   │   ├── today_session_view.dart      # 今日训练记录视图
│   │   ├── exercise_record_card.dart     # 训练项目卡片
│   │   ├── add_exercise_bottom_sheet.dart # 添加训练底部弹窗
│   │   ├── training_detail_dialog.dart   # 训练详情对话框
│   │   └── training_set_data.dart        # 训练组数据类
│   │
│   ├── calendar/                        # 日历模块组件
│   │   ├── day_workout_detail_card.dart # 日期训练详情卡片
│   │   ├── exercise_record_list.dart     # 训练记录列表
│   │   └── exercise_record_card.dart     # 训练记录卡片
│   │
│   └── plan/                            # 计划模块组件
│       ├── plan_selector.dart            # 计划选择器
│       ├── plan_detail_view.dart         # 计划详情视图
│       ├── plan_setup_dialog.dart        # 计划设置对话框
│       ├── plan_day_item.dart            # 计划日期项
│       └── training_day_picker_dialog.dart # 训练日选择对话框
│
└── providers/                           # 状态管理
    ├── providers.dart
    └── workout_session_provider.dart
```

---

## 五、 导航结构

```
HomeNavigationPage (首页导航页面)
  └── NavigationBar (底部导航)
        ├── CalendarOverviewPage (训练日历页面)
        │     └── DayWorkoutDetailCard (日期训练详情卡片)
        │           └── ExerciseRecordList (训练记录列表)
        │                 └── ExerciseRecordCard (训练记录卡片)
        │
        ├── TodayPage (今日训练页面)
        │     ├── TodaySessionView (今日训练记录视图)
        │     │     └── ExerciseRecordCard (训练项目卡片)
        │     └── ActiveSessionView (活跃训练视图)
        │           ├── ExerciseRecordCard (训练项目卡片)
        │           └── AddExerciseBottomSheet (添加训练底部弹窗)
        │
        ├── AnalysisPage (数据分析页面)
        │     ├── StatisticsTabView (统计标签页)
        │     │     ├── GlobalStatsCard (全局统计卡片)
        │     │     └── BodyPartStatCard (部位统计卡片)
        │     └── HeatmapTabView (热力图标签页)
        │           └── HeatmapGrid (热力图网格)
        │
        ├── PlanPage (计划页面)
        │     └── PlanSelector (计划选择器)
        │           └── PlanDetailView (计划详情视图)
        │                 └── PlanSetupDialog (计划设置对话框)
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

## 六、 核心数据 Provider

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

## 七、 术语对照表

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

## 八、 命名规范总结

### 8.1 通过名称判断类型

| 名称结尾 | 类型 | 示例 |
|---------|------|------|
| `Page` | 页面 | `TodayPage` |
| `View` | 视图 | `ActiveSessionView` |
| `Card` | 卡片 | `ExerciseRecordCard` |
| `List` | 列表 | `ExerciseRecordList` |
| `Dialog` | 对话框 | `TrainingDetailDialog` |
| `BottomSheet` | 底部弹窗 | `AddExerciseBottomSheet` |
| `TabView` | 标签页 | `StatisticsTabView` |
| `Panel` | 面板 | `ThemeSettingsPanel` |
| `Selector` | 选择器 | `PlanSelector` |
| `Helper` | 辅助类 | `MuscleGroupHelper` |
| `Data` | 数据类 | `TrainingSetData` |

### 8.2 命名内在逻辑

* **模块前缀**: `Today` (今日) / `Calendar` (日历) / `Plan` (计划) / `App` (应用)
* **功能描述**: 名称描述核心功能，如 `TodaySessionView` = 今日 + 训练 + 视图
* **层次继承**: 子组件继承父组件前缀，如 `PlanSelector` → `PlanDetailView`

### 8.3 简化规则

* **消除冗余**: 删除 `Workout` 前缀（如 `TodayWorkoutPage` → `TodayPage`）
* **统一单数**: 中间部分使用单数（如 `PlanDetailsView` → `PlanDetailView`）
* **术语一致**: UI层与数据层术语保持一致（Session、ExerciseRecord、Set）
