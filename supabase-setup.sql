-- ══════════════════════════════════════════════════════════════
-- Run this once in your Supabase project's SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run)
-- ══════════════════════════════════════════════════════════════

-- 1. Table that stores one row per project
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,              -- used in the shareable URL, e.g. "riverside-house"
  project_name text not null,
  client_name text,
  project_date text,
  images jsonb not null default '{}'::jsonb,   -- { "flooring": "https://...", "exterior-hero-render": "https://..." }
  texts jsonb not null default '{}'::jsonb,    -- { "int-room-name": "Primary Suite", "studio-email": "hi@studio.com", ... }
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table projects enable row level security;

-- Anyone (including people who just have the link) can VIEW projects
create policy "Public can view projects"
  on projects for select
  using (true);

-- Only a logged-in admin (you) can create/edit/delete
create policy "Authenticated users can insert projects"
  on projects for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update projects"
  on projects for update
  to authenticated
  using (true);

create policy "Authenticated users can delete projects"
  on projects for delete
  to authenticated
  using (true);

-- ══════════════════════════════════════════════════════════════
-- Already ran this before "texts" existed? Run this one line instead
-- of the table creation above:
-- alter table projects add column if not exists texts jsonb not null default '{}'::jsonb;
-- ══════════════════════════════════════════════════════════════

-- 2. Storage bucket for uploaded renders
insert into storage.buckets (id, name, public)
values ('project-images', 'project-images', true)
on conflict (id) do nothing;

create policy "Public can view project images"
  on storage.objects for select
  using (bucket_id = 'project-images');

create policy "Authenticated can upload project images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'project-images');

create policy "Authenticated can update project images"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'project-images');

create policy "Authenticated can delete project images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'project-images');

-- ══════════════════════════════════════════════════════════════
-- 3. Create yourself an admin login
-- Dashboard → Authentication → Users → Add user
-- Enter your email + a password. That's what you'll log into
-- admin.html with. (No public sign-up is exposed anywhere —
-- this is the only way an account gets created.)
-- ══════════════════════════════════════════════════════════════
