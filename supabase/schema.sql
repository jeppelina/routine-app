-- routine-app — Supabase schema
-- Run this once in the Supabase SQL editor (Project → SQL → New query).
--
-- Access model: the household `id` (an unguessable UUID) is the shared "key".
-- Anyone who knows it can read/write that household; that's the intended,
-- low-stakes, no-login design for a single family. Not real auth.

create extension if not exists pgcrypto;

-- One row per family. `state` holds the live routine JSON for cross-device sync.
create table if not exists households (
  id         uuid primary key default gen_random_uuid(),
  name       text,
  state      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Append-only log of completed tasks — powers stars history / streaks.
create table if not exists completions (
  id           bigint generated always as identity primary key,
  household_id uuid not null references households(id) on delete cascade,
  child        text not null,
  routine      text not null,
  task_text    text not null,
  completed_on date not null default (now() at time zone 'Europe/Stockholm')::date,
  created_at   timestamptz not null default now()
);

create index if not exists completions_household_date_idx
  on completions (household_id, completed_on);

-- Don't log the same task twice for the same child on the same day.
create unique index if not exists completions_unique_daily
  on completions (household_id, child, routine, task_text, completed_on);

-- Row-Level Security. Policies are permissive because the unguessable `id`
-- is the secret; the anon key is public (it ships in the static page).
alter table households  enable row level security;
alter table completions enable row level security;

create policy "anon read households"   on households  for select using (true);
create policy "anon insert households" on households  for insert with check (true);
create policy "anon update households" on households  for update using (true) with check (true);

create policy "anon read completions"   on completions for select using (true);
create policy "anon insert completions" on completions for insert with check (true);
create policy "anon delete completions" on completions for delete using (true);

-- Live updates pushed to every device.
alter publication supabase_realtime add table households;
alter publication supabase_realtime add table completions;

-- Create your family's row and copy the returned id into the app config:
-- insert into households (name) values ('Lindmarker') returning id;
