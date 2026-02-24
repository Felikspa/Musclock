# Musclock

> **力量训练记录与分析工具** | 基于 Flutter + Clean Architecture

![Version](https://img.shields.io/badge/version-v1.0.0%2B1-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![License](https://img.shields.io/badge/license-MIT-green)

Musclock 是一款基于 Flutter 的轻量级力量训练记录与分析工具。它采用 Clean Architecture 架构，旨在帮助用户科学地记录训练内容、追踪肌肉恢复状态、分析训练频率，并制定周期性训练计划。

---

## 核心功能

| 模块 | 功能描述 |
|------|----------|
| **训练记录 (Today)** | 实时记录训练动作、组数、重量与次数，支持自动计算容量 |
| **日历视图 (Calendar)** | 按月展示训练历史，基于数据置信度的加权得分制热力图呈现训练强度 |
| **数据分析 (Analysis)** | 多维度统计（部位训练频率、休息天数、总容量），辅助科学训练 |
| **计划管理 (Plan)** | 支持 PPL、Upper/Lower、Bro Split 等经典分化计划及自定义计划 |
| **本地优先** | 数据完全存储在本地 SQLite 数据库，支持 JSON/CSV 导出与备份 |
| **云同步 (Beta)** | 支持 Supabase BaaS 平台数据同步 |

---

## 技术架构

项目遵循 **Clean Architecture** 分层原则，配合 **Riverpod** 进行状态管理。

### 架构分层

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│              (Flutter + Riverpod)                       │
│         Pages / Widgets / StateNotifiers / Providers     │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                      Domain Layer                        │
│                    (Pure Dart)                          │
│            Entities / UseCases / Repository Interfaces   │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                       Data Layer                         │
│                  (Drift + SQLite)                       │
│      Repository Implementation / Database / Services    │
└─────────────────────────────────────────────────────────┘
```

### 关键技术栈

| 领域 | 技术 | 说明 |
|------|------|------|
| Framework | Flutter | 跨平台 UI 框架 |
| Language | Dart 3 | 强类型、空安全 |
| State Management | Flutter Riverpod | 声明式状态管理，依赖注入 |
| Database | Drift (SQLite) | 类型安全的 ORM，支持 Stream 响应式查询 |
| Localization | flutter_localizations | 官方国际化方案 (ARB) |

---

## 目录结构

```
Musclock/
├── lib/
│   ├── core/                    # 核心配置
│   │   ├── constants/            # 常量定义
│   │   ├── enums/               # 枚举定义
│   │   └── theme/               # 主题配置
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
└── pubspec.yaml                 # 项目配置
```

---

## 核心算法

### 1. 部位恢复天数计算
基于 UTC 时间戳计算距离上次训练的天数，UI 展示为 "x天x小时" 格式。

### 2. 部位训练频率
```
频率 = 包含该部位的所有Session数量 / (当前时间 - 首次训练时间)
```
全周期平均频率，非滚动窗口计算。

### 3. 训练量 (Volume)
```
单组 Volume = 重量 × 次数
单动作 Volume = Σ(重量 × 次数)
单 Session Volume = Σ(所有动作的volume)
```

### 4. 训练值 (Training Points - TP)
基于数据置信度的加权得分制热力图算法，支持渐进式降级：

- **Level 1** (模糊匹配层): 仅记录部位 → TP = 部位基础权重 × √部位数量
- **Level 2** (结构化层): 有组数记录 → TP = Σ(组数 × 1.2)
- **Level 3** (精确测量层): 完整数据 → TP = Σ(重量 × 次数 × 组数) × 动作难度系数 × 1.5

**视觉反馈**: 浅绿色 → 中绿色 → 深绿色/金色

---

## 数据模型

核心实体：

- **BodyPart**: 训练部位（如 Chest, Back, Legs）
- **Exercise**: 训练动作，归属于某个或多个 BodyPart
- **WorkoutSession**: 一次训练会话
- **ExerciseRecord**: 会话中的动作记录
- **SetRecord**: 动作下的具体组数据
- **TrainingPlan**: 周期性训练计划
- **PlanItem**: 计划中的单日安排

---

## 运行项目

### 前置要求

- Flutter SDK 3.x
- Dart 3.x

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run
```

### 构建 APK

```bash
flutter build apk --release
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| **v1.0.0+1** | 2026-02-24 | 正式版发布 - App Icon、正式签名、应用名称 |
| **v0.8.0-beta.1** | 2026-02-24 | Plan交互逻辑优化 |
| **v0.6.3-beta.1** | 2026-02-24 | 训练详情编辑页保存修复 |
| **v0.5.0-beta.1** | 2026-02-24 | Plan页执行计划功能 |
| **v0.2.8-beta.1** | 2026-02-23 | UI风格重构完成 |

完整版本历史请查看 [PROJECT_TRACKER.md](./PROJECT_TRACKER.md)

---

## 未来规划

### 即将推出
- [ ] 云同步功能完善
- [ ] 训练提醒通知
- [ ] 训练数据图表可视化

### 长期目标
- [ ] 跨平台支持 (iOS/Web)
- [ ] 训练数据分享
- [ ] AI 训练建议
- [ ] Apple Watch / 健康 App 集成

---

## 许可证

MIT License
