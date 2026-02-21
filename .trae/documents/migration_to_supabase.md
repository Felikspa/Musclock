# 迁移至 Supabase 评估与计划

## 1. 现状评估

经过代码分析，目前的后端集成情况如下：

*   **核心类**: `MinAppClient` (位于 `lib/data/cloud/minapp_client.dart`) 封装了所有与 MinApp 的交互。
*   **认证**: `AuthStateNotifier` 依赖 `MinAppClient` 进行登录/注册。
*   **数据同步**: `CloudSyncService` (位于 `lib/data/cloud/sync_service_impl.dart`) 负责数据同步，但目前 **仅实现了上传逻辑的框架，下载/合并逻辑尚未完成**。
*   **配置**: 使用 `CloudConfig` 注入环境变量。

**迁移工程量评估**: **中等偏低 (Low-Medium)**
由于原有的数据同步逻辑尚未完全跑通，现在切换到 Supabase 是一个非常好的时机，不会造成大量的代码浪费。Supabase 提供的 Flutter SDK (`supabase_flutter`) 非常成熟，可以大幅简化目前手动封装 HTTP 请求的代码。

## 2. 迁移方案

我们将移除 `MinAppClient`，直接集成官方 `supabase_flutter` SDK。

### 第一步：依赖与配置更新
1.  **添加依赖**: 引入 `supabase_flutter`。
2.  **清理代码**: 移除 `http` 请求封装代码 (`MinAppClient` 大部分代码将被废弃)。
3.  **环境变量**: 将 `MINAPP_CLIENT_ID` / `SECRET` 替换为 `SUPABASE_URL` / `SUPABASE_ANON_KEY`。

### 第二步：认证模块 (Auth) 重构
*   **目标**: 替换 `AuthStateNotifier` 中的逻辑。
*   **实现**: 使用 `Supabase.instance.client.auth` 替代原有的 REST API 调用。Supabase 自动处理 Token 持久化和刷新，代码量将减少 50% 以上。

### 第三步：数据库与同步 (Database)
*   **目标**: 实现真正的数据同步。
*   **实现**:
    *   利用 Supabase 的 PostgreSQL 接口。
    *   在 `CloudSyncService` 中，将原有的 HTTP `createRecord`/`updateRecord` 调用替换为 Supabase 的 `.from('table').upsert()` 或 `.insert()`。
    *   **优势**: Supabase 支持 `upsert` (存在则更新，不存在则插入)，这将极大简化同步逻辑。

## 3. 您需要提供的信息

为了开始迁移，请您提供以下 Supabase 项目信息（可以在 Supabase 后台 -> Project Settings -> API 中找到）：

1.  **Project URL** (例如: `https://xyzcompany.supabase.co`)
2.  **Anon / Public Key** (以 `eyJ` 开头的长字符串)

## 4. 数据库表结构准备 (SQL)

Supabase 使用 PostgreSQL，我们需要在 Supabase 的 SQL Editor 中运行以下命令来创建表结构，以匹配您本地的 Drift 数据库：

```sql
-- 用户配置表 (示例)
create table user_settings (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  -- 其他字段...
);

-- 启用行级安全策略 (RLS) - 这一步很重要，保证用户只能访问自己的数据
alter table user_settings enable row level security;

create policy "Users can insert their own settings."
  on user_settings for insert
  with check ( auth.uid() = id );

create policy "Users can update their own settings."
  on user_settings for update
  using ( auth.uid() = id );

create policy "Users can select their own settings."
  on user_settings for select
  using ( auth.uid() = id );
```

*注：我们可以先完成代码迁移，然后再协助您在 Supabase 后台运行 SQL 建表脚本。*
