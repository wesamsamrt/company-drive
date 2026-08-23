-- نفّذ هذا الملف كاملًا مرة واحدة في Supabase > SQL Editor.
create extension if not exists pgcrypto;

create type public.workspace_role as enum ('owner','admin','editor','viewer');
create type public.invitation_status as enum ('pending','accepted','declined');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 100),
  email text not null unique,
  avatar_url text,
  created_at timestamptz not null default now()
);
create table public.workspaces (
  id uuid primary key default gen_random_uuid(), name text not null check(char_length(name) between 2 and 100),
  description text, icon_url text, owner_id uuid not null references public.profiles(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.workspace_members (
  workspace_id uuid references public.workspaces(id) on delete cascade, user_id uuid references public.profiles(id) on delete cascade,
  role public.workspace_role not null default 'viewer', joined_at timestamptz not null default now(), primary key(workspace_id,user_id)
);
create table public.invitations (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade, sender_id uuid not null references public.profiles(id),
  role public.workspace_role not null default 'viewer', status public.invitation_status not null default 'pending', created_at timestamptz not null default now(), responded_at timestamptz,
  unique(workspace_id,recipient_id)
);
create table public.folders (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  parent_id uuid references public.folders(id) on delete cascade, name text not null check(char_length(name) between 1 and 160), created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique nulls not distinct(workspace_id,parent_id,name)
);
create table public.files (
  id uuid primary key default gen_random_uuid(), workspace_id uuid not null references public.workspaces(id) on delete cascade,
  folder_id uuid references public.folders(id) on delete set null, name text not null, mime_type text not null, size_bytes bigint not null check(size_bytes >= 0), storage_path text not null unique,
  uploaded_by uuid not null references public.profiles(id), last_modified_by uuid not null references public.profiles(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique nulls not distinct(workspace_id,folder_id,name)
);
create table public.activity_logs (
  id bigint generated always as identity primary key, workspace_id uuid not null references public.workspaces(id) on delete cascade, actor_id uuid not null references public.profiles(id),
  action text not null, entity_type text not null, entity_id text, entity_name text not null, created_at timestamptz not null default now()
);

create or replace function public.create_profile() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,full_name,email) values(new.id,coalesce(new.raw_user_meta_data->>'full_name',split_part(new.email,'@',1)),new.email); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.create_profile();
create or replace function public.add_workspace_owner() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.workspace_members(workspace_id,user_id,role) values(new.id,new.owner_id,'owner'); return new; end $$;
create trigger workspace_owner after insert on public.workspaces for each row execute procedure public.add_workspace_owner();
create or replace function public.is_member(ws uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from workspace_members where workspace_id=ws and user_id=auth.uid()) $$;
create or replace function public.has_role(ws uuid, allowed public.workspace_role[]) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from workspace_members where workspace_id=ws and user_id=auth.uid() and role=any(allowed)) $$;
create or replace function public.log_activity(ws uuid, action_text text, entity_type_text text, entity_name_text text, entity_id_text text default null) returns void language plpgsql security definer set search_path=public as $$ begin if not is_member(ws) then raise exception 'forbidden'; end if; insert into activity_logs(workspace_id,actor_id,action,entity_type,entity_name,entity_id) values(ws,auth.uid(),action_text,entity_type_text,entity_name_text,entity_id_text); end $$;
create or replace function public.accept_invitation(invitation_id uuid) returns void language plpgsql security definer set search_path=public as $$ declare inv invitations; begin select * into inv from invitations where id=invitation_id and recipient_id=auth.uid() and status='pending' for update; if not found then raise exception 'Invitation unavailable'; end if; insert into workspace_members(workspace_id,user_id,role) values(inv.workspace_id,auth.uid(),inv.role) on conflict(workspace_id,user_id) do update set role=excluded.role; update invitations set status='accepted',responded_at=now() where id=inv.id; perform log_activity(inv.workspace_id,'قبل الدعوة','invitation','دعوة الانضمام',inv.id::text); end $$;

alter table public.profiles enable row level security; alter table public.workspaces enable row level security; alter table public.workspace_members enable row level security; alter table public.invitations enable row level security; alter table public.folders enable row level security; alter table public.files enable row level security; alter table public.activity_logs enable row level security;
create policy "profiles readable" on public.profiles for select to authenticated using(true);
create policy "profiles update self" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy "workspace members read" on public.workspaces for select to authenticated using(is_member(id));
create policy "authenticated create workspace" on public.workspaces for insert to authenticated with check(owner_id=auth.uid());
create policy "owner update workspace" on public.workspaces for update to authenticated using(has_role(id,array['owner']::workspace_role[]));
create policy "owner delete workspace" on public.workspaces for delete to authenticated using(has_role(id,array['owner']::workspace_role[]));
create policy "members list" on public.workspace_members for select to authenticated using(is_member(workspace_id));
create policy "admins manage members" on public.workspace_members for all to authenticated using(has_role(workspace_id,array['owner','admin']::workspace_role[])) with check(has_role(workspace_id,array['owner','admin']::workspace_role[]));
create policy "invites read sender recipient" on public.invitations for select to authenticated using(sender_id=auth.uid() or recipient_id=auth.uid());
create policy "admins invite" on public.invitations for insert to authenticated with check(sender_id=auth.uid() and has_role(workspace_id,array['owner','admin']::workspace_role[]));
create policy "recipient update invitation" on public.invitations for update to authenticated using(recipient_id=auth.uid()) with check(recipient_id=auth.uid());
create policy "admins update invitation" on public.invitations for update to authenticated using(has_role(workspace_id,array['owner','admin']::workspace_role[])) with check(has_role(workspace_id,array['owner','admin']::workspace_role[]));
create policy "members read folders" on public.folders for select to authenticated using(is_member(workspace_id));
create policy "editors manage folders" on public.folders for insert to authenticated with check(has_role(workspace_id,array['owner','admin','editor']::workspace_role[]));
create policy "admins delete folders" on public.folders for delete to authenticated using(has_role(workspace_id,array['owner','admin']::workspace_role[]));
create policy "members read files" on public.files for select to authenticated using(is_member(workspace_id));
create policy "editors upload metadata" on public.files for insert to authenticated with check(uploaded_by=auth.uid() and last_modified_by=auth.uid() and has_role(workspace_id,array['owner','admin','editor']::workspace_role[]));
create policy "admins delete metadata" on public.files for delete to authenticated using(has_role(workspace_id,array['owner','admin']::workspace_role[]));
create policy "members activity" on public.activity_logs for select to authenticated using(is_member(workspace_id));

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values ('workspace-files','workspace-files',false,26214400,array['application/pdf','text/csv','application/zip','image/jpeg','image/png','image/webp','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','application/vnd.openxmlformats-officedocument.wordprocessingml.document']) on conflict(id) do nothing;
create policy "member reads objects" on storage.objects for select to authenticated using(bucket_id='workspace-files' and public.is_member((storage.foldername(name))[1]::uuid));
create policy "editors upload objects" on storage.objects for insert to authenticated with check(bucket_id='workspace-files' and public.has_role((storage.foldername(name))[1]::uuid,array['owner','admin','editor']::workspace_role[]));
create policy "admins delete objects" on storage.objects for delete to authenticated using(bucket_id='workspace-files' and public.has_role((storage.foldername(name))[1]::uuid,array['owner','admin']::workspace_role[]));
