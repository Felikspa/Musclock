-- ============================================
-- Musclock Supabase 数据库表结构
-- 用于云同步训练数据
-- ============================================

-- 启用 UUID 扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. 训练部位表 (Body Parts)
-- ============================================
DROP TABLE IF EXISTS body_parts CASCADE;
CREATE TABLE body_parts (
    id TEXT PRIMARY KEY,           -- UUID v4 字符串 (与本地 SQLite 一致)
    name TEXT NOT NULL,            -- 部位名称 (Chest, Back, Legs 等)
    is_deleted BOOLEAN DEFAULT false,  -- 软删除标志
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- 创建时间
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- 更新时间
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE  -- 用户ID (用于多设备)
);

-- ============================================
-- 2. 训练动作表 (Exercises)
-- ============================================
DROP TABLE IF EXISTS exercises CASCADE;
CREATE TABLE exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,            -- 动作名称 (Bench Press, Squat 等)
    body_part_id TEXT NOT NULL,    -- 关联的部位 ID
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- 外键约束
    CONSTRAINT fk_exercise_body_part 
        FOREIGN KEY (body_part_id) REFERENCES body_parts(id) ON DELETE CASCADE
);

-- ============================================
-- 3. 训练会话表 (Workout Sessions)
-- ============================================
DROP TABLE IF EXISTS workout_sessions CASCADE;
CREATE TABLE workout_sessions (
    id TEXT PRIMARY KEY,
    start_time TIMESTAMPTZ NOT NULL,   -- 训练开始时间
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    body_part_ids TEXT DEFAULT '[]',    -- JSON 数组: 训练的部位 ID 列表
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- ============================================
-- 4. 动作记录表 (Exercise Records)
-- ============================================
DROP TABLE IF EXISTS exercise_records CASCADE;
CREATE TABLE exercise_records (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,      -- 关联的训练会话
    exercise_id TEXT NOT NULL,     -- 关联的动作 (或 "bodyPart:部位ID" 格式)
    is_deleted BOOLEAN DEFAULT false,  -- 软删除标志
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    CONSTRAINT fk_record_session 
        FOREIGN KEY (session_id) REFERENCES workout_sessions(id) ON DELETE CASCADE
);

-- ============================================
-- 5. 组记录表 (Set Records)
-- ============================================
DROP TABLE IF EXISTS set_records CASCADE;
CREATE TABLE set_records (
    id TEXT PRIMARY KEY,
    exercise_record_id TEXT NOT NULL,  -- 关联的动作记录
    weight REAL NOT NULL,              -- 重量 (kg)
    reps INTEGER NOT NULL,             -- 次数
    order_index INTEGER NOT NULL,      -- 排序索引 (同动作内的组序号)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    CONSTRAINT fk_set_record 
        FOREIGN KEY (exercise_record_id) REFERENCES exercise_records(id) ON DELETE CASCADE
);

-- ============================================
-- 6. 训练计划表 (Training Plans)
-- ============================================
DROP TABLE IF EXISTS training_plans CASCADE;
CREATE TABLE training_plans (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,            -- 计划名称 (PPL, Upper/Lower 等)
    cycle_length_days INTEGER NOT NULL DEFAULT 7,  -- 周期天数
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- ============================================
-- 7. 计划项目表 (Plan Items)
-- ============================================
DROP TABLE IF EXISTS plan_items CASCADE;
CREATE TABLE plan_items (
    id TEXT PRIMARY KEY,
    plan_id TEXT NOT NULL,         -- 关联的训练计划
    day_index INTEGER NOT NULL,    -- 周期内的天数索引 (0, 1, 2...)
    body_part_ids TEXT NOT NULL,   -- JSON 数组: 该日训练的部位 ID
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    CONSTRAINT fk_plan_item 
        FOREIGN KEY (plan_id) REFERENCES training_plans(id) ON DELETE CASCADE
);

-- ============================================
-- 8. 同步元数据表 (Sync Metadata)
-- ============================================
DROP TABLE IF EXISTS sync_metadata CASCADE;
CREATE TABLE sync_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    last_sync_time TIMESTAMPTZ,    -- 最后同步时间
    device_id TEXT,                -- 设备标识
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 创建索引以提升查询性能
-- ============================================

-- body_parts 索引
CREATE INDEX idx_body_parts_user ON body_parts(user_id);
CREATE INDEX idx_body_parts_name ON body_parts(name);

-- exercises 索引
CREATE INDEX idx_exercises_user ON exercises(user_id);
CREATE INDEX idx_exercises_body_part ON exercises(body_part_id);

-- workout_sessions 索引
CREATE INDEX idx_sessions_user ON workout_sessions(user_id);
CREATE INDEX idx_sessions_start_time ON workout_sessions(start_time DESC);

-- exercise_records 索引
CREATE INDEX idx_records_user ON exercise_records(user_id);
CREATE INDEX idx_records_session ON exercise_records(session_id);

-- set_records 索引
CREATE INDEX idx_sets_user ON set_records(user_id);
CREATE INDEX idx_sets_exercise_record ON set_records(exercise_record_id);
CREATE INDEX idx_sets_order ON set_records(order_index);

-- training_plans 索引
CREATE INDEX idx_plans_user ON training_plans(user_id);
CREATE INDEX idx_plans_name ON training_plans(name);

-- plan_items 索引
CREATE INDEX idx_plan_items_user ON plan_items(user_id);
CREATE INDEX idx_plan_items_plan ON plan_items(plan_id);
CREATE INDEX idx_plan_items_day ON plan_items(day_index);

-- sync_metadata 索引
CREATE INDEX idx_sync_metadata_user ON sync_metadata(user_id);

-- ============================================
-- 启用 Row Level Security (RLS)
-- ============================================

ALTER TABLE body_parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE set_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_metadata ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS 策略: 用户只能操作自己的数据
-- ============================================

-- body_parts 策略
CREATE POLICY "Users can select their own body_parts" 
    ON body_parts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own body_parts" 
    ON body_parts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own body_parts" 
    ON body_parts FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own body_parts" 
    ON body_parts FOR DELETE USING (auth.uid() = user_id);

-- exercises 策略
CREATE POLICY "Users can select their own exercises" 
    ON exercises FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own exercises" 
    ON exercises FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exercises" 
    ON exercises FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own exercises" 
    ON exercises FOR DELETE USING (auth.uid() = user_id);

-- workout_sessions 策略
CREATE POLICY "Users can select their own sessions" 
    ON workout_sessions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sessions" 
    ON workout_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sessions" 
    ON workout_sessions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sessions" 
    ON workout_sessions FOR DELETE USING (auth.uid() = user_id);

-- exercise_records 策略
CREATE POLICY "Users can select their own exercise_records" 
    ON exercise_records FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own exercise_records" 
    ON exercise_records FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exercise_records" 
    ON exercise_records FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own exercise_records" 
    ON exercise_records FOR DELETE USING (auth.uid() = user_id);

-- set_records 策略
CREATE POLICY "Users can select their own set_records" 
    ON set_records FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own set_records" 
    ON set_records FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own set_records" 
    ON set_records FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own set_records" 
    ON set_records FOR DELETE USING (auth.uid() = user_id);

-- training_plans 策略
CREATE POLICY "Users can select their own plans" 
    ON training_plans FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own plans" 
    ON training_plans FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own plans" 
    ON training_plans FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own plans" 
    ON training_plans FOR DELETE USING (auth.uid() = user_id);

-- plan_items 策略
CREATE POLICY "Users can select their own plan_items" 
    ON plan_items FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own plan_items" 
    ON plan_items FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own plan_items" 
    ON plan_items FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own plan_items" 
    ON plan_items FOR DELETE USING (auth.uid() = user_id);

-- sync_metadata 策略
CREATE POLICY "Users can manage their own sync_metadata" 
    ON sync_metadata FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 创建更新时间触发器函数
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表添加 updated_at 自动更新触发器
CREATE TRIGGER update_body_parts_updated_at 
    BEFORE UPDATE ON body_parts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exercises_updated_at 
    BEFORE UPDATE ON exercises 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_sessions_updated_at 
    BEFORE UPDATE ON workout_sessions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exercise_records_updated_at 
    BEFORE UPDATE ON exercise_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_set_records_updated_at 
    BEFORE UPDATE ON set_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_plans_updated_at 
    BEFORE UPDATE ON training_plans 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plan_items_updated_at 
    BEFORE UPDATE ON plan_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sync_metadata_updated_at 
    BEFORE UPDATE ON sync_metadata 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 插入默认训练部位数据
-- ============================================
INSERT INTO body_parts (id, name, created_at, updated_at) VALUES
    ('body_chest', 'Chest', NOW(), NOW()),
    ('body_back', 'Back', NOW(), NOW()),
    ('body_legs', 'Legs', NOW(), NOW()),
    ('body_shoulders', 'Shoulders', NOW(), NOW()),
    ('body_arms', 'Arms', NOW(), NOW()),
    ('body_glutes', 'Glutes', NOW(), NOW()),
    ('body_abs', 'Abs', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 插入默认训练动作数据
-- ============================================
INSERT INTO exercises (id, name, body_part_id, created_at, updated_at) VALUES
    -- Chest exercises
    ('ex_bench_press', 'Bench Press', 'body_chest', NOW(), NOW()),
    ('ex_incline_press', 'Incline Press', 'body_chest', NOW(), NOW()),
    ('ex_push_up', 'Push Up', 'body_chest', NOW(), NOW()),
    ('ex_cable_fly', 'Cable Fly', 'body_chest', NOW(), NOW()),
    -- Back exercises
    ('ex_deadlift', 'Deadlift', 'body_back', NOW(), NOW()),
    ('ex_lat_pulldown', 'Lat Pulldown', 'body_back', NOW(), NOW()),
    ('ex_barbell_row', 'Barbell Row', 'body_back', NOW(), NOW()),
    ('ex_pull_up', 'Pull Up', 'body_back', NOW(), NOW()),
    -- Legs exercises
    ('ex_squat', 'Squat', 'body_legs', NOW(), NOW()),
    ('ex_leg_press', 'Leg Press', 'body_legs', NOW(), NOW()),
    ('ex_lunge', 'Lunge', 'body_legs', NOW(), NOW()),
    ('ex_leg_curl', 'Leg Curl', 'body_legs', NOW(), NOW()),
    -- Shoulders exercises
    ('ex_overhead_press', 'Overhead Press', 'body_shoulders', NOW(), NOW()),
    ('ex_lateral_raise', 'Lateral Raise', 'body_shoulders', NOW(), NOW()),
    ('ex_front_raise', 'Front Raise', 'body_shoulders', NOW(), NOW()),
    ('ex_face_pull', 'Face Pull', 'body_shoulders', NOW(), NOW()),
    -- Arms exercises
    ('ex_bicep_curl', 'Bicep Curl', 'body_arms', NOW(), NOW()),
    ('ex_tricep_pushdown', 'Tricep Pushdown', 'body_arms', NOW(), NOW()),
    ('ex_hammer_curl', 'Hammer Curl', 'body_arms', NOW(), NOW()),
    ('ex_tricep_extension', 'Tricep Extension', 'body_arms', NOW(), NOW()),
    -- Glutes exercises
    ('ex_hip_thrust', 'Hip Thrust', 'body_glutes', NOW(), NOW()),
    ('ex_glute_bridge', 'Glute Bridge', 'body_glutes', NOW(), NOW()),
    ('ex_cable_kickback', 'Cable Kickback', 'body_glutes', NOW(), NOW()),
    -- Abs exercises
    ('ex_crunch', 'Crunch', 'body_abs', NOW(), NOW()),
    ('ex_plank', 'Plank', 'body_abs', NOW(), NOW()),
    ('ex_leg_raise', 'Leg Raise', 'body_abs', NOW(), NOW()),
    ('ex_russian_twist', 'Russian Twist', 'body_abs', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 创建默认训练计划示例 (PPL - Push Pull Legs)
-- ============================================
INSERT INTO training_plans (id, name, cycle_length_days, created_at, updated_at) VALUES
    ('plan_ppl', 'PPL', 3, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO plan_items (id, plan_id, day_index, body_part_ids, created_at, updated_at) VALUES
    ('plan_ppl_item_0', 'plan_ppl', 0, '["body_chest", "body_shoulders", "body_arms"]', NOW(), NOW()),  -- Push
    ('plan_ppl_item_1', 'plan_ppl', 1, '["body_back", "body_arms"]', NOW(), NOW()),                     -- Pull
    ('plan_ppl_item_2', 'plan_ppl', 2, '["body_legs", "body_glutes"]', NOW(), NOW())                   -- Legs
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 输出完成信息
-- ============================================
DO $$
BEGIN
    RAISE NOTICE 'Musclock Supabase 数据库创建完成!';
    RAISE NOTICE '表: body_parts, exercises, workout_sessions, exercise_records, set_records, training_plans, plan_items, sync_metadata';
    RAISE NOTICE '已启用 RLS 策略，确保用户只能访问自己的数据';
END $$;
