-- Enable UUID extension (optional but good practice)
create extension if not exists "uuid-ossp";

-- 1. Body Parts
create table if not exists body_parts (
  id text primary key,
  user_id uuid references auth.users not null,
  name text not null,
  created_at timestamp with time zone not null,
  is_deleted boolean default false
);

-- 2. Exercises
create table if not exists exercises (
  id text primary key,
  user_id uuid references auth.users not null,
  name text not null,
  body_part_id text not null,
  created_at timestamp with time zone not null
);

-- 3. Workout Sessions
create table if not exists workout_sessions (
  id text primary key,
  user_id uuid references auth.users not null,
  start_time timestamp with time zone not null,
  created_at timestamp with time zone not null,
  body_part_ids text
);

-- 4. Exercise Records
create table if not exists exercise_records (
  id text primary key,
  user_id uuid references auth.users not null,
  session_id text not null,
  exercise_id text not null
);

-- 5. Set Records
create table if not exists set_records (
  id text primary key,
  user_id uuid references auth.users not null,
  exercise_record_id text not null,
  weight double precision not null,
  reps integer not null,
  order_index integer not null
);

-- 6. Training Plans
create table if not exists training_plans (
  id text primary key,
  user_id uuid references auth.users not null,
  name text not null,
  cycle_length_days integer not null,
  created_at timestamp with time zone not null
);

-- 7. Plan Items
create table if not exists plan_items (
  id text primary key,
  user_id uuid references auth.users not null,
  plan_id text not null,
  day_index integer not null,
  body_part_ids text
);

-- Enable RLS (Row Level Security) for all tables
alter table body_parts enable row level security;
alter table exercises enable row level security;
alter table workout_sessions enable row level security;
alter table exercise_records enable row level security;
alter table set_records enable row level security;
alter table training_plans enable row level security;
alter table plan_items enable row level security;

-- Create Policies (Allow users to do everything on their own data)

-- Helper function to create standard policies
create or replace function create_user_policies(table_name text) returns void as $$
begin
  execute format('create policy "Users can select their own %I" on %I for select using (auth.uid() = user_id)', table_name, table_name);
  execute format('create policy "Users can insert their own %I" on %I for insert with check (auth.uid() = user_id)', table_name, table_name);
  execute format('create policy "Users can update their own %I" on %I for update using (auth.uid() = user_id)', table_name, table_name);
  execute format('create policy "Users can delete their own %I" on %I for delete using (auth.uid() = user_id)', table_name, table_name);
end;
$$ language plpgsql;

-- Apply policies
select create_user_policies('body_parts');
select create_user_policies('exercises');
select create_user_policies('workout_sessions');
select create_user_policies('exercise_records');
select create_user_policies('set_records');
select create_user_policies('training_plans');
select create_user_policies('plan_items');
